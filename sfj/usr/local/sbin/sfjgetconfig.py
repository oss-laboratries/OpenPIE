# -*- coding: utf-8 -*-

import xlrd
from collections import OrderedDict
import simplejson as json
import sys
import traceback

dbg = 0
dbginfo = 1
dbgdetail = 2

rootdir=""

configfile="%s/%s" % (rootdir,"etc/sfj/SFJ_config.xlsx")
jsonfile="%s/%s" % (rootdir,"etc/sfj/SFJ_config.json")

def sfjgetconfig(dbg=0):

	try:
		cf = xlrd.open_workbook( configfile )
		sh = cf.sheet_by_index(0)

		shconf = OrderedDict()

		# List to hold dictionaries
		for rownum in range(7, 14):
			shdata = OrderedDict()
			itemdata = OrderedDict()

			shdata['file'] = sh.cell(rownum, 1).value
			shdata['sheet'] = sh.cell(rownum, 2).value

			m = int(sh.cell(rownum, 3).value) - 1
			n = int(sh.cell(rownum, 4).value) - 1

			if dbg >= 2:
				print "file:%s sheet:%s row:%d col:%d" % (shdata['file'],shdata['sheet'],m,n)

			aflag = 1
			i = 0
			while n < sh.nrows:
				posdata = OrderedDict()

				item = sh.cell(n, m).value
				default = sh.cell(n, (m + 1)).value
				if type(default) != str and type(default) != unicode :
					default = int(default)
				position = sh.cell(n, (m + 2)).value
				if dbg >= 2:
					print "item:%s default:%s position:%s" % (item,default,position)

				if item == "":
					break

				if item == "dataarea":
					if default == "":
						aflag = 0
						break
					else:
						shdata[item] = default
				else:
					if item == "direction":
						shdata[item] = default
					elif item == "step":
						shdata[item] = default
					else:
						if position != -1:
							posdata['itm'] = item
							posdata['def'] = default
							posdata['pos'] = int(position)

							itemdata[i] = posdata
							i = i + 1

				n = n + 1

			## shdata['memo'] = sh.cell(rownum, 5).value

			if aflag == 1:
				shdata['items'] = itemdata
				shconf[sh.cell(rownum, 0).value] = shdata

		######

		# Serialize the list of dicts to JSON
		js = json.dumps(shconf, indent=2)

		if dbg >= 1:
			print js

		# Write to file
		with open(jsonfile, 'w') as f:
			f.write(js)
			f.close()

	except Exception as e:
		print '=== エラー内容 ==='
		print 'type:' + str(type(e))
		print traceback.format_exc()

sfjgetconfig(dbg)

###############################################################
