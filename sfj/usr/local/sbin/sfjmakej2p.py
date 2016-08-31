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
dbg = os.environ.get("DBG")

confdir=os.environ.get("CONFDIR")
gitrepodir=os.environ.get("GITREPODIR")

vpcnetfile=os.environ.get("vpcnetfile")
aclfile=os.environ.get("aclfile")
hostsfile=os.environ.get("hostsfile")
sfjpara=os.environ.get("sfjpara")

tfcmd=os.environ.get("tfcmd")

parafile="ParamaterSeet.json"

APPLIST=["ApacheHttpd","MySQL"]

def sfjmakej2p(sysname,parafile,dbg=0):

	try:
		currentdir = os.getcwd()

		varsdir="%s/%s" % (gitrepodir,sysname)
		varsfile="%s/%s" % (varsdir,sfjpara)
		if os.path.exists(varsdir) is False:
			os.makedirs(varsdir)

		parafile="%s/%s/%s_%s" % (gitrepodir,sysname,sysname,parafile)

		paradata = OrderedDict()

		with open(parafile, 'r') as f:
			paradata = json.load(f)
			f.close()

		if dbg >= dbgdetail:
			print json.dumps(paradata, indent=2)

		#
		if sysname != paradata['system']['0']['sysname']:
			print "Different SystemName : %s : %s" % sysname,paradata['system'][0]['sysname']
			exit( 1 )

		# パラメータファイルの作成(sfjpara.tfvars)
		f = open(varsfile, "w")

		for cloudno in paradata['cloud']:
			f.write( "aws_access_key=\"%s\"\n" % paradata['cloud'][cloudno]['accesskey'] )
			f.write( "aws_secret_key=\"%s\"\n" % paradata['cloud'][cloudno]['secretkey'] )
			f.write( "reagion=\"%s\"\n" % paradata['cloud'][cloudno]['reagion'] )
			f.write( "privatekeyfile=\"%s\"\n" % paradata['cloud'][cloudno]['privatekeyfile'] )
			pemfile="%s/%s" % (confdir,paradata['cloud'][cloudno]['privatekeyfile'])
			gitpemfile="%s/%s/%s" % (gitrepodir,sysname,paradata['cloud'][cloudno]['privatekeyfile'])
			sfjuser=paradata['cloud'][cloudno]['privatekeyfile'].replace(".pem","" )

			f.write( "private_key_name=\"%s\"\n" % sfjuser)

		f.write( "\n" )

		f.write( "network0=\"%s\"\n" % paradata['network']['0']['network'] )
		f.write( "netmask0=\"%d\"\n" % int(paradata['network']['0']['netmask']) )

		f.write( "\n" )

		for hostno in paradata['hosts']:
			no = int(hostno) + 1
			## f.write( "hostname=\"%s\"\n" % paradata['hosts'][hostno]['hostname'] )
			f.write( "instance_type%d=\"%s\"\n" % (no,paradata['hosts'][hostno]['vmtype']) )
			f.write( "hostip%d=\"%s\"\n" % (no,paradata['hosts'][hostno]['hostip']) )
			f.write( "amitype%d=\"%s\"\n" % (no,paradata['hosts'][hostno]['ostype']) )
			f.write( "\n" )

		f.close()

		# pem ファイルのコピー
		shutil.copy(pemfile, varsdir)

		# vpcnet.tf ファイルのコピー
		shutil.copy(vpcnetfile, varsdir)

		# acl.tf ファイルのコピー
		shutil.copy(aclfile, varsdir)

		# hostN.tf ファイルのコピー
		f = open(hostsfile, "r")
		hostsfiledata = f.read()
		f.close()
		for hostno in paradata['hosts']:
			no = int(hostno) + 1
			# SFJPARAをnoに置換
			hostsdata = hostsfiledata.replace("SFJPARA",str(no))

			hostfile="%s/host%d.tf" % (varsdir,no)
			f = open(hostfile, "w")
			f.write(hostsdata)
			f.close()

		## # terraformの実行
		## os.chdir(varsdir)
		## os.system("terraform %s -var-file=%s" % (tfcmd,varsfile) )

		for hostno in paradata['hosts']:
			hfile="%s/%s/%s-%s.host" % (gitrepodir,sysname,sysname,paradata['hosts'][hostno]['hostname'])
			hf = open(hfile, 'w')

			hf.write("[appl]\n")
			hf.write("%s\n" % paradata['hosts'][hostno]['hostip'] )
			hf.write("\n")
			hf.write("[all:vars]\n")
			hf.write("ansible_ssh_user=ec2-user\n")
			hf.write("ansible_ssh_private_key_file=%s\n\n" % gitpemfile )
			hf.close()

			yfile="%s/%s/%s-%s.yml" % (gitrepodir,sysname,sysname,paradata['hosts'][hostno]['hostname'])
			yf = open(yfile, 'w')

			yf.write("- hosts: appl\n")
			yf.write("  roles:\n")

			for appl in APPLIST:
				item=paradata['hosts'][hostno][appl].encode('utf-8')
				if item == '有' :
					yf.write("    - %s\n" % appl )
			yf.write("\n" )
			yf.close()

		os.chdir(currentdir)
		exit( 0 )

	except Exception as e:
		os.chdir(currentdir)
		print '=== エラー内容 ==='
		print 'type:' + str(type(e))
		print traceback.format_exc()

if __name__ == "__main__":
	argv = sys.argv
	argc = len(argv)

	if argc <= 1:
		print "NEED PROJECTNAME"
		exit(1)

	sysname=argv[1]

	if argc > 2:
		parafile=argv[2]

	if argc > 3:
		dbg=int(argv[3])

	sfjmakej2p(argv[1],parafile,dbg)

###############################################################
