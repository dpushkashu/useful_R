import csv, time, MySQLdb
from geopy import geocoders

YAHOO_API_KEY = 'INSERT_YAHOO_API_KEY'
GOOGLE_API_KEY = 'INSERT_GOOGLE_API_KEY'

# Database connection
connection = MySQLdb.Connect(host='localhost', user='root', passwd='', db='ufo')
cursor = connection.cursor()

# Open CSV with UFO locations
ufo_reader = csv.reader(open('ufo_awesome.txt', 'r'), delimiter="\t")
parse_errors = 0
geocode_errors = 0
num_rows = 0


for row in ufo_reader:
    
    # There are limits with these geocoding APIs, so 
    # I had to geocode in chunks. These few lines skipped the 
    # first x rows i.e. locations I had successfully geocoded already
    num_rows += 1
    if num_rows < 20365:
        continue
    
    # Parse the sighting time
    try:
        sighting_time = time.strptime(row[0], "%Y%m%d")
        sighting_time = time.strftime("%Y-%m-%d", sighting_time)
    except:
        parse_errors += 1
        continue
    
    # Parse the reporting time
    try:
        reporting_time = time.strptime(row[1], "%Y%m%d")
        reporting_time = time.strftime("%Y-%m-%d", reporting_time)
    except:
        parse_errors += 1
        continue
    
    # Get the location. Sometimes the location is messy in the file
    try:
        location = row[2]
        description = row[5]
    except:
        parse_errors += 1
        continue
    
    try:
        shape = row[3]
    except:
        shape = ''
    try:
        duration = row[4]
    except:
        duration = ''
    
    # Geocoders
    y = geocoders.Yahoo(YAHOO_API_KEY)
    g = geocoders.Google(GOOGLE_API_KEY)
    us = geocoders.GeocoderDotUS()  # Free, but didn't seem to work well when I tried it
    
    # Geocode locations
    try:
        # Try Google first
        place, (latitude, longitude) = list(g.geocode(location, exactly_one=False))[0]
    except:
        try:
            # Then Yahoo
            place, (latitude, longitude) = list(y.geocode(location, exactly_one=False))[0]
        except:
            # Can't find it
            latitude = ''
            longitude = ''
    
    # Build SQL INSERT statement
    sql = "INSERT INTO sightings (sighting_time, reporting_time, location, lat, lng, lat_lng, description, shape, duration) VALUES ("
    sql += "'" + sighting_time + "',"
    sql += "'" + reporting_time + "',"
    sql += "'" + location + "',"
    sql += "'" + str(latitude) + "',"
    sql += "'" + str(longitude) + "',"
    sql += "GeomFromText('POINT(" + str(latitude) + ' ' + str(longitude) + ")'),"
    sql += "'" + description + "',"
    sql += "'" + shape + "',"
    sql += "'" + duration + "'"
    sql += ")"
    
    # Insert into database
    cursor.execute(sql)
    
    # Debug
    print location + "\t" + str(latitude) + "\t" + str(longitude)
    

# DEBUG
print 'Parse errors: ' + str(parse_errors) 

# Close database connection
connection.close()            