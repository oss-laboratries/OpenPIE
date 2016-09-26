#!/bin/bash

# インストールrootディレクトリ
export ROOTDIR=""

# ディレクトリ情報
export CONFDIR="${ROOTDIR}/etc/sfj"
export BINDIR="${ROOTDIR}/usr/local/sbin"
export TFBINDIR="${BINDIR}/tf"
export VARDIR="${ROOTDIR}/var/sfj"
export UPLOADDIR="${VARDIR}/upload"
export GITREPODIR="${VARDIR}/gitrepo"
export WORKDIR="${VARDIR}/work"
export BACKUPDIR="${VARDIR}/backup"
export PATH=".:${TFBINDIR}:${PATH}"

# コンフィグファイル（変更不可）
export SFJCONFIGFILE="${CONFDIR}/SFJ_config.json"

# インストールユーザ
export SFJUSER="sfjuser"

# GitLab用
export GITLABDIR="/var/opt/gitlab/git-data/repositories/root"
export GITHOST="localhost"
export GITUSER="root"
export GITPASS="password"
export GITEMAIL="${GITUSER}@${GITHOST}"
export GITURL="http://${GITUSER}@${GITHOST}/${GITUSER}"

# terraform用
export tfcmd="plan"
export TF_VAR_tftimeout="15m"

export vpcnetfile="${CONFDIR}/vpcnet.tf"
export aclfile="${CONFDIR}/acl.tf"
export hostsfile="${CONFDIR}/hostSFJPARA.tf.template"
export eipfile="${CONFDIR}/eip.tf"
export sfjpara="sfjpara.tfvars"

# JobScheduler用
export JOSHOST="192.168.100.127"

# ZABBIX用
export ZBXHOST="192.168.100.127"
export ZBXURL="http://${ZBXHOST}:88/zabbix"
export ZBXUSER="Admin"
export ZBXPASS="zabbix"
export ZBXGRP="OpenPIE Servers"
export ZBXTEMPLATE="Template OS Linux"

#
