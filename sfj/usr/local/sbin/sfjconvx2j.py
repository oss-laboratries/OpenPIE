# -*- coding: utf-8 -*-

import xlrd
from collections import OrderedDict
import simplejson as json
import sys
import traceback
import os.path

dbginfo = 1
dbgdetail = 2

dbg=os.environ.get("DBG")

confdir=os.environ.get("CONFDIR")
uploaddir=os.environ.get("UPLOADDIR")
gitrepodir=os.environ.get("GITREPODIR")

configfile=os.environ.get("SFJCONFIGFILE")

xlsfile=""
outfile="ParamaterSeet.json"


def sfjconvx2j(dbg=0):

	try:
		paradata = OrderedDict()

		with open(configfile, 'r') as f:
			confdata = json.load(f)
			f.close()

		for n1,k1 in enumerate(confdata.keys()):
			itmdatas = OrderedDict()
			tmp = []

			if dbg >= dbginfo:
				print "no = %d : item = %s" % (n1,k1)

			confinfo = confdata[k1]

			if xlsfile != "":
				file = xlsfile
			else:
				file = "%s/%s" % (uploaddir,confinfo['file'])
			sheet = confinfo['sheet']
			dataarea = confinfo['dataarea']
			tmp = dataarea.split(",")
			fr = int(tmp[0])
			to = int(tmp[1])
			direction = confinfo['direction']
			step = confinfo['step']
			items = confinfo['items']

			if dbg >= dbginfo:
				print "  file      : %s\n" % file
				print "  sheet     : %s\n" % sheet
				print "  dataarea  : %s\n" % dataarea
				print "    fr      : %d\n" % fr
				print "    to      : %d\n" % to
				print "  step      : %s\n" % step
				print "  direction : %s\n" % direction
				print "\n"

			xf = xlrd.open_workbook( file )
			sh = xf.sheet_by_name(sheet)

			if dbg >= dbginfo:
				print "   cnt = %d" % len(items)

			if direction == 2:
				col = fr - 1
				no2 = 0
				while col < to :
					no3 = 0
					itmdata = OrderedDict()
					addflag = 1
					while no3 < len(items) :


						row = int(items[str(no3)]['pos'])
						if row == 0 :
							celldata = items[str(no3)]['def']
						elif row == -1:
							celldata = ""
						elif row > 0:
							celldata = sh.cell((row - 1), col).value
						else:
							celldata = ""

						if items[str(no3)]['itm'] == "hostname" :
							if celldata == "" :
								addflag = 0

						if dbg >= dbginfo:
							print "%12s row : col = %2d : %2d %s\n" % (items[str(no3)]['itm'],row,col,celldata)

						itmdata[items[str(no3)]['itm']] = celldata

						no3 = no3 + 1

					col = col + step

					if addflag == 1:
						itmdatas[no2] = itmdata

					no2 = no2 + 1

				xf.release_resources()

				paradata[k1] = itmdatas

			else:
				row = fr - 1
				no2 = 0
				while row < to :
					no3 = 0
					addflag = 1
					itmdata = OrderedDict()
					while no3 < len(items) :

						col = int(items[str(no3)]['pos'])

						if col == 0 :
							celldata = items[str(no3)]['def']
						elif col == -1 :
							celldata = ""
						elif col > 0 :
							celldata = sh.cell(row, (col - 1)).value
						else:
							celldata = ""

						if items[str(no3)]['itm'] == "network" :
							if celldata == "" :
								addflag = 0

						if dbg >= dbginfo:
							print "%12s row : col = %2d : %2d %s" % (items[str(no3)]['itm'],row,col,celldata)

						itmdata[items[str(no3)]['itm']] = celldata

						no3 = no3 + 1

					row = row + step

					if addflag == 1:
						itmdatas[no2] = itmdata

					no2 = no2 + 1

				xf.release_resources()

				paradata[k1] = itmdatas

		js = json.dumps(paradata, indent=2)

		if dbg >= dbgdetail:
			print js

		#
		sysname=paradata['system'][0]['sysname']
		print "SystemName : %s" % sysname

		
		pjdir="%s/%s" % (gitrepodir,sysname)
		if os.path.exists(pjdir) is False:
			os.makedirs(pjdir)

		# Write to file
		jsonfile="%s/%s_%s" % (pjdir,sysname,outfile)
		with open(jsonfile, 'w') as f:
			f.write(js)
			f.close()

		exit( 0 )

	except Exception as e:
		print '=== エラー内容 ==='
		print 'type:' + str(type(e))
		print traceback.format_exc()


if __name__ == "__main__":
	argv = sys.argv
	argc = len(argv)

	if argc > 1:
		xlsfile="%s/%s" % (uploaddir,argv[1])

	if argc > 2:
		dbg=int(argv[2])

	sfjconvx2j(dbg)

###############################################################
