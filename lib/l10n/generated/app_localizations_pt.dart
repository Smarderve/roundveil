// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => 'Início';

  @override
  String get navCreate => 'Criar jogo';

  @override
  String get navQuick => 'Jogo rápido';

  @override
  String get navDrafts => 'Rascunhos salvos';

  @override
  String get navLibrary => 'Modos de jogo';

  @override
  String get navSettings => 'Configurações';

  @override
  String get welcomeEyebrow => 'A próxima noite de jogos começa aqui';

  @override
  String get welcomeTitle => 'Reúna todos\nà mesa.';

  @override
  String get welcomeBody =>
      'Escolha um jogo, configure a sessão e deixe o ROUNDVEIL conduzir o momento.';

  @override
  String get createGame => 'Criar jogo';

  @override
  String get quickGame => 'Jogo rápido';

  @override
  String get savedDrafts => 'Rascunhos salvos';

  @override
  String get gameModes => 'Explorar modos de jogo';

  @override
  String get singleGame => 'Jogo único';

  @override
  String get mixedGame => 'Jogo misto';

  @override
  String get selectGames => 'Escolha os jogos';

  @override
  String get players => 'Jogadores';

  @override
  String get addPlayer => 'Adicionar jogador';

  @override
  String get removePlayer => 'Remover jogador';

  @override
  String get rounds => 'Rodadas';

  @override
  String get saveDraft => 'Salvar rascunho';

  @override
  String get startSession => 'Criar sessão';

  @override
  String get editConfiguration => 'Editar configuração';

  @override
  String get draftSaved => 'Rascunho salvo neste dispositivo.';

  @override
  String get noDrafts => 'Suas sessões salvas aparecerão aqui.';

  @override
  String get chooseOneGame => 'Escolha um jogo para continuar.';

  @override
  String get chooseTwoGames =>
      'Escolha pelo menos dois jogos para uma sessão mista.';

  @override
  String get choosePlayer => 'Adicione pelo menos um jogador para continuar.';

  @override
  String get sessionCreated => 'Configuração da sessão criada.';

  @override
  String get sessionReadyTitle => 'Sua sessão está montada';

  @override
  String get sessionReadyBody =>
      'A configuração foi salva. A partida só inicia nos módulos já implementados.';

  @override
  String get playablePrototype => 'Protótipo jogável';

  @override
  String get inFoundation => 'Fundação em andamento';

  @override
  String get notPlayable => 'Partida ainda não conectada';

  @override
  String get guessCountry => 'Adivinhe o país';

  @override
  String get quiz => 'Quiz';

  @override
  String get wordPlay => 'Jogo de palavras';

  @override
  String get guessCharacter => 'Adivinhe o personagem';

  @override
  String get riddles => 'Charadas';

  @override
  String get memory => 'Memória';

  @override
  String get quickQuiz => 'Quiz rápido';

  @override
  String get quickWordPlay => 'Corrida de palavras';

  @override
  String get quickCharacter => 'Desafio de personagem';

  @override
  String get quickRiddles => 'Sessão de charadas';

  @override
  String get quickMemory => 'Jogo da memória';

  @override
  String get quickFlags => 'Desafio das bandeiras';

  @override
  String get quickPartyMix => 'Mix de festa';

  @override
  String get working => 'Configure sua sessão';

  @override
  String get localOffline => 'Suas sessões ficam neste dispositivo';

  @override
  String get themeDark => 'Tema escuro';

  @override
  String get themeLight => 'Tema claro';

  @override
  String get language => 'Idioma';

  @override
  String get back => 'Voltar';

  @override
  String get close => 'Fechar';

  @override
  String get delete => 'Excluir';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get quickTemplates => 'Comece por um modelo';

  @override
  String get templateDescription =>
      'Todos os modelos podem ser editados antes de criar a sessão.';

  @override
  String get sessionName => 'Nome da sessão';

  @override
  String draftCount(num count) {
    return '$count rascunhos';
  }

  @override
  String get menu => 'Menu principal';

  @override
  String get appearance => 'Aparência';

  @override
  String get languageNote => 'Idioma da interface ROUNDVEIL';

  @override
  String get sessionTitle => 'Resumo da sessão';

  @override
  String get editPlayers => 'Editar jogadores';

  @override
  String get createAnother => 'Criar outra sessão';

  @override
  String get moduleOnlyCountry =>
      'Este é o único protótipo jogável no momento.';

  @override
  String get selected => 'Selecionado';

  @override
  String get notSelected => 'Não selecionado';

  @override
  String get ready => 'Pronto para criar';

  @override
  String get incomplete => 'Complete as escolhas obrigatórias';

  @override
  String get rebuildStatus =>
      'A reconstrução dos outros jogos está em andamento.';
}
