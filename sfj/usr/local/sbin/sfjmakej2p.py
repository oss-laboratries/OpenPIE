# -*- coding: utf-8 -*- 
import xlrd
from collections import OrderedDict
import simplejson as json
import sys
import traceback
import os
import pwd
import grp
import shutil

dbginfo = 1
dbgdetail = 2
dbg = os.environ.get("DBG")

confdir=os.environ.get("CONFDIR")
gitrepodir=os.environ.get("GITREPODIR")
homedir=os.environ.get("HOME")
user=os.environ.get("USER")

vpcnetfile=os.environ.get("vpcnetfile")
aclfile=os.environ.get("aclfile")
hostsfile=os.environ.get("hostsfile")
eipfile=os.environ.get("eipfile")
sfjpara=os.environ.get("sfjpara")

tfcmd=os.environ.get("tfcmd")

parafile="ParamaterSeet.json"
appconffile="appconf.json"
zbxserv=os.environ.get("ZBXHOST")

def sfjmakej2p(sysname,parafile,dbg=0):

	try:
		currentdir = os.getcwd()

		varsdir="%s/%s" % (gitrepodir,sysname)
		varsfile="%s/%s" % (varsdir,sfjpara)
		if os.path.exists(varsdir) is False:
			os.makedirs(varsdir)

		appfile="%s/%s" % (confdir,appconffile)

		appdata = OrderedDict()

		with open(appfile, 'r') as f:
			appdata = json.load(f)
			f.close()

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
			pemfile="%s/%s" % (confdir,paradata['cloud'][cloudno]['privatekeyfile'])
			gitpemfile="%s/%s/%s" % (gitrepodir,sysname,paradata['cloud'][cloudno]['privatekeyfile'])
			sfjuser=paradata['cloud'][cloudno]['privatekeyfile'].replace(".pem","" )
			accountid="%s" % (paradata['cloud'][cloudno]['accountid'])

			f.write( "aws_access_key=\"%s\"\n" % paradata['cloud'][cloudno]['accesskey'] )
			f.write( "aws_secret_key=\"%s\"\n" % paradata['cloud'][cloudno]['secretkey'] )
			f.write( "reagion=\"%s\"\n" % paradata['cloud'][cloudno]['reagion'] )
			f.write( "ansible_ssh_user=\"%s\"\n" % accountid )
			f.write( "privatekeyfile=\"%s\"\n" % paradata['cloud'][cloudno]['privatekeyfile'] )
			f.write( "private_key_name=\"%s\"\n" % sfjuser)

		f.write( "\n" )

		f.write( "network0=\"%s\"\n" % paradata['network']['0']['network'] )
		f.write( "netmask0=\"%d\"\n" % int(paradata['network']['0']['netmask']) )

		f.write( "\n" )

		for hostno in paradata['hosts']:
			no = int(hostno) + 1
			f.write( "hostname=\"%s\"\n" % paradata['hosts'][hostno]['hostname'] )
			f.write( "instance_type%d=\"%s\"\n" % (no,paradata['hosts'][hostno]['vmtype']) )
			f.write( "hostip%d=\"%s\"\n" % (no,paradata['hosts'][hostno]['hostip']) )
			f.write( "amitype%d=\"%s\"\n" % (no,paradata['hosts'][hostno]['ostype']) )
			f.write( "\n" )

		f.close()

		# pem ファイルのコピー
		shutil.copy(pemfile, varsdir)
		uid = pwd.getpwnam(user).pw_uid
		gid = grp.getgrnam(user).gr_gid
		os.chown(gitpemfile, uid, gid)
		os.chmod(gitpemfile,0600)

		# vpcnet.tf ファイルのコピー
		f = open(vpcnetfile, "r")
		vpcfiledata = f.read()
		f.close()

		tagname="%s" % ( sysname )
		vpcdata = vpcfiledata.replace("SFJTAGS",tagname)

		dirs, files = os.path.split(vpcnetfile)
		vpcfile="%s/%s" % (varsdir,files)
		f = open(vpcfile, "w")
		f.write(vpcdata)
		f.close()

		# acl.tf ファイルのコピー
		f = open(aclfile, "r")
		aclfiledata = f.read()
		f.close()

		tagname="%s" % ( sysname )
		acldata = aclfiledata.replace("SFJTAGS",tagname)

		dirs, files = os.path.split(aclfile)
		aclnewfile="%s/%s" % (varsdir,files)
		f = open(aclnewfile, "w")
		f.write(acldata)
		f.close()

		# hostN.tf ファイルのコピーと作成
		f = open(hostsfile, "r")
		hostsfiledata = f.read()
		f.close()
		f = open(eipfile, "r")
		eipdfileata = f.read()
		f.close()
		for hostno in paradata['hosts']:
			no = int(hostno) + 1
			# SFJPARAをnoに置換
			hostsdata = hostsfiledata.replace("SFJPARA",str(no))
			tagname="%s" % ( sysname )
			hostsdata = hostsdata.replace("SFJTAGS",tagname)
			tagname="%s-%s" % ( sysname, paradata['hosts'][hostno]['hostname'] )
			hostsdata = hostsdata.replace("SFJTAGHOST",tagname)

			hostfile="%s/host%d.tf" % (varsdir,no)
			f = open(hostfile, "w")
			f.write(hostsdata)

			eipflag=paradata['hosts'][hostno]['gip'].encode('utf-8')
			if eipflag == '有' :
				tagname="%s" % ( sysname )
				eipdata = eipdfileata.replace("SFJPARA",str(no))
				eipdata = eipdata.replace("SFJTAGS",tagname)
				f.write(eipdata)

			f.close()

		sshdir="%s/.ssh" % (homedir)
		if os.path.exists(sshdir) is False:
			os.makedirs(sshdir)

		sfile="%s/config" % (sshdir)
		sf = open(sfile, 'w')

		gwname=paradata['hosts']['0']['hostname'].encode('utf-8')
		for hostno in paradata['hosts']:
			if paradata['hosts'][hostno]['role'].encode('utf-8') == "踏み台":
				gwname=paradata['hosts'][hostno]['hostname'].encode('utf-8')

		sf.write("host %s\n" % gwname)
		sf.write("   HostName PUBIP\n")
		sf.write("   User %s\n" % accountid )
		sf.write("   StrictHostKeyChecking no\n")
		sf.write("   IdentityFile %s\n" % gitpemfile )
		sf.write("\n" )

		for hostno in paradata['hosts']:
			sf.write("Host %s-%s\n" % (sysname,paradata['hosts'][hostno]['hostname']) )
			sf.write("   HostName %s\n" % paradata['hosts'][hostno]['hostip'] )
			sf.write("   User %s\n" % accountid )
			sf.write("   StrictHostKeyChecking no\n")
			sf.write("   IdentityFile %s\n" % gitpemfile )
			sf.write("   ProxyCommand ssh -W %%h:%%p %s\n" % gwname)
			sf.write("\n" )

		sf.close()

		# hostsとymlファイルの作成
		for hostno in paradata['hosts']:
			monflag=0

			# ymlファイルの作成
			yfile="%s/%s/%s-%s.yml" % (gitrepodir,sysname,sysname,paradata['hosts'][hostno]['hostname'])
			yf = open(yfile, 'w')

			yf.write("- hosts: appl-%s\n" % paradata['hosts'][hostno]['hostname'])
			yf.write("  become: yes\n")
			yf.write("  roles:\n")

			for applno in appdata['rolelist']:
				appl=appdata['rolelist'][applno]['appname'].encode('utf-8')
				roleinfo=appdata['rolelist'][applno]['roleinfo'].encode('utf-8')
				monitor=paradata['hosts'][hostno]['monitorname']

				if monitor != '' and appl == 'ZabbixAgent' :
					yf.write("    - role: %s\n" % roleinfo )
					monflag=1

				elif roleinfo != '' :
					item=paradata['hosts'][hostno].get(appl,"None")

					if item != 'None' :
						item=item.encode('utf-8')

						if item == '有' :
							yf.write("    - role: %s\n" % roleinfo )

			yf.write("\n" )

			if monflag == 1:
				yf.write("- hosts: appl-zbx\n")
				yf.write("  connection: local\n")
				yf.write("  become: yes\n")
				yf.write("  roles:\n")
				yf.write("    - role: RgistAgent\n")
				yf.write("\n" )

			yf.close()

			# hostsファイルの作成
			hfile="%s/%s/%s-%s.host" % (gitrepodir,sysname,sysname,paradata['hosts'][hostno]['hostname'])
			hf = open(hfile, 'w')

			hf.write("[appl-%s]\n" % paradata['hosts'][hostno]['hostname'])
			hf.write("%s-%s\n" % (sysname,paradata['hosts'][hostno]['hostname']) )
			hf.write("\n")
			hf.write("[appl-%s:vars]\n" % paradata['hosts'][hostno]['hostname'])
			hf.write("ansible_ssh_user=%s\n" % paradata['cloud']['0']['accountid'])
			hf.write("ansible_ssh_private_key_file=%s\n" % gitpemfile )
			hf.write("ansible_server_ip=%s\n" % zbxserv )
			hf.write("\n")

			if monflag == 1:
				hf.write("[appl-zbx]\n")
				hf.write("localhost\n")
				hf.write("\n")

			hf.close()

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
