// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'ROUNDVEIL';

  @override
  String get navHome => '홈';

  @override
  String get navCreate => '게임 만들기';

  @override
  String get navQuick => '빠른 게임';

  @override
  String get navDrafts => '저장된 초안';

  @override
  String get navLibrary => '게임 모드';

  @override
  String get navSettings => '설정';

  @override
  String get welcomeEyebrow => '다음 게임 나이트가 여기서 시작됩니다';

  @override
  String get welcomeTitle => '모두를\n한자리에.';

  @override
  String get welcomeBody => '게임을 고르고 세션을 구성하면 ROUNDVEIL이 진행을 맡습니다.';

  @override
  String get createGame => '게임 만들기';

  @override
  String get quickGame => '빠른 게임';

  @override
  String get savedDrafts => '저장된 초안';

  @override
  String get gameModes => '게임 모드 둘러보기';

  @override
  String get singleGame => '단일 게임';

  @override
  String get mixedGame => '혼합 게임';

  @override
  String get selectGames => '게임 선택';

  @override
  String get players => '플레이어';

  @override
  String get addPlayer => '플레이어 추가';

  @override
  String get removePlayer => '플레이어 제거';

  @override
  String get rounds => '라운드';

  @override
  String get saveDraft => '초안 저장';

  @override
  String get startSession => '세션 만들기';

  @override
  String get editConfiguration => '구성 편집';

  @override
  String get draftSaved => '초안이 이 기기에 저장되었습니다.';

  @override
  String get noDrafts => '저장한 세션이 여기에 표시됩니다.';

  @override
  String get chooseOneGame => '계속하려면 게임 하나를 선택하세요.';

  @override
  String get chooseTwoGames => '혼합 세션은 두 개 이상 선택하세요.';

  @override
  String get choosePlayer => '계속하려면 플레이어를 한 명 이상 추가하세요.';

  @override
  String get sessionCreated => '세션 구성이 만들어졌습니다.';

  @override
  String get sessionReadyTitle => '세션이 준비되었습니다';

  @override
  String get sessionReadyBody => '구성이 저장되었습니다. 구현된 모드만 플레이를 시작할 수 있습니다.';

  @override
  String get playablePrototype => '플레이 가능한 프로토타입';

  @override
  String get inFoundation => '기반 구축 중';

  @override
  String get notPlayable => '게임 플레이 미연결';

  @override
  String get guessCountry => '국가 맞히기';

  @override
  String get quiz => '퀴즈';

  @override
  String get wordPlay => '단어 게임';

  @override
  String get guessCharacter => '캐릭터 맞히기';

  @override
  String get quickQuiz => '빠른 퀴즈';

  @override
  String get quickWordPlay => '단어 스프린트';

  @override
  String get quickCharacter => '캐릭터 도전';

  @override
  String get quickFlags => '국기 도전';

  @override
  String get quickPartyMix => '파티 믹스';

  @override
  String get working => '세션 구성';

  @override
  String get localOffline => '세션은 이 기기에 저장됩니다';

  @override
  String get themeDark => '다크 테마';

  @override
  String get themeLight => '라이트 테마';

  @override
  String get language => '언어';

  @override
  String get back => '뒤로';

  @override
  String get close => '닫기';

  @override
  String get delete => '삭제';

  @override
  String get duplicate => '복제';

  @override
  String get quickTemplates => '템플릿으로 시작';

  @override
  String get templateDescription => '세션을 만들기 전에 템플릿을 편집할 수 있습니다.';

  @override
  String get sessionName => '세션 이름';

  @override
  String draftCount(num count) {
    return '저장된 초안 $count개';
  }

  @override
  String get menu => '메인 메뉴';

  @override
  String get appearance => '모양';

  @override
  String get languageNote => 'ROUNDVEIL 인터페이스 언어';

  @override
  String get sessionTitle => '세션 개요';

  @override
  String get editPlayers => '플레이어 편집';

  @override
  String get createAnother => '다른 세션 만들기';

  @override
  String get moduleOnlyCountry => '현재 플레이할 수 있는 프로토타입은 이것뿐입니다.';

  @override
  String get selected => '선택됨';

  @override
  String get notSelected => '선택 안 됨';

  @override
  String get ready => '만들 준비 완료';

  @override
  String get incomplete => '필수 선택을 완료하세요';

  @override
  String get rebuildStatus => '나머지 게임은 계속 개발 중입니다.';

  @override
  String get draftNeedsEditing => '이 초안에는 중단된 게임이 포함되어 있습니다. 사용하기 전에 편집하세요.';
}
