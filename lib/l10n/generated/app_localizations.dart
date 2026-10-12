import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('sw'),
    Locale('tr'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ROUNDVEIL'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get navCreate;

  /// No description provided for @navQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick Game'**
  String get navQuick;

  /// No description provided for @navDrafts.
  ///
  /// In en, this message translates to:
  /// **'Saved Drafts'**
  String get navDrafts;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get navLibrary;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @welcomeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR NEXT GAME NIGHT STARTS HERE'**
  String get welcomeEyebrow;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring everyone\nto the table.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a game, shape the session, and let ROUNDVEIL host the moment.'**
  String get welcomeBody;

  /// No description provided for @createGame.
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get createGame;

  /// No description provided for @quickGame.
  ///
  /// In en, this message translates to:
  /// **'Quick Game'**
  String get quickGame;

  /// No description provided for @savedDrafts.
  ///
  /// In en, this message translates to:
  /// **'Saved Drafts'**
  String get savedDrafts;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'Explore game modes'**
  String get gameModes;

  /// No description provided for @singleGame.
  ///
  /// In en, this message translates to:
  /// **'Single Game'**
  String get singleGame;

  /// No description provided for @mixedGame.
  ///
  /// In en, this message translates to:
  /// **'Mixed Game'**
  String get mixedGame;

  /// No description provided for @selectGames.
  ///
  /// In en, this message translates to:
  /// **'Choose your games'**
  String get selectGames;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get addPlayer;

  /// No description provided for @removePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove player'**
  String get removePlayer;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Create session'**
  String get startSession;

  /// No description provided for @editConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Edit configuration'**
  String get editConfiguration;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved on this device.'**
  String get draftSaved;

  /// No description provided for @noDrafts.
  ///
  /// In en, this message translates to:
  /// **'Your saved sessions will appear here.'**
  String get noDrafts;

  /// No description provided for @chooseOneGame.
  ///
  /// In en, this message translates to:
  /// **'Choose one game to continue.'**
  String get chooseOneGame;

  /// No description provided for @chooseTwoGames.
  ///
  /// In en, this message translates to:
  /// **'Choose at least two games for a mixed session.'**
  String get chooseTwoGames;

  /// No description provided for @choosePlayer.
  ///
  /// In en, this message translates to:
  /// **'Add at least one player to continue.'**
  String get choosePlayer;

  /// No description provided for @sessionCreated.
  ///
  /// In en, this message translates to:
  /// **'Session configuration created.'**
  String get sessionCreated;

  /// No description provided for @sessionReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your session is assembled'**
  String get sessionReadyTitle;

  /// No description provided for @sessionReadyBody.
  ///
  /// In en, this message translates to:
  /// **'The configuration is saved. Gameplay launches only for modules that are currently implemented.'**
  String get sessionReadyBody;

  /// No description provided for @playablePrototype.
  ///
  /// In en, this message translates to:
  /// **'Playable prototype'**
  String get playablePrototype;

  /// No description provided for @inFoundation.
  ///
  /// In en, this message translates to:
  /// **'Foundation in progress'**
  String get inFoundation;

  /// No description provided for @notPlayable.
  ///
  /// In en, this message translates to:
  /// **'Gameplay not connected yet'**
  String get notPlayable;

  /// No description provided for @guessCountry.
  ///
  /// In en, this message translates to:
  /// **'Guess the Country'**
  String get guessCountry;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @wordPlay.
  ///
  /// In en, this message translates to:
  /// **'Word Play'**
  String get wordPlay;

  /// No description provided for @guessCharacter.
  ///
  /// In en, this message translates to:
  /// **'Guess the Character'**
  String get guessCharacter;

  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get quickQuiz;

  /// No description provided for @quickWordPlay.
  ///
  /// In en, this message translates to:
  /// **'Word Sprint'**
  String get quickWordPlay;

  /// No description provided for @quickCharacter.
  ///
  /// In en, this message translates to:
  /// **'Character Challenge'**
  String get quickCharacter;

  /// No description provided for @quickFlags.
  ///
  /// In en, this message translates to:
  /// **'Flag Challenge'**
  String get quickFlags;

  /// No description provided for @quickPartyMix.
  ///
  /// In en, this message translates to:
  /// **'Party Mix'**
  String get quickPartyMix;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Set up your session'**
  String get working;

  /// No description provided for @localOffline.
  ///
  /// In en, this message translates to:
  /// **'Your sessions stay on this device'**
  String get localOffline;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLight;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @quickTemplates.
  ///
  /// In en, this message translates to:
  /// **'Start from a template'**
  String get quickTemplates;

  /// No description provided for @templateDescription.
  ///
  /// In en, this message translates to:
  /// **'Every template is editable before you create a session.'**
  String get templateDescription;

  /// No description provided for @sessionName.
  ///
  /// In en, this message translates to:
  /// **'Session name'**
  String get sessionName;

  /// No description provided for @draftCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No saved drafts} =1{1 saved draft} other{{count} saved drafts}}'**
  String draftCount(num count);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get menu;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'ROUNDVEIL interface language'**
  String get languageNote;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session overview'**
  String get sessionTitle;

  /// No description provided for @editPlayers.
  ///
  /// In en, this message translates to:
  /// **'Edit players'**
  String get editPlayers;

  /// No description provided for @createAnother.
  ///
  /// In en, this message translates to:
  /// **'Create another session'**
  String get createAnother;

  /// No description provided for @moduleOnlyCountry.
  ///
  /// In en, this message translates to:
  /// **'This is the only connected playable prototype today.'**
  String get moduleOnlyCountry;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready to create'**
  String get ready;

  /// No description provided for @incomplete.
  ///
  /// In en, this message translates to:
  /// **'Finish the required choices'**
  String get incomplete;

  /// No description provided for @rebuildStatus.
  ///
  /// In en, this message translates to:
  /// **'The broader multi-game rebuild is in progress.'**
  String get rebuildStatus;

  /// No description provided for @draftNeedsEditing.
  ///
  /// In en, this message translates to:
  /// **'This draft includes discontinued games. Edit it before use.'**
  String get draftNeedsEditing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'ko',
    'pt',
    'sw',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'sw':
      return AppLocalizationsSw();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
