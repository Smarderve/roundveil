// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCreate => 'Créer une partie';

  @override
  String get navQuick => 'Partie rapide';

  @override
  String get navDrafts => 'Brouillons enregistrés';

  @override
  String get navLibrary => 'Modes de jeu';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get welcomeEyebrow => 'Votre prochaine soirée jeux commence ici';

  @override
  String get welcomeTitle => 'Rassemblez tout le monde\nautour de la table.';

  @override
  String get welcomeBody =>
      'Choisissez un jeu, préparez la session et laissez ROUNDVEIL mener la partie.';

  @override
  String get createGame => 'Créer une partie';

  @override
  String get quickGame => 'Partie rapide';

  @override
  String get savedDrafts => 'Brouillons enregistrés';

  @override
  String get gameModes => 'Découvrir les modes';

  @override
  String get singleGame => 'Jeu unique';

  @override
  String get mixedGame => 'Jeux mélangés';

  @override
  String get selectGames => 'Choisissez vos jeux';

  @override
  String get players => 'Joueurs';

  @override
  String get addPlayer => 'Ajouter un joueur';

  @override
  String get removePlayer => 'Retirer un joueur';

  @override
  String get rounds => 'Manches';

  @override
  String get saveDraft => 'Enregistrer le brouillon';

  @override
  String get startSession => 'Créer la session';

  @override
  String get editConfiguration => 'Modifier la configuration';

  @override
  String get draftSaved => 'Brouillon enregistré sur cet appareil.';

  @override
  String get noDrafts => 'Vos sessions enregistrées apparaîtront ici.';

  @override
  String get chooseOneGame => 'Choisissez un jeu pour continuer.';

  @override
  String get chooseTwoGames =>
      'Choisissez au moins deux jeux pour une session mixte.';

  @override
  String get choosePlayer => 'Ajoutez au moins un joueur pour continuer.';

  @override
  String get sessionCreated => 'Configuration de session créée.';

  @override
  String get sessionReadyTitle => 'Votre session est prête';

  @override
  String get sessionReadyBody =>
      'Configuration enregistrée. Le jeu démarre uniquement pour les modules implémentés.';

  @override
  String get playablePrototype => 'Prototype jouable';

  @override
  String get inFoundation => 'Fondations en cours';

  @override
  String get notPlayable => 'Jeu non connecté';

  @override
  String get guessCountry => 'Devinez le pays';

  @override
  String get quiz => 'Quiz';

  @override
  String get wordPlay => 'Jeu de mots';

  @override
  String get guessCharacter => 'Devinez le personnage';

  @override
  String get riddles => 'Énigmes';

  @override
  String get memory => 'Mémoire';

  @override
  String get quickQuiz => 'Quiz rapide';

  @override
  String get quickWordPlay => 'Défi de mots';

  @override
  String get quickCharacter => 'Défi personnage';

  @override
  String get quickRiddles => 'Session d’énigmes';

  @override
  String get quickMemory => 'Jeu de mémoire';

  @override
  String get quickFlags => 'Défi des drapeaux';

  @override
  String get quickPartyMix => 'Mélange festif';

  @override
  String get working => 'Préparez votre session';

  @override
  String get localOffline => 'Vos sessions restent sur cet appareil';

  @override
  String get themeDark => 'Thème sombre';

  @override
  String get themeLight => 'Thème clair';

  @override
  String get language => 'Langue';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get delete => 'Supprimer';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get quickTemplates => 'Partir d’un modèle';

  @override
  String get templateDescription =>
      'Chaque modèle est modifiable avant la création de la session.';

  @override
  String get sessionName => 'Nom de la session';

  @override
  String draftCount(num count) {
    return '$count brouillons';
  }

  @override
  String get menu => 'Menu principal';

  @override
  String get appearance => 'Apparence';

  @override
  String get languageNote => 'Langue de ROUNDVEIL';

  @override
  String get sessionTitle => 'Aperçu de la session';

  @override
  String get editPlayers => 'Modifier les joueurs';

  @override
  String get createAnother => 'Créer une autre session';

  @override
  String get moduleOnlyCountry =>
      'C’est le seul prototype jouable pour le moment.';

  @override
  String get selected => 'Sélectionné';

  @override
  String get notSelected => 'Non sélectionné';

  @override
  String get ready => 'Prêt à créer';

  @override
  String get incomplete => 'Terminez les choix requis';

  @override
  String get rebuildStatus => 'La reconstruction des autres jeux continue.';
}
