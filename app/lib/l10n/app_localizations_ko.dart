// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navQueue => '대기열';

  @override
  String get navCharacters => '캐릭터';

  @override
  String get navSettings => '설정';

  @override
  String get retry => '다시 시도';

  @override
  String nasUnavailable(String error) {
    return 'NAS를 사용할 수 없음: $error';
  }

  @override
  String get promptLabel => '아이템 프롬프트';

  @override
  String get categoriesLabel => '카테고리';

  @override
  String get catHelmet => '투구';

  @override
  String get catBack => '날개 / 등';

  @override
  String get catSword => '검';

  @override
  String get catFront => '흉갑';

  @override
  String get catHat => '모자';

  @override
  String get catHair => '머리카락(위험)';

  @override
  String get styleLabel => '스타일';

  @override
  String get collectionLabel => '컬렉션';

  @override
  String get radialTitle => '전체 둘레 장식';

  @override
  String get radialSubtitle => '방사 대칭 – 케이크, 왕관';

  @override
  String variantsPerCategory(int count) {
    return '카테고리당 변형 수: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '아이템 $count개 생성',
    );
    return '$_temp0 (약 $minutes분)';
  }

  @override
  String composerSent(int sent) {
    return '전송한 작업: $sent – Spark가 생성 중(개당 약 4분, 순서대로)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return '전송: $sent, 오류: $errors';
  }

  @override
  String get queueEmpty => 'NAS에 아직 아무것도 없습니다 – Composer에서 배치를 보내세요.';

  @override
  String get stNew => '트리아지 대기 중';

  @override
  String get stRemeshing => 'TRELLIS에서 다시 계산 중(약 4분)';

  @override
  String get stApproved => '변환 대기열';

  @override
  String get stConverting => '변환 중';

  @override
  String get stConverted => '변환됨 – 3D 검토 대기 중';

  @override
  String get stPacked => 'Studio용으로 패키징됨';

  @override
  String get stFailed => '실패';

  @override
  String get stRejected => '거부됨';

  @override
  String get stRerolled => '다시 생성됨';

  @override
  String get tapFor3d => '탭하여 3D 보기';

  @override
  String get pack => '패키징';

  @override
  String sparkSection(int count) {
    return 'Spark에서 제작 중 ($count)';
  }

  @override
  String get sgQueued => '대기열에서 기다리는 중';

  @override
  String get sgConcept => '콘셉트 그리는 중';

  @override
  String get sgCleanplate => '배경 제거 중';

  @override
  String get sgMesh => '3D 모델링 중(약 4분)';

  @override
  String get sgPush => 'NAS로 전송 중';

  @override
  String get sgDone => '완료';

  @override
  String get sgFailed => '실패';

  @override
  String get reviewTris => '삼각형';

  @override
  String get reviewTexture => '텍스처';

  @override
  String get reviewSymmetry => '대칭';

  @override
  String get yes => '예';

  @override
  String get no => '아니요';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (이음새 꼭짓점: $count)';
  }

  @override
  String get reconvertAgain => '다시 변환';

  @override
  String get reconvertSymmetry => '대칭을 적용해 다시';

  @override
  String get radialMenu => '전체 둘레 장식(방사형)';

  @override
  String get noSymmetry => '대칭 없음';

  @override
  String get backToConcept => '콘셉트로 돌아가기';

  @override
  String get show3d => '3D 모델 보기';

  @override
  String get rejectedToast => '거부됨';

  @override
  String get rerollToast => '리롤을 Spark로 보냈습니다';

  @override
  String get approvedToast => '승인됨 → 변환';

  @override
  String errorPrefix(String error) {
    return '오류: $error';
  }

  @override
  String get allSorted => '모두 분류했습니다. Composer에서 새 배치를 보낼까요?';

  @override
  String get newShort => '새로 만들기';

  @override
  String get charactersEmpty => '아직 캐릭터가 없습니다.\n인간형 캐릭터의 사진이나 이미지로 시작하세요.';

  @override
  String get newCharacter => '새 캐릭터';

  @override
  String get creating => '만드는 중…';

  @override
  String get generate => '생성';

  @override
  String get nameLabel => '이름';

  @override
  String get prepPhoto => '사진 준비';

  @override
  String get prepPhotoHelp =>
      '배경을 제거합니다. 팔이 몸에 붙어 있으면 A 포즈로 떼어 내고, 발목 아래 다리가 없으면 채워 넣습니다. 이 과정이 없으면 팔다리가 붙은 경우 리그가 자주 실패합니다.';

  @override
  String get animationsLabel => '애니메이션';

  @override
  String libraryLoadFailed(String error) {
    return '라이브러리를 불러오지 못했습니다: $error';
  }

  @override
  String get libraryEmpty =>
      '라이브러리가 비어 있습니다. 클립은 NAS의 seed_animlib.py 스크립트로 등록합니다.';

  @override
  String get gallery => '갤러리';

  @override
  String get camera => '카메라';

  @override
  String get characterFallback => '캐릭터';

  @override
  String get downloadGlb => 'GLB 다운로드';

  @override
  String get downloadFbx => 'FBX 다운로드';

  @override
  String get downloadZip => '모두 다운로드(ZIP)';

  @override
  String get sendRoblox => 'Roblox로 보내기';

  @override
  String get sendLuanti => 'Luanti로 보내기';

  @override
  String exportQueued(String target) {
    return '$target(으)로 내보내기를 대기열에 추가했습니다';
  }

  @override
  String get clipsTitle => '클립';

  @override
  String get exportsTitle => '내보내기';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step ($attempt번째 시도)';
  }

  @override
  String get retryStep => '단계 다시 시도';

  @override
  String stepOf(int step, int total) {
    return '$total단계 중 $step단계';
  }

  @override
  String get cfAccessHelp => 'ugc.ol1n.com에만 필요합니다(Tailscale 없이 접속).';

  @override
  String get saveAndTest => '저장 후 테스트';

  @override
  String connOk(int count) {
    return '연결 정상(불러온 작업: $count)';
  }

  @override
  String connFailed(String error) {
    return '사용할 수 없음: $error';
  }
}
