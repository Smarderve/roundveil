// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get riddles => 'Riddles';

  @override
  String get memory => 'Memory';

  @override
  String get quickQuiz => 'Quick Quiz';

  @override
  String get quickWordPlay => 'Word Sprint';

  @override
  String get quickCharacter => 'Character Challenge';

  @override
  String get quickRiddles => 'Riddle Session';

  @override
  String get quickMemory => 'Memory Match';

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
}
