# -*- coding: utf-8 -*- 
import xlrd
from collections import OrderedDict
import simplejson as json
import sys
import traceback
import os
import shutil

dbginfo = 1
dbgdetail = 2
dbg='0'
dbg = os.environ.get("DBG")

gitrepodir=os.environ.get("GITREPODIR")

parafile="ParamaterSeet.json"
statusfile="terraform.tfstate"

def getpublic(sysname,statusfile,dbg):

	try:
		if dbg == "":
			dbg=0
		else:
			dbg=int(dbg)

                pfile="%s/%s/%s_%s" % (gitrepodir,sysname,sysname,parafile)
                paradata = OrderedDict()
                with open(pfile, 'r') as f:
                        paradata = json.load(f)
                        f.close()

		# 踏み台サーバがあるならそのホスト名からタグを決定
                stepsrvflag=0
                for hostno in paradata['hosts']:
                        if paradata['hosts'][hostno]['role'].encode('utf-8') == "踏み台":
                                stepsrvflag=1
                                stepsrvtag="%s-%s" % (sysname,paradata['hosts'][hostno]['hostname'].encode('utf-8'))

		# 踏み台サーバな無ければ最初に指定したサーバからタグを決定
		if stepsrvflag ==0:
			stepsrvtag="%s-%s" % (sysname,paradata['hosts'][0]['hostname'].encode('utf-8'))

		statusfile="%s/%s/%s" % (gitrepodir,sysname,statusfile)
		statusfata = OrderedDict()
		with open(statusfile, 'r') as f:
			statusdata = json.load(f)
			f.close()

		resourcedate=statusdata['modules'][0]['resources']
		for status in resourcedate:
			sdata=statusdata['modules'][0]['resources'][status]['primary']['attributes']
			if "aws_instance" in status:
				inodedata=resourcedate[status]['primary']['attributes']['id']
				tagdata=resourcedate[status]['primary']['attributes']['tags.Name']
				privateip=resourcedate[status]['primary']['attributes']['private_ip']
				eipflag=0
				for status1 in resourcedate:
					if "aws_eip" in status1:
						instancedata=resourcedate[status1]['primary']['attributes']['instance']
						if inodedata == instancedata:
							eipflag=1
							eipdata=statusdata['modules'][0]['resources'][status1]['primary']['attributes']
							privateip=eipdata.get('private_ip','None')
							publicip=eipdata.get('public_ip','None')
							if stepsrvtag == tagdata:
								print "%s,%s,%s" % (tagdata,privateip,publicip)
							elif dbg != 0:
								print "%s,%s,%s" % (tagdata,privateip,publicip)
				if eipflag == 0:
					if dbg != 0:
						print "%s,%s," % (tagdata,privateip)


		exit( 0 )

	except Exception as e:
		os.chdir(currentdir)
		print '=== エラー内容 ==='
		print 'type:' + str(type(e))
		print traceback.format_exc()

if __name__ == "__main__":
	argv = sys.argv
	argc = len(argv)

	currentdir = os.getcwd()

	if argc <= 1:
		print "NEED PROJECTNAME"
		exit(1)

	sysname=argv[1]

	if argc > 2:
		statusfile=argv[2]

	if argc > 3:
		dbg=argv[3]

	getpublic(argv[1],statusfile,dbg)

###############################################################
