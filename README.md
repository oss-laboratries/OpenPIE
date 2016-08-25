![](images/opie_logo.gif?raw=true "opie_logo")
# OpenPIEとは

OpenPIE (Open Programmable Infrastructure Environment)とは、オープンソースのクラウド／データセンター運用自動化基盤です。
ポータル、システム監視、構成管理、ジョブ管理、チケット管理などの様々なツールを組み合わせて、自動連携することを可能にするツールチェーンです。
構成コンポーネントはAPIによる疎結合構造になっていますので、必要な機能だけ選んで使用できます。

対象とするシステムは、VrirtualBox、AWSなどのパブリッククラウドから、オンプレミスのVMware、OpenStack環境まで対応予定です。

OpenPIEの目的は運用自動化そのものではなく、すべてのオペレーション、機器情報や障害対応を記録し、情報共有・分析によるSRE (Site Reliability Engineering)を可能にすることです。

# 機能
- 運用ポータル：Liferayポートレットにより必要な情報が一覧でき、表示情報はユーザー自身でカスタマイズ可能です
- プロビジョニング：Excelで作成した設定シートをアップロードするだけで、自動的にサーバーを作成しアプリケーションをインストール・設定します
- インベントリ収集：管理対象機器から、構成情報を自動収集します
- システム監視：プロビジョニングされたシステムを、自動的に監視開始します
- アラート自動対応 (予定)：システム監視が発報したアラートから自動的にチケットを作成し、予め登録した手順に従い対象システムにログイン・ログ収集・プロセス再起動などを実行します。 

# アーキテクチャ

![概要図](images/opie_architecture.gif?raw=true "opie_architecture")

## 設定シート例

![](images/opie_excel.gif?raw=true "opie_excel")

## 使用ツール

- システム監視：[Zabbix](http://www.zabbix.com/jp/)
- 構成管理：[CMDBuild](http://www.cmdbuild.org/en)
- インベントリ管理：[Open-Audit](http://www.open-audit.org/)
- 実行管理：[JobScheduler](http://www.sos-berlin.com/jobscheduler)
- バージョン管理：[Gitlab](https://about.gitlab.com/)
- サービスデスク (予定)：[Redmine](http://redmine.jp/), [OTRS](https://www.otrs.com/)
- プロビジョニング：[Terraform](https://www.terraform.io/)<!--, [Packer](https://www.packer.io/) -->
- アプリケーションインストール/コマンド実行：[Ansible](https://www.ansible.com/)
- ポータル：[Liferay](https://web.liferay.com/ja/community/welcome/dashboard)

## 対象システム

- VirtualBox
- AWS EC2
- Openstack (予定)
- VMware vSphere (予定)
- Google Cloud Platform (予定)

## コンポーネント

- Liferay ポートレット
   - ファイルアップロード：Excel設定シートをプロジェクトにアップロードします
   - プロジェクト表示：設定シートから生成されたプロジェクトを表示、Apply/Destroyできます
   - Gitlab表示：設定シートから生成されたファイル群のリポジトリを表示します
   - Zabbix表示：生成されたサーバーの監視イベントを表示します
   - CMDB表示：Zabbix表示ポートレットで指定したサーバーの構成情報を表示します
   - ジョブ表示：実行されているジョブを表示します

画面イメージ

![](images/opie_screenshot.gif?raw=true "opie_screenshot")

- ジョブチェーン
   - パラメータ作成：Excel設定シートから、Terraform/Ansibleの設定情報を生成します
   - ファイルモニター：アップロードされるExcel設定シートを検知し、パラメータ作成を実行します
   - アプライ：生成された設定情報をもとにTerraform/Ansibleを実行し、サーバーを作成、アプリケーションをインストール、監視設定、構成情報登録まで行います
   - デストロイ：作成されたサーバーを削除します


## プレゼンテーション

- [OpenPIE紹介資料]()

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
- モジュールを分割して複数サーバーにインストールすることも可能です

# インストール方法

# クイックスタート

# ライセンス

[Apache License　V.2](http://www.apache.org/licenses/)