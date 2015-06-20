rm(list=ls())
getwd()
set.seed(973487)
load(url('http://biostat.mc.vanderbilt.edu/wiki/pub/Main/DataSets/titanic3.sav'))

#####
# create training and forecasting data sets from sample
#####


o<-order(runif(dim(titanic3)[1]))
titanic.train <- titanic3[o[1:655],]
titanic.pred <- titanic3[o[656:1309],]

########################
########################
# logit classification
########################
########################

titanic.survival.mod <- glm(survived ~ pclass + sex + pclass:sex + age + sibsp, family = binomial(logit), data = titanic.train)


summary(titanic.survival.mod)

# perform in sample predictions
titanic.is.predict<-predict(titanic.survival.mod, type="response", newdata=titanic.train)

# perform out of sample predictions
titanic.oos.predict<-predict(titanic.survival.mod, type="response", newdata=titanic.pred)

####
# Percent correctly predicted assessment, in- and out-of-sample
####

# in-sample percent survivors correctly predicted
live.logit<-which(titanic.is.predict>0.5)
sum(titanic.train$survived[live.logit])/length(live.logit)

# in-sample percent fatalities correctly predicted
die.logit<-which(titanic.is.predict<=0.5)
1-sum(titanic.train$survived[die.logit])/length(die.logit)

# out-of-sample percent survivors correctly predicted
live.logit<-which(titanic.oos.predict>0.5)
sum(titanic.pred$survived[live.logit])/length(live.logit)

# out-of-sample percent fatalities correctly predicted
die.logit<-which(titanic.oos.predict<=0.5)
1-sum(titanic.pred$survived[die.logit])/length(die.logit)

####
# Heat map assessment, in- and out-of-sample
####

# in-sample fit assessment
library(heatmapFit)
heatmap.fit(form=survived ~ pclass + sex + pclass:sex + age + sibsp, fam = binomial(logit), dat=titanic.pred)

# out-of-sample fit assessment--no package yet :-(
library(fANCOVA)
loess.data<-as.data.frame(cbind(titanic.oos.predict, survived=titanic.pred$survived))
loess.data<-na.omit(loess.data)

titanic.lo.mod<-loess.as(loess.data$titanic.oos.predict, loess.data$survived, degree=1)
titanic.lo.pred<-predict(titanic.lo.mod, newdata=titanic.oos.predict)
summary(titanic.lo.mod)

oo<-order(titanic.oos.predict)

plot(titanic.lo.pred[oo]~titanic.oos.predict[oo], type="l", ylim=c(0,1), xlab="logit predicted Pr(survive)", ylab="empirical probability Pr(survive)")
abline(0, 1, lty=2)
rug(titanic.oos.predict)

###########################################
###########################################
# conditional inference tree classification
###########################################
###########################################

library(party)
titanic.survival.ctree<-ctree(formula = as.factor(survived) ~ pclass + sex + age + sibsp, data = titanic.train)
plot(titanic.survival.ctree)

# export a nicer plot
png(file="titanic-tree.png", width=900, height=700)
plot(titanic.survival.ctree)
dev.off()

###########################################
###########################################
# random forest classification model
###########################################
###########################################

library(randomForest)
titanic.survival.rf<-randomForest(formula = as.factor(survived) ~ pclass + sex + age + sibsp, data = titanic.train, ntree = 5000, importance = TRUE, na.action=na.omit)

# visualization: how important was each variable in the forest?
# from the help file: Here are the definitions of the variable importance measures. For each tree, the prediction accuracy on the out-of-bag portion of the data is recorded. Then the same is done after permuting each predictor variable. The difference between the two accuracies are then averaged over all trees, and normalized by the standard error. For regression, the MSE is computed on the out-of-bag data for each tree, and then the same computed after permuting a variable. The differences are averaged and normalized by the standard error. If the standard error is equal to 0 for a variable, the division is not done (but the measure is almost always equal to 0 in that case).

#The second measure is the total decrease in node impurities from splitting on the variable, averaged over all trees. For classification, the node impurity is measured by the Gini index. For regression, it is measured by residual sum of square.
varImpPlot(titanic.survival.rf)

# marginal effects plots
titanic.train.nomiss<-data.frame(survived=titanic.train$survived, pclass=titanic.train$pclass, sex=titanic.train$sex, age=titanic.train$age, sibsp=titanic.train$sibsp)
titanic.train.nomiss<-na.omit(titanic.train.nomiss)
partialPlot(titanic.survival.rf, pred.data=titanic.train.nomiss, x.var=sex, which.class=1)
partialPlot(titanic.survival.rf, pred.data=titanic.train.nomiss, x.var=pclass, which.class=1)
partialPlot(titanic.survival.rf, pred.data=titanic.train.nomiss, x.var=age, which.class=1, n.pt=8)

