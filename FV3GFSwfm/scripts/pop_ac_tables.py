#!/usr/bin/env python
#=====================================================================================
# This script will populate the AC database for global models utilizing the rocoto
# workflow
#
# Author: Jeff Hamilton
# Last Update: 12 July 2018
#
#-------------------------------------------------------------------------------------

import MySQLdb
import os
import sys
import calendar
from datetime import datetime
from datetime import timedelta

def main():
    # Grab the date and forecast length
    yyyymmddhhmm = os.getenv("yyyymmddhhmm");
    fcst_len = os.getenv("FCST_LEN");

    # Grab DB credentials
    db_user = os.getenv("DBI_USER");
    db_pass = os.getenv("DBI_PASS");

    # Grab the MET stat file to read
    stat_file = os.getenv("STAT_FILE");

    # Grab model, analysis name, and stat to grab
    model = os.getenv("MODEL");
    analysis = os.getenv("ANALYSIS");
    statistic = os.getenv("STATISTIC");

    # Set valid time
    year = yyyymmddhhmm[0:4]
    month = yyyymmddhhmm[4:6]
    day = yyyymmddhhmm[6:8]
    hour = yyyymmddhhmm[8:10]

    valid_date = year+"-"+month+"-"+day

    # Set regions

    regions = ['FULL','NH_G2_box','SH_G2_box','TRO_G2_box','NP_G2_box','SP_G2_box']
    region_id = ['7','10','9','8','11','12']

    # declare indexes program will need

    stat_index = -1
    region_index = -1
    model_index = -1
    variable_index = -1
    level_index = -1

    # open database connection

    try:
        db = MySQLdb.connect(host="137.75.133.134", port=3306, user=db_user, passwd=db_pass, db="anom_corr2")
        cursor = db.cursor()
    except MySQLdb.Error, e:
        print "Error %d: %s" % (e.args[0], e.args[1])
        sys.exit (1)

    # Check to see if database table exists, if not create it

    for regid in region_id:
       table = model+"_anomcorr_"+regid

       cmd = 'SHOW TABLES LIKE "%s"' % table

       check = cursor.execute(cmd)

       if (check==0):
         cmd = 'CREATE TABLE %s LIKE template' % table
         print cmd
         cursor.execute(cmd)

    # Open stat file

    try:

      sf = open(stat_file,"r")
 
    except:

      msg = "Error! Stat file, %s does not exist, exiting" % stat_file
      print(msg)
      sys.exit()

    header = sf.readline()

    header_contents = header.split()

    for i in range(len(header_contents)):
       if (header_contents[i] == statistic):
          stat_index = i
       elif (header_contents[i] == "MODEL"):
          model_index = i
       elif (header_contents[i] == "VX_MASK"):
          region_index = i
       elif (header_contents[i] == "FCST_VAR"):
          variable_index = i
       elif (header_contents[i] == "FCST_LEV"):
          level_index = i
       else:
          continue

    msg = "INDEXES stat: %s  model: %s  level: %s  region: %s  variable: %s" % (stat_index,model_index,level_index,region_index,variable_index)
    #print msg

    for line in sf:
       content = line.split()

       stat = content[stat_index]
       stat_model = content[model_index]
       stat_level = content[level_index]
       stat_region = content[region_index]
       stat_var = content[variable_index]


       if (float(stat) == 1):
          final_stat = int(stat)*10000
       elif (float(stat) == 0):
          final_stat = int(stat)*10000
       else:
          final_stat = int(float(stat[:-1])*10000)

       msg = "stat: %s  model: %s  level: %s  region: %s  variable: %s" % (str(final_stat),stat_model,stat_level,stat_region,stat_var)
      # print msg

       if stat_model in model:
          msg = "Model name matches!"
          #print msg
       else:
          msg = "Model name mismatch!"
          print msg
          continue

       if stat_region in regions:
          x = regions.index(stat_region)
          stat_region_id = region_id[x]
       else:
          msg = "Region not included!"
          print msg
          continue

       table = model+"_anomcorr_"+stat_region_id

       cmd = 'REPLACE INTO %s (valid_date, valid_hour, level, variable, fcst_len, wacorr) VALUES ("%s",%s,%s,"%s",%s,%s)' % (table,valid_date,hour,stat_level[1:],stat_var,fcst_len,str(final_stat))
       print cmd
       cursor.execute(cmd)

    sf.close()
                    
    cursor.close()
    db.close()

#-----------------------------------end------------------------------------------------

if __name__ == "__main__":
    main()
