// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCreate => 'Crear juego';

  @override
  String get navQuick => 'Juego rápido';

  @override
  String get navDrafts => 'Borradores guardados';

  @override
  String get navLibrary => 'Modos de juego';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get welcomeEyebrow => 'Tu próxima noche de juegos empieza aquí';

  @override
  String get welcomeTitle => 'Reunid a todos\nen la mesa.';

  @override
  String get welcomeBody =>
      'Elige un juego, prepara la sesión y deja que ROUNDVEIL dirija el momento.';

  @override
  String get createGame => 'Crear juego';

  @override
  String get quickGame => 'Juego rápido';

  @override
  String get savedDrafts => 'Borradores guardados';

  @override
  String get gameModes => 'Explorar modos de juego';

  @override
  String get singleGame => 'Juego individual';

  @override
  String get mixedGame => 'Juego mixto';

  @override
  String get selectGames => 'Elige tus juegos';

  @override
  String get players => 'Jugadores';

  @override
  String get addPlayer => 'Añadir jugador';

  @override
  String get removePlayer => 'Quitar jugador';

  @override
  String get rounds => 'Rondas';

  @override
  String get saveDraft => 'Guardar borrador';

  @override
  String get startSession => 'Crear sesión';

  @override
  String get editConfiguration => 'Editar configuración';

  @override
  String get draftSaved => 'Borrador guardado en este dispositivo.';

  @override
  String get noDrafts => 'Tus sesiones guardadas aparecerán aquí.';

  @override
  String get chooseOneGame => 'Elige un juego para continuar.';

  @override
  String get chooseTwoGames =>
      'Elige al menos dos juegos para una sesión mixta.';

  @override
  String get choosePlayer => 'Añade al menos un jugador para continuar.';

  @override
  String get sessionCreated => 'Configuración de sesión creada.';

  @override
  String get sessionReadyTitle => 'Tu sesión está preparada';

  @override
  String get sessionReadyBody =>
      'La configuración se guardó. Solo se inicia el juego en módulos implementados.';

  @override
  String get playablePrototype => 'Prototipo jugable';

  @override
  String get inFoundation => 'Base en desarrollo';

  @override
  String get notPlayable => 'Juego aún no conectado';

  @override
  String get guessCountry => 'Adivina el país';

  @override
  String get quiz => 'Quiz';

  @override
  String get wordPlay => 'Juego de palabras';

  @override
  String get guessCharacter => 'Adivina el personaje';

  @override
  String get quickQuiz => 'Quiz rápido';

  @override
  String get quickWordPlay => 'Reto de palabras';

  @override
  String get quickCharacter => 'Reto de personaje';

  @override
  String get quickFlags => 'Reto de banderas';

  @override
  String get quickPartyMix => 'Mezcla de fiesta';

  @override
  String get working => 'Prepara tu sesión';

  @override
  String get localOffline => 'Tus sesiones permanecen en este dispositivo';

  @override
  String get themeDark => 'Tema oscuro';

  @override
  String get themeLight => 'Tema claro';

  @override
  String get language => 'Idioma';

  @override
  String get back => 'Volver';

  @override
  String get close => 'Cerrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get quickTemplates => 'Empieza con una plantilla';

  @override
  String get templateDescription =>
      'Puedes editar cada plantilla antes de crear la sesión.';

  @override
  String get sessionName => 'Nombre de sesión';

  @override
  String draftCount(num count) {
    return '$count borradores';
  }

  @override
  String get menu => 'Menú principal';

  @override
  String get appearance => 'Apariencia';

  @override
  String get languageNote => 'Idioma de ROUNDVEIL';

  @override
  String get sessionTitle => 'Resumen de sesión';

  @override
  String get editPlayers => 'Editar jugadores';

  @override
  String get createAnother => 'Crear otra sesión';

  @override
  String get moduleOnlyCountry =>
      'Este es el único prototipo jugable por ahora.';

  @override
  String get selected => 'Seleccionado';

  @override
  String get notSelected => 'No seleccionado';

  @override
  String get ready => 'Listo para crear';

  @override
  String get incomplete => 'Completa las opciones obligatorias';

  @override
  String get rebuildStatus => 'La reconstrucción de los demás juegos continúa.';

  @override
  String get draftNeedsEditing =>
      'Este borrador incluye juegos retirados. Edítalo antes de usarlo.';
}
