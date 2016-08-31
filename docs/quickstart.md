
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
  - インベントリ管理：Open-Audit http://Gitlabサーバー/open-audit
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
      - ユーザー：admin
      - パスワード：admin
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
1. 設定シートを用意

/sfj/etc/sfj/ParamaterSeet_sample.xlsx
をPCにダウンロードし下記項目を入力する

|ファイル名|任意|
|:--|:--|
|プロジェクト名|任意|
|:--|:--|
|クラウド名|任意|	
|:--|:--|
|プラットフォーム|AWS|（現状AWSのみ）		
|:--|:--|
|ログインID|AWSログインユーザー名を入力|
|:--|:--|
|アクセスキー|AWSアクセスキーを入力|
|:--|:--|
|シークレットキー|AWSシークレットキーを入力|
|:--|:--|
|プライベートキー|AWSプライベートキーファイル名を入力|
|:--|:--|
|OSタイプ|使用しているAWS環境でアクセスできるAMI idを入力|


pemファイルの場所？

1. アップロード
- Lifrayのポータルにログインし、Uploadポートレットを開く
- ファイルを選択ボタンをクリックし、保存した設定シートを選択、アップロードをクリックする

2. プロジェクトを確認
- Lifrayのポータルから、Projectポートレットを開く
- 更新ボタンをクリックし、設置シートで指定したプロジェクトが表示され、Gitlabポートレットで内容が表示されることを確認する

3. インスタンスの作成
- Lifrayのポータルから、Projectポートレットを開く
- 作成するプロジェクトを選択し、Applyをクリック
- AWSコンソールにログインし、指定したインスタンスが作成されていることを確認する

4. インスタンスの削除
- Lifrayのポータルから、Projectポートレットを開く
- 作成するプロジェクトを選択し、Destroyをクリック
- AWSコンソールにログインし、指定したインスタンスが削除されていることを確認する