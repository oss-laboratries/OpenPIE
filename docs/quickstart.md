
![logo](../images/opie_logo.png?raw=true "opie_logo")

2016/9/1 初版
# 使用方法 

- Liferayサーバー
  - ポータル：https://Liferayサーバー:8080
    - ユーザー：test@liferay.com
    - パスワード：test
  - データベース：MariaDB, lportal
    - ユーザー：liferay
    - パスワード：liferay

- 以下の各設定内容は、Liferayサーバーの`/opt/liferay/config/portlet_config'で設定

- Gitlabサーバー
  - システム監視：Zabbix http://Gitlabサーバー/zabbix
      - ユーザー：Admin
      - パスワード：zabbix
    - データベース：PostgreSQL, zabbix
      - ユーザー：zabbix
      - パスワード：zabbix
  - 構成管理：CMDBuild http://Gitlabサーバー:8099
      - ユーザー：admin
      - パスワード：admin
    - データベース：PostgreSQL, cmdbuild
      - ユーザー：postgres
      - パスワード：postgres
  - インベントリ管理：Open-Audit http://Gitlabサーバー:88/open-audit
      - ユーザー：admin
      - パスワード：password
    - データベース：MySQL, openaudit
      - ユーザー：openaudit
      - パスワード：openauditpassword
  - 実行管理：JobScheduler http://Gitlabサーバー:4444
    - データベース：PostgreSQL, scheduler
      - ユーザー：scheduler
      - パスワード：scheduler
  - バージョン管理：Gitlab http://Gitlabサーバー
      - ユーザー：root
      - パスワード：password
    - データベース：PostgreSQL, gitlabhq_production
      - ユーザー：gitlab
      - パスワード：gitlab
  - プロビジョニング：Terraform
      - コマンド：`/usr/local/sbin/tf/terraform`
  - アプリケーションインストール/コマンド実行：Ansible
      - コマンド：
      ```
      # ansible --version
      ansible 2.1.1.0
      config file = /etc/ansible/ansible.cfg
      configured module search path = Default w/o overrides
      ```

# プロビジョニング

## 本バージョンでは、AWSのグローバルIP有りインスタンスのみサポートとなっています。

1. 設定シートを用意

/sfj/etc/sfj/ParamaterSeet_sample.xlsx
をPCにダウンロードし下記項目を入力する

|ファイル名|任意|
|---|---|
|プロジェクト名|任意|
|プラットフォーム|AWS|（現状AWSのみ）		
|ログインID|AWSログインユーザー名を入力|
|AWSリージョン|リージョンコードを入力 |
|アクセスキー|AWSアクセスキーを入力|
|シークレットキー|AWSシークレットキーを入力|
|プライベートキー|AWSプライベートキーファイル名を入力|
|OSタイプ|使用しているAWS環境でアクセスできるAMI idを入力|
|グローバルIP有無|有（現状有のみサポート）|
|役割|「踏み台」と入力するか、空白の場合はグローバルIPが設定された一番左側のインスタンスが踏み台となる|

1. AWSプライベートキーファイル(pemファイル)の配置

   予め作成しておいたpemファイルを、ftpなどでGitlabサーバーの`/etc/sfj`ディレクトリに配置する

1. アップロード

   Lifrayのポータルにログインし、Uploadポートレットを開く

   ファイルを選択ボタンをクリックし、保存した設定シートを選択、アップロードをクリックする

1. プロジェクトを確認

   Lifrayのポータルから、Projectポートレットを開く
   
   更新ボタンをクリックし、設置シートで指定したプロジェクトが表示され、Gitlabポートレットで内容が表示されることを確認する

1. インスタンスの作成

   Lifrayのポータルから、Projectポートレットを開く
   作成するプロジェクトを選択し、Applyをクリック
   AWSコンソールにログインし、指定したインスタンスが作成されていることを確認する

1. インスタンスへのsshログインと踏み台

   AWSインスタンスへのsshログインは、Gitlabサーバーからホスト名でログインできるように構成されます（/home/sfjuser/.ssh/config）
   Gitlabサーバーから、`# ssh プロジェクト名-ホスト名`だけで、グローバルIPが設定されていないインスタンスにも、自動的に踏み台サーバーを経由してsshログインができます。

1. インスタンスの削除

   Lifrayのポータルから、Projectポートレットを開く
   作成するプロジェクトを選択し、Destroyをクリック
   AWSコンソールにログインし、指定したインスタンスが削除されていることを確認する
   AWSコンソールから手動削除する場合は、EC2インスタンス、ElasticIP、ボリューム、VPCの削除が必要です