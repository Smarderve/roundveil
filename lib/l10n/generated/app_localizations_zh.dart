// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => 'Home';

  @override
  String get navCreate => 'Create Game';

  @override
  String get navQuick => 'Quick Game';

  @override
  String get navDrafts => 'Saved Drafts';

  @override
  String get navLibrary => 'Game Modes';

  @override
  String get navSettings => 'Settings';

  @override
  String get welcomeEyebrow => 'YOUR NEXT GAME NIGHT STARTS HERE';

  @override
  String get welcomeTitle => 'Bring everyone\nto the table.';

  @override
  String get welcomeBody =>
      'Choose a game, shape the session, and let ROUNDVEIL host the moment.';

  @override
  String get createGame => 'Create Game';

  @override
  String get quickGame => 'Quick Game';

  @override
  String get savedDrafts => 'Saved Drafts';

  @override
  String get gameModes => 'Explore game modes';

  @override
  String get singleGame => 'Single Game';

  @override
  String get mixedGame => 'Mixed Game';

  @override
  String get selectGames => 'Choose your games';

  @override
  String get players => 'Players';

  @override
  String get addPlayer => 'Add player';

  @override
  String get removePlayer => 'Remove player';

  @override
  String get rounds => 'Rounds';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get startSession => 'Create session';

  @override
  String get editConfiguration => 'Edit configuration';

  @override
  String get draftSaved => 'Draft saved on this device.';

  @override
  String get noDrafts => 'Your saved sessions will appear here.';

  @override
  String get chooseOneGame => 'Choose one game to continue.';

  @override
  String get chooseTwoGames => 'Choose at least two games for a mixed session.';

  @override
  String get choosePlayer => 'Add at least one player to continue.';

  @override
  String get sessionCreated => 'Session configuration created.';

  @override
  String get sessionReadyTitle => 'Your session is assembled';

  @override
  String get sessionReadyBody =>
      'The configuration is saved. Gameplay launches only for modules that are currently implemented.';

  @override
  String get playablePrototype => 'Playable prototype';

  @override
  String get inFoundation => 'Foundation in progress';

  @override
  String get notPlayable => 'Gameplay not connected yet';

  @override
  String get guessCountry => 'Guess the Country';

  @override
  String get quiz => 'Quiz';

  @override
  String get wordPlay => 'Word Play';

  @override
  String get guessCharacter => 'Guess the Character';

  @override
  String get quickQuiz => 'Quick Quiz';

  @override
  String get quickWordPlay => 'Word Sprint';

  @override
  String get quickCharacter => 'Character Challenge';

  @override
  String get quickFlags => 'Flag Challenge';

  @override
  String get quickPartyMix => 'Party Mix';

  @override
  String get working => 'Set up your session';

  @override
  String get localOffline => 'Your sessions stay on this device';

  @override
  String get themeDark => 'Dark theme';

  @override
  String get themeLight => 'Light theme';

  @override
  String get language => 'Language';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get quickTemplates => 'Start from a template';

  @override
  String get templateDescription =>
      'Every template is editable before you create a session.';

  @override
  String get sessionName => 'Session name';

  @override
  String draftCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved drafts',
      one: '1 saved draft',
      zero: 'No saved drafts',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Main menu';

  @override
  String get appearance => 'Appearance';

  @override
  String get languageNote => 'ROUNDVEIL interface language';

  @override
  String get sessionTitle => 'Session overview';

  @override
  String get editPlayers => 'Edit players';

  @override
  String get createAnother => 'Create another session';

  @override
  String get moduleOnlyCountry =>
      'This is the only connected playable prototype today.';

  @override
  String get selected => 'Selected';

  @override
  String get notSelected => 'Not selected';

  @override
  String get ready => 'Ready to create';

  @override
  String get incomplete => 'Finish the required choices';

  @override
  String get rebuildStatus => 'The broader multi-game rebuild is in progress.';

  @override
  String get draftNeedsEditing => '此草稿包含已停用的游戏。请先编辑再使用。';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => '主页';

  @override
  String get navCreate => '创建游戏';

  @override
  String get navQuick => '快速游戏';

  @override
  String get navDrafts => '已保存草稿';

  @override
  String get navLibrary => '游戏模式';

  @override
  String get navSettings => '设置';

  @override
  String get welcomeEyebrow => '下一场游戏之夜，从这里开始';

  @override
  String get welcomeTitle => '让大家\n围坐一堂。';

  @override
  String get welcomeBody => '选择游戏、设置对局，让 ROUNDVEIL 主持精彩时刻。';

  @override
  String get createGame => '创建游戏';

  @override
  String get quickGame => '快速游戏';

  @override
  String get savedDrafts => '已保存草稿';

  @override
  String get gameModes => '探索游戏模式';

  @override
  String get singleGame => '单款游戏';

  @override
  String get mixedGame => '混合游戏';

  @override
  String get selectGames => '选择游戏';

  @override
  String get players => '玩家';

  @override
  String get addPlayer => '添加玩家';

  @override
  String get removePlayer => '移除玩家';

  @override
  String get rounds => '回合';

  @override
  String get saveDraft => '保存草稿';

  @override
  String get startSession => '创建对局';

  @override
  String get editConfiguration => '编辑设置';

  @override
  String get draftSaved => '草稿已保存在此设备。';

  @override
  String get noDrafts => '已保存的对局会显示在这里。';

  @override
  String get chooseOneGame => '请选择一款游戏以继续。';

  @override
  String get chooseTwoGames => '混合对局至少选择两款游戏。';

  @override
  String get choosePlayer => '至少添加一位玩家以继续。';

  @override
  String get sessionCreated => '对局设置已创建。';

  @override
  String get sessionReadyTitle => '对局已组建';

  @override
  String get sessionReadyBody => '设置已保存。只有已实现的模式可以启动游戏。';

  @override
  String get playablePrototype => '可玩的原型';

  @override
  String get inFoundation => '基础建设中';

  @override
  String get notPlayable => '游戏尚未接入';

  @override
  String get guessCountry => '猜国家';

  @override
  String get quiz => '问答';

  @override
  String get wordPlay => '文字游戏';

  @override
  String get guessCharacter => '猜角色';

  @override
  String get quickQuiz => '快速问答';

  @override
  String get quickWordPlay => '文字冲刺';

  @override
  String get quickCharacter => '角色挑战';

  @override
  String get quickFlags => '旗帜挑战';

  @override
  String get quickPartyMix => '派对混合';

  @override
  String get working => '设置对局';

  @override
  String get localOffline => '对局数据保存在此设备';

  @override
  String get themeDark => '深色主题';

  @override
  String get themeLight => '浅色主题';

  @override
  String get language => '语言';

  @override
  String get back => '返回';

  @override
  String get close => '关闭';

  @override
  String get delete => '删除';

  @override
  String get duplicate => '复制';

  @override
  String get quickTemplates => '从模板开始';

  @override
  String get templateDescription => '创建对局前可编辑每个模板。';

  @override
  String get sessionName => '对局名称';

  @override
  String draftCount(num count) {
    return '已保存草稿 $count 个';
  }

  @override
  String get menu => '主菜单';

  @override
  String get appearance => '外观';

  @override
  String get languageNote => 'ROUNDVEIL 界面语言';

  @override
  String get sessionTitle => '对局概览';

  @override
  String get editPlayers => '编辑玩家';

  @override
  String get createAnother => '创建另一场对局';

  @override
  String get moduleOnlyCountry => '目前只有此游戏原型可以游玩。';

  @override
  String get selected => '已选择';

  @override
  String get notSelected => '未选择';

  @override
  String get ready => '可以创建';

  @override
  String get incomplete => '请完成必选项';

  @override
  String get rebuildStatus => '其他游戏正在开发中。';

  @override
  String get draftNeedsEditing => '此草稿包含已停用的游戏。请先编辑再使用。';
}
