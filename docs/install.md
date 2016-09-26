
![logo](../images/opie_logo.png?raw=true "opie_logo")

2016/9/1 初版
# インストール手順 

本手順は、OpenPIEの機能確認を目的とした検証環境の構築の手順です。
実業務では使用しないで下さい。

# 動作要件
- ソフトウェア
   - CentOS/RHEL 6/7
   - Oracle JDK 1.8<
   - Tomcat 6/7
   - MySQL/MariaDB 5.5<, PostgreSQL 8.3<
- 最低リソース (全ソフトウェアを１サーバーにインストールする場合）
   - 4 core CPU
   - 8GB メモリー
   - 20GB ディスク空容量
# インストール方法
本手順では、下記の２つのサーバーに分けて、それぞれインストールを実行します
   - Liferayサーバー
      - ポータル：[Liferay](https://web.liferay.com/ja/community/welcome/dashboard)
   - Gitlabサーバー
      - システム監視：[Zabbix](http://www.zabbix.com/jp/)
      - 構成管理：[CMDBuild](http://www.cmdbuild.org/en)
      - インベントリ管理：[Open-Audit](http://www.open-audit.org/)
      - 実行管理：[JobScheduler](http://www.sos-berlin.com/jobscheduler)
      - バージョン管理：[Gitlab](https://about.gitlab.com/)
      - プロビジョニング：[Terraform](https://www.terraform.io/)
      - アプリケーションインストール/コマンド実行：[Ansible](https://www.ansible.com/)
## Liferayサーバー
### インストール環境
- OS:CentOS Linux release 7.2.1511 (Core) minimalインストール
- JAVA：java version "1.8.0_101"
- MariaDB：Ver 15.1
- Liferay:6.2.0
- Liferayインストールディレクトリ：/opt/liferay
- ポートレットConfigディレクトリ：/opt/liferay/config
- ※SELinuxはdisabled、iptablesは停止されていること


１．初期設定

```
# yum groupinstall "Base"
# yum install expect
# yum update
```
２．javaのインストール
下記からOracleJDK1.8をダウンロード
http://www.oracle.com/technetwork/java/javase/downloads/index.html
```
# rpm -ivh jdk-8u101-linux-x64.rpm
# java -version
java version "1.8.0_101"
Java(TM) SE Runtime Environment (build 1.8.0_101-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.101-b13, mixed mode)
```
３．MariaDBのインストール
```
# yum install mariadb-server
# systemctl enable mariadb.service
# systemctl start mariadb.service
```
・MariaDBの初期設定
```
# mysql_secure_installation
※rootパスワードを設定（パスワード：password）、それ以外は「Enter」キーを押す
```
４．Liferayのインストール

下記からLiferayの必要パッケージダウンロード
https://www.liferay.com/ja/downloads
liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip

・Liferayのインストール
```
# unzip liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip
# mv liferay-portal-6.2-ce-ga6/ /opt/liferay
```

・DBをMariaDBに変更
```
# vim /opt/liferay/portal-ext.properties 
```
以下を設定
```
jdbc.default.driverClassName=com.mysql.jdbc.Driver
jdbc.default.url=jdbc:mysql://localhost:3306/lportal?useUnicode=true&characterEncoding=UTF-8&useFastDateParsing=false
jdbc.default.username=root
jdbc.default.password=password
```
・データベースの作成
```
# mysql -uroot -ppassword
> create database lportal default character set 'utf8';
> grant all privileges on lportal.* to liferay identified by 'liferay';
> quit
```
・タイムゾーンの変更
```
# vim /opt/liferay/tomcat-7.0.62/bin/setenv.sh 
```
以下を修正する
```
-Duser.timezone=GMT
↓
-Duser.timezone=Asia/Tokyo
```
・Liferayの起動
```
# /opt/liferay/tomcat-7.0.62/bin/startup.sh
```

６．ポートレットのインポート

・ディレクトリ、Configファイルの作成
```
# mkdir /opt/liferay/config
# mkdir /opt/liferay/file
# vim /opt/liferay/config/portlet_config
```
※以下のように各サーバ、ユーザ情報を記載する
```
#Set GitLab
#GitLabサーバのURL、ログインユーザ、PrivateTokenを設定する
#PrivateTokenはGitLabのWebUIにログイン後、以下にて確認することができる
#画面右上のアカウントアイコンをクリック＞Profile Settings＞Account
GitURL=http://192.168.100.127
PrivateToken=YjQijA62fSzyYBxazX6j
GitUser=root

#Set Liferay tomcat path
#Liferayをインストールした場所（tomcatのディレクトリ）を設定する
Liferay_Tomcat_Path=/opt/liferay/tomcat-7.0.62

#Set File upload server
#ファイルをアップロードするサーバを設定する
#FLUser、FLPasswordにはアップロードサーバにログインする際に使用する
#ユーザ情報を設定する、FLUploadpathは、「Gitサーバインストール手順」の
#初期設定にて作成したディレクトリを指定
FLServer=192.168.100.127
FLUser=root
FLPassword=P@ssword
FLUploadpath=/var/sfj/upload

#Set Zabbix server
#ZabbixサーバのURL、ログイン情報を設定する
#Zabbiサーバのポート番号は、「Gitサーバインストール手順」の
#Zabbixインストールにて設定したものを指定
ZabbixURL=http://192.168.100.127:88/zabbix
ZabbixUser=Admin
ZabbixPassword=zabbix

#Set CMDBuild server
#CMDBuildのURL,ログイン情報を設定する
#Zabbiサーバのポート番号は、「Gitサーバインストール手順」の
#CMDBuildインストールにて設定したものを指定
CMDBuildURL=http://192.168.100.127:8099
CMDBUser=admin
CMDBPassword=admin

#Set JobScheduler
#JobSchedulerのURLを設定する
JobSchedulerURL=http://192.168.100.127:4444
```

・ポートレットのインポート
「GitLab-portlet」、「Projects-portlet」、「Upload-portlet」、
「cmdb-portlet」、「zabbix-portlet」を以下のディレクトリに格納する
```
# mv GitLab-portlet /opt/liferay/tomcat-7.0.62/webapps/
# mv Projects-portlet /opt/liferay/tomcat-7.0.62/webapps/
# mv Upload-portlet /opt/liferay/tomcat-7.0.62/webapps/
# mv cmdb-portlet /opt/liferay/tomcat-7.0.62/webapps/
# mv zabbix-portlet /opt/liferay/tomcat-7.0.62/webapps/
```


## Gitlabサーバー
### サーバインストール環境

- OS:CentOS Linux release 7.2.1511 (Core) minimalインストール
- JAVA：java version "1.8.0_101"
- postgresql:9.4.9
- CMDBuild：2.4.1
- Zabbix：3.0.4
- JobScheduler：1.10.4
- Ansible：2.1.1.0
- OpenAudit：1.12.8
- Terraform:0.7.1

※SELinuxはdisabled、iptablesは停止されていること
　本サーバにGitlab、Zabbix、CMDBuild、JobSchedulerをインストールする

１．初期設定
```
# yum groupinstall "Base"
# yum update
# mkdir -p /var/sfj/upload/
```
※ファイルアップロード先ディレクトリの作成

「sfj/etc/sfj」を以下のディレクトリに移動する
```
# mv sfj/etc/sfj /etc/
```

移動したファイルに実行権を追加する
```
# chmod +x /etc/sfj/SFJ_config.xlsx
# chmod +x /etc/sfj/acl.tf
# chmod +x /etc/sfj/sfjconf.sh
# chmod +x /etc/sfj/hostSFJPARA.tf.template
# chmod +x /etc/sfj/vpcnet.tf  
```
２．javaのインストール
下記からOracleJDK1.8をダウンロード
http://www.oracle.com/technetwork/java/javase/downloads/index.html
```
# rpm -ivh jdk-8u101-linux-x64.rpm
# java -version
java version "1.8.0_101"
Java(TM) SE Runtime Environment (build 1.8.0_101-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.101-b13, mixed mode)
```
３．GitLabのインストール
```
# curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash 
# yum install gitlab-ce
# chmod 600 /etc/gitlab/gitlab.rb 
# vi /etc/gitlab/gitlab.rb
# yum install git expect
```
以下を変更
```
# gitlab_rails['time_zone'] = 'UTC'
　↓
 gitlab_rails['time_zone'] = 'Asia/Tokyo'
```
・GitLab起動
```
# gitlab-ctl reconfigure
```
・管理画面での設定

http://＜アドレス＞にてWebUIに接続後、初期アカウントにてログイン後、
パスワードを変更する

初期パスワード
Username: root
Password: 5iveL!fe


４．CMDBuildインストール
- postgres9.4のインストール
```
# rpm -ivh http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-2.noarch.rpm
# yum --disableplugin=priorities install -y postgresql94-server postgresql94-devel
# su - postgres
$ /usr/pgsql-9.4/bin/initdb --encoding=UTF-8 --no-locale -D /var/lib/pgsql/9.4/data/

# /usr/pgsql-9.4/bin/postgresql94-setup initdb
# vim /var/lib/pgsql/9.4/data/pg_hba.conf
```
下記のように修正
```
# "local" is for Unix domain socket connections only
local   all             all                                     trust  # <- 変更
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust  # <- 変更
# IPv6 local connections:
host    all             all             ::1/128                 trust  # <- 変更
```
Postgresを再起動し、自動起動設定にする
```
# systemctl start postgresql-9.4
# systemctl enable postgresql-9.4
```

- Tomcatのインストール
```
# curl -OL http://ftp.riken.jp/net/apache/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz
# tar zxvf apache-tomcat-8.0.33.tar.gz 
# mv apache-tomcat-8.0.33 /opt/tomcat
# useradd -M -d /opt/tomcat tomcat 
```
- Tomcatの設定
```
# vi /opt/tomcat/bin/setenv.sh
```
※以下を設定
```
JAVA_HOME=/usr/java/default
JAVA_OPTS="-Dfile.encoding=UTF-8 -Xms256m -Xmx1024m -XX:MaxPermSize=256M -server"
LANG="ja_JP.UTF-8"

# vi /usr/lib/systemd/system/tomcat.service
※以下を設定

[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
```

```
# vim /opt/tomcat/conf/server.xml 
```
・ポート番号の変更（任意のポート番号に変更する）
```
<Connector port="8080" protocol="HTTP/1.1"
↓
<Connector port="8099" protocol="HTTP/1.1"
```
Tomcatを再起動し、自動起動設定にする
```
# systemctl daemon-reload
# systemctl enable tomcat.service
```

- Postgres9.4/jdk8用jdbcdriver インストール
```
# curl -OL https://jdbc.postgresql.org/download/postgresql-9.4.1209.jar
# mv postgresql-9.4.1209.jar /opt/tomcat/lib/
# chown -R tomcat. /opt/tomcat
# systemctl start tomcat.service
```
- cmdbuildのインストール
```
# curl -L -o  cmdbuild-2.4.1.zip https://sourceforge.net/projects/cmdbuild/files/2.4.1/cmdbuild-2.4.1.zip/download
# unzip cmdbuild-2.4.1.zip 
# cd cmdbuild-2.4.1/
# cp cmdbuild-2.4.1.war /opt/tomcat/webapps/cmdbuild.war
```
http://IPアドレス:8099/cmdbuild
にアクセスするとGUI設定画面が開始するので、まず言語を選択し次へをクリック
データベース設定を入力、タイプを「デモ」とするとデモ用データが設定される
 デフォルトのデータベース接続のユーザ／パスワードは、postgres/postgres
OKをクリックし
 デフォルトの管理者情報、admin/adminでログイン


５．sharkインストール
```
# curl -OL https://sourceforge.net/projects/cmdbuild/files/2.4.1/shark-cmdbuild-2.4.1.zip
# unzip shark-cmdbuild-2.4.1.zip
# cp shark-cmdbuild-2.4.1/cmdbuild-shark-server-2.4.1.war /opt/tomcat/webapps/shark.war
# vi /opt/tomcat/webapps/shark/META-INF/context.xml
```
※以下を修正
```
url="jdbc:postgresql://localhost/cmdbuild"
```
```
# vi /opt/tomcat/webapps/cmdbuild/WEB-INF/conf/auth.conf
```
※以下を設定
```
serviceusers.privileged=workflow
```
```
# systemctl restart tomcat
```

- ワークフローの設定
アドミニストレーションモジュール > 一般オプション > ワークフローを選択し
有効、Enable "Add attachment" on closed activities、Disable syncronizaton of missing variablesにチェック、
ユーザー名／パスワードに、shark/sharkを入力し、保存をクリック


６．Alfrescoインストール
- DBの作成
```
# su - postgres
$ createdb -U postgres --encoding=UTF-8 alfresco
```
- 依存パッケージのインストール
```
# yum install -y fontconfig libSM libICE libXrender libXextlibcups libGLU
```
- 以下からファイルをダウンロードし実行する
http://osdn.jp/projects/sfnet_alfresco/downloads/Alfresco%20201606-EA%20Community/alfresco-community-installer-201606-EA-linux-x64.bin/
```
# chmod +x alfresco-community-installer-201606-EA-linux-x64.bin
# ./alfresco-community-installer-201606-EA-linux-x64.bin ¥
--unattendedmodeui none --mode unattended ¥
--enable-components libreofficecomponent,alfrescosolr,alfrescosolr4,aosmodule,alfrescowcmqs,alfrescogoogledocs ¥
--disable-components javaalfresco,postgres ¥
--installer-language ja ¥
--jdbc_username postgres --jdbc_password postgres ¥
--tomcat_server_port 10080 --tomcat_server_shutdown_port 10005 ¥
--tomcat_server_ajp_port 10009 --alfresco_ftp_port 1121 ¥
--alfresco_admin_password admin ¥
--alfrescocustomstack_services_startup demand
```
- Postgres9.4用jdbcdriverをコピーし、Alfrescoを起動
```
# cp /opt/tomcat/lib/postgresql-9.4.1208.jar /opt/alfresco-community/tomcat/lib/
# service alfresco restart
```
７．Zabbixインストール
- zabbixサーバのインストール
```
# rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm 
# yum install zabbix-web-pgsql zabbix-agent zabbix-server-pgsql zabbix-web
```
- ポート番号の変更（任意のポート番号に変更する）
```
# vim /etc/httpd/conf/httpd.conf
```
※以下を変更する
```
Listen 80
↓
Listen 88
```
- DBの作成
```
# su - postgres
$ createuser zabbix -P -S -R -D
※パスワード：zabbix
$ createdb -O zabbix -E UTF8 zabbix
$ exit
# zcat /usr/share/doc/zabbix-server-pgsql-3.0.4/create.sql.gz | psql -U zabbix zabbix -W
```
- 設定ファイルの修正
```
# vim /etc/zabbix/zabbix_server.conf
```
※以下を修正する
```
# DBHost=localhost
↓
DBHost=localhost
 
# DBPassword=
↓
DBPassword=zabbix
```
```
# vim /etc/zabbix/zabbix_agentd.conf 
```
※以下を修正する
```
#Server=127.0.0.1
↓
Server=192.168.100.127
```
```
# vim /etc/httpd/conf.d/zabbix.conf
```
※以下を修正する
```
 # php_value date.timezone Europe/Riga
↓
php_value date.timezone Asia/Tokyo 
```


- 起動
```
# systemctl start zabbix-server
# systemctl start zabbix-agent
# systemctl start httpd
# systemctl enable zabbix-server
# systemctl enable zabbix-agent
# systemctl enable httpd
```


８．JobSchedulerインストール

- 以下のURLからjobscheduler_linux-x64.1.10.4.tar.gzをダウンロードする
http://www.sos-berlin.com/jobscheduler-downloads

- インストールファイルの作成、設定ファイル修正
```
# vim /var/lib/pgsql/9.4/data/postgresql.conf
```
※以下を修正
```
#standard_conforming_strings = on
↓
standard_conforming_strings = off
```
```
# systemctl restart postgresql-9.4.service
# tar zxvf /tmp/jobscheduler_linux-x64.1.10.4.tar.gz 
# chmod +0777 /opt
# useradd sfjuser
# passwd sfjuser
```
```
# vim /tmp/jobscheduler.1.10.4/sfj.xml
```
※以下を設定
```
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<AutomatedInstallation langpack="eng">
<com.izforge.izpack.panels.UserInputPanel id="home">
<userInput/>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="licences">
<userInput>
<entry key="licenceOptions" value="GPL"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.HTMLLicencePanel id="gpl_licence"/>
<com.izforge.izpack.panels.HTMLLicencePanel id="commercial_licence"/>
<com.izforge.izpack.panels.TargetPanel id="target">
<installpath>/opt/sos-berlin.com/jobscheduler</installpath>
</com.izforge.izpack.panels.TargetPanel>
<com.izforge.izpack.panels.UserPathPanel id="userpath">
<UserPathPanelElement>/home/sfjuser/sos-berlin.com/jobscheduler</UserPathPanelElement>
</com.izforge.izpack.panels.UserPathPanel>
<com.izforge.izpack.panels.PacksPanel id="package">
<pack index="0" name="Job Scheduler" selected="true"/>
<pack index="1" name="Database Support" selected="true"/>
<pack index="2" name="Housekeeping Jobs" selected="true"/>
<pack index="3" name="Cron" selected="false"/>
</com.izforge.izpack.panels.PacksPanel>
<com.izforge.izpack.panels.UserInputPanel id="network">
<userInput>
<entry key="schedulerPort" value="4444"/>
<entry key="schedulerAllowedHost" value="0.0.0.0"/>
<entry key="schedulerId" value="SFJ"/>
<entry key="jettyHTTPSPort" value="48444"/>
<entry key="schedulerHost" value="localhost.localdomain"/>
<entry key="jettyHTTPPort" value="40444"/>
<entry key="launchScheduler" value="yes"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="cluster">
<userInput>
<entry key="clusterOptions" value=""/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="smtp">
<userInput>
<entry key="smtpAccount" value=""/>
<entry key="smtpPass" value=""/>
<entry key="mailPort" value="25"/>
<entry key="mailTo" value=""/>
<entry key="mailServer" value="localhost.localdomain"/>
<entry key="mailBcc" value=""/>
<entry key="mailFrom" value="scheduler@localhost.localdomain"/>
<entry key="mailCc" value=""/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="email">
<userInput>
<entry key="jobEvents" value="on"/>
<entry key="mailOnSuccess" value="no"/>
<entry key="mailOnError" value="no"/>
<entry key="mailOnWarning" value="no"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="update">
<userInput/>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="database">
<userInput>
<entry key="databaseDbms" value="pgsql"/>
<entry key="databaseCreate" value="on"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="dbconnection">
<userInput>
<entry key="databaseSchema" value="scheduler"/>
<entry key="databaseUser" value="scheduler"/>
<entry key="databaseHost" value="localhost"/>
<entry key="databasePassword" value="schedule"/>
<entry key="databasePort" value="5432"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="jdbc">
<userInput/>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="cron">
<userInput/>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.InstallPanel id="install"/>
<com.izforge.izpack.panels.ProcessPanel id="process"/>
<com.izforge.izpack.panels.FinishPanel id="finish"/>
</AutomatedInstallation>
```
```
# chown -R sfjuser.sfjuser /tmp/jobscheduler.1.10.4
```
- DBの作成
```
# su - postgres
$ createuser scheduler -P -S -R -D
※パスワード：scheduler
$ createdb -O scheduler -E UTF8 scheduler
$ exit
```
- JobSchedulerのインストール
```
# cd /tmp/jobscheduler.1.10.4
# sudo -u sfjuser ./setup.sh ./sfj.xml
```
- GUI日本語化設定
```
# vim /home/sfjuser/sos-berlin.com/jobscheduler/sfj/config/operations_gui/custom.js
```
※以下を修正
```
_sos_lang            = '';
↓
_sos_lang            = 'ja';
```

- scheduler.xmlの編集

```
# vim /home/sfjuser/sos-berlin.com/jobscheduler/sfj/config/
```
※以下をconfigセクションへの追加
```

               <config mail_xslt_stylesheet="config/scheduler_mail.xsl" port="4444">
                ・
                ・
                ・

                                <http_server>
                                        <web_service
                                                debug = "no"
                                                request_xslt_stylesheet = "config/scheduler_soap_request.xslt"
                                                response_xslt_stylesheet = "config/scheduler_soap_response.xslt"
                                                name = "scheduler"
                                                url_path = "/scheduler" >
                                        </web_service>
                                </http_server>
                </config>
```
- Jobのインポート
「jos-job/sfj」を以下のディレクトリに格納する
```
# mv jos-job/sfj /home/sfjuser/sos-berlin.com/jobscheduler/sfj/config/live/
```
- オーナ/グループの変更
```
# chown -R sfjuser.sfjuser /home/sfjuser/sos-berlin.com/
```
 - sfjconf.shの修正
```
# vim /etc/sfj/sfjconf.sh
```
※以下の設定を必要に応じ修正
```
#JobScheduler実行ユーザ
export SFJUSER="sfjuser"

#GutLabサーバのホスト
export GITHOST="localhost"
#GitLabサーバのユーザ、パスワード
export GITUSER="root"
export GITPASS="password"
#JobSchedulerのホスト
export JOSHOST="192.168.100.127"
```

- JobSchedulerの再起動
```
# /opt/sos-berlin.com/jobscheduler/sfj/bin/jobscheduler.sh restart
```

９．Ansibleのインストール
```
# yum install epel-release
# yum install python-setuptools python-pip
# yum install --enablerepo=epel-testing ansible
# ansible --version
ansible 2.1.1.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides
# pip install python-gitlab
# pip install zabbix-api 
```
１０．OpenAuditインストール
- 下記ダウンロードサイトから、最新版のLinux用をダウンロードする。
http://www.open-audit.org/downloads.php
```
# yum install perl-core
# chmod +x OAE-Linux-x86_64-release_1.12.8.run
# ./OAE-Linux-x86_64-release_1.12.8.run
```
※インストーラを実行するとMySQL／Apache／PHP等必要なものは自動的にインストールされる。

インストーラーが完了後、ブラウザから下記にアクセスし動作を確認する。
http://IPアドレス:88/open-audit
Username:admin
Password:password


１１．terraformインストール
- 下記ダウンロードサイトから最新版のlinux用をダウンロードする。
https://www.terraform.io/downloads.html

- pythonライブラリインストール
```
# pip install xlwt xlrd xlutils simplejson
```
- terraformのインストール
```
# mkdir /usr/local/sbin/tf 
# mv terraform_0.7.1_linux_amd64.zip /usr/local/sbin/tf
# cd /usr/local/sbin/tf/
# unzip terraform_0.7.1_linux_amd64.zip 
# rm terraform_0.7.1_linux_amd64.zip
# vi ~/.bash_profile
```
以下を修正
```
PATH=$PATH:$HOME/bin
↓
PATH=$PATH:$HOME/bin:/usr/local/sbin/tf
```
```
# source ~/.bash_profile
```
「sfj/usr/local/sbin」を以下のディレクトリに移動する
```
# mv sfj/usr/local/sbin/* /usr/local/sbin/
```
移動したファイルに実行権を追加する
```
# chmod +x /usr/local/sbin/*
```

