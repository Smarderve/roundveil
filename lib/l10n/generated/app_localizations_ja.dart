// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => 'ホーム';

  @override
  String get navCreate => 'ゲームを作成';

  @override
  String get navQuick => 'クイックゲーム';

  @override
  String get navDrafts => '保存した下書き';

  @override
  String get navLibrary => 'ゲームモード';

  @override
  String get navSettings => '設定';

  @override
  String get welcomeEyebrow => '次のゲームナイトはここから';

  @override
  String get welcomeTitle => 'みんなで\nテーブルを囲もう。';

  @override
  String get welcomeBody => 'ゲームを選んでセッションを準備。ROUNDVEILが進行をサポートします。';

  @override
  String get createGame => 'ゲームを作成';

  @override
  String get quickGame => 'クイックゲーム';

  @override
  String get savedDrafts => '保存した下書き';

  @override
  String get gameModes => 'ゲームモードを見る';

  @override
  String get singleGame => 'シングルゲーム';

  @override
  String get mixedGame => 'ミックスゲーム';

  @override
  String get selectGames => 'ゲームを選択';

  @override
  String get players => 'プレイヤー';

  @override
  String get addPlayer => 'プレイヤーを追加';

  @override
  String get removePlayer => 'プレイヤーを削除';

  @override
  String get rounds => 'ラウンド';

  @override
  String get saveDraft => '下書きを保存';

  @override
  String get startSession => 'セッションを作成';

  @override
  String get editConfiguration => '設定を編集';

  @override
  String get draftSaved => '下書きをこの端末に保存しました。';

  @override
  String get noDrafts => '保存したセッションがここに表示されます。';

  @override
  String get chooseOneGame => '続行するにはゲームを1つ選択してください。';

  @override
  String get chooseTwoGames => 'ミックスセッションには2つ以上選択してください。';

  @override
  String get choosePlayer => '続行するにはプレイヤーを1人以上追加してください。';

  @override
  String get sessionCreated => 'セッション設定を作成しました。';

  @override
  String get sessionReadyTitle => 'セッションの準備ができました';

  @override
  String get sessionReadyBody => '設定を保存しました。実装済みのモードのみプレイを開始できます。';

  @override
  String get playablePrototype => 'プレイ可能なプロトタイプ';

  @override
  String get inFoundation => '基盤を構築中';

  @override
  String get notPlayable => 'ゲーム未接続';

  @override
  String get guessCountry => '国を当てよう';

  @override
  String get quiz => 'クイズ';

  @override
  String get wordPlay => 'ワードゲーム';

  @override
  String get guessCharacter => 'キャラクター当て';

  @override
  String get quickQuiz => 'クイッククイズ';

  @override
  String get quickWordPlay => 'ワードスプリント';

  @override
  String get quickCharacter => 'キャラクターチャレンジ';

  @override
  String get quickFlags => '国旗チャレンジ';

  @override
  String get quickPartyMix => 'パーティーミックス';

  @override
  String get working => 'セッションを準備';

  @override
  String get localOffline => 'セッションはこの端末に保存されます';

  @override
  String get themeDark => 'ダークテーマ';

  @override
  String get themeLight => 'ライトテーマ';

  @override
  String get language => '言語';

  @override
  String get back => '戻る';

  @override
  String get close => '閉じる';

  @override
  String get delete => '削除';

  @override
  String get duplicate => '複製';

  @override
  String get quickTemplates => 'テンプレートから開始';

  @override
  String get templateDescription => 'セッション作成前に各テンプレートを編集できます。';

  @override
  String get sessionName => 'セッション名';

  @override
  String draftCount(num count) {
    return '保存済み下書き $count 件';
  }

  @override
  String get menu => 'メインメニュー';

  @override
  String get appearance => '外観';

  @override
  String get languageNote => 'ROUNDVEILの表示言語';

  @override
  String get sessionTitle => 'セッション概要';

  @override
  String get editPlayers => 'プレイヤーを編集';

  @override
  String get createAnother => '別のセッションを作成';

  @override
  String get moduleOnlyCountry => '現在プレイできるプロトタイプはこれだけです。';

  @override
  String get selected => '選択済み';

  @override
  String get notSelected => '未選択';

  @override
  String get ready => '作成できます';

  @override
  String get incomplete => '必須項目を選択してください';

  @override
  String get rebuildStatus => '他のゲームを開発中です。';

  @override
  String get draftNeedsEditing => 'この下書きには提供終了したゲームが含まれています。使用前に編集してください。';
}
