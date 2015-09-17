# Replace text within a string with grep

group <- c("12357e", "12575e", "197e18", "e18947")
group
[1] "12357e" "12575e" "197e18" "e18947"

gsub("e", "", group)
[1] "12357" "12575" "19718" "18947"