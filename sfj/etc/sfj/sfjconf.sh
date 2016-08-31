#!/bin/bash

#
export ROOTDIR=""

#
export CONFDIR="${ROOTDIR}/etc/sfj"

#
export BINDIR="${ROOTDIR}/usr/local/sbin"
export TFBINDIR="${BINDIR}/tf"

#
export VARDIR="${ROOTDIR}/var/sfj"
export UPLOADDIR="${VARDIR}/upload"
export GITREPODIR="${VARDIR}/gitrepo"
export WORKDIR="${VARDIR}/work"
export BACKUPDIR="${VARDIR}/backup"

#
export PATH=".:${TFBINDIR}:${PATH}"

#
export SFJCONFIGFILE="${CONFDIR}/SFJ_config.json"

#
export SFJUSER="sfjuser"

#
export GITLABDIR="/var/opt/gitlab/git-data/repositories/root"
export GITHOST="localhost"
export GITUSER="root"
export GITPASS="password"
export GITEMAIL="${GITUSER}@${GITHOST}"
export GITURL="http://${GITUSER}@${GITHOST}/${GITUSER}"

#
export tfcmd="plan"

export vpcnetfile="${CONFDIR}/vpcnet.tf"
export aclfile="${CONFDIR}/acl.tf"
export hostsfile="${CONFDIR}/hostSFJPARA.tf.template"
export sfjpara="sfjpara.tfvars"
#

export JOSHOST="192.168.100.127"

#
