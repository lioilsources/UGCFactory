// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get navQueue => 'ଧାଡ଼ି';

  @override
  String get navCharacters => 'ଚରିତ୍ର';

  @override
  String get navSettings => 'ସେଟିଂସ୍';

  @override
  String get retry => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String nasUnavailable(String error) {
    return 'NAS ଉପଲବ୍ଧ ନାହିଁ: $error';
  }

  @override
  String get promptLabel => 'ଆଇଟମ୍‌ର ପ୍ରମ୍ପ୍ଟ୍';

  @override
  String get categoriesLabel => 'ବର୍ଗ';

  @override
  String get catHelmet => 'ହେଲମେଟ୍';

  @override
  String get catBack => 'ଡେଣା / ପିଠି';

  @override
  String get catSword => 'ଖଡ୍ଗ';

  @override
  String get catFront => 'ଛାତି କବଚ';

  @override
  String get catHat => 'ଟୋପି';

  @override
  String get catHair => 'କେଶ (ବିପଜ୍ଜନକ)';

  @override
  String get styleLabel => 'ଶୈଳୀ';

  @override
  String get collectionLabel => 'ସଂଗ୍ରହ';

  @override
  String get radialTitle => 'ଚାରିପାଖରେ ସଜ୍ଜା';

  @override
  String get radialSubtitle => 'ରେଡିଆଲ୍ ସମମିତି – କେକ୍, ମୁକୁଟ';

  @override
  String variantsPerCategory(int count) {
    return 'ପ୍ରତି ବର୍ଗରେ ଭାରିଆଣ୍ଟ: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ଆଇଟମ୍ ତିଆରି କରନ୍ତୁ',
      one: '$count ଆଇଟମ୍ ତିଆରି କରନ୍ତୁ',
    );
    return '$_temp0 (~$minutes ମିନିଟ୍)';
  }

  @override
  String composerSent(int sent) {
    return 'ପଠାଯାଇଥିବା କାମ: $sent – Spark ତିଆରି କରୁଛି (~ପ୍ରତ୍ୟେକ 4 ମିନିଟ୍, ଗୋଟିଏ ପରେ ଗୋଟିଏ)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'ପଠାଗଲା: $sent, ତ୍ରୁଟି: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS ରେ ଏପର୍ଯ୍ୟନ୍ତ କିଛି ନାହିଁ – Composer ରୁ ବ୍ୟାଚ୍ ପଠାନ୍ତୁ।';

  @override
  String get stNew => 'ଟ୍ରାଏଜ୍ ପାଇଁ ଅପେକ୍ଷା';

  @override
  String get stRemeshing => 'TRELLIS ରେ ପୁଣି ଗଣନା ହେଉଛି (~4 ମିନିଟ୍)';

  @override
  String get stApproved => 'ରୂପାନ୍ତର ଧାଡ଼ିରେ';

  @override
  String get stConverting => 'ରୂପାନ୍ତର ହେଉଛି';

  @override
  String get stConverted => 'ରୂପାନ୍ତରିତ – 3D ସମୀକ୍ଷା ପାଇଁ ଅପେକ୍ଷା';

  @override
  String get stPacked => 'Studio ପାଇଁ ପ୍ୟାକ୍ ହୋଇଛି';

  @override
  String get stFailed => 'ବିଫଳ';

  @override
  String get stRejected => 'ପ୍ରତ୍ୟାଖ୍ୟାତ';

  @override
  String get stRerolled => 'ପୁଣି ତିଆରି ହୋଇଛି';

  @override
  String get tapFor3d => '3D ପାଇଁ ଟାପ୍ କରନ୍ତୁ';

  @override
  String get pack => 'ପ୍ୟାକ୍ କରନ୍ତୁ';

  @override
  String sparkSection(int count) {
    return 'Spark ରେ ତିଆରି ହେଉଛି ($count)';
  }

  @override
  String get sgQueued => 'ଧାଡ଼ିରେ ଅପେକ୍ଷା କରୁଛି';

  @override
  String get sgConcept => 'କନ୍ସେପ୍ଟ ଆଙ୍କୁଛି';

  @override
  String get sgCleanplate => 'ପୃଷ୍ଠଭୂମି ହଟାଉଛି';

  @override
  String get sgMesh => '3D ମଡେଲିଂ (~4 ମିନିଟ୍)';

  @override
  String get sgPush => 'NAS କୁ ପଠାଉଛି';

  @override
  String get sgDone => 'ସମାପ୍ତ';

  @override
  String get sgFailed => 'ବିଫଳ';

  @override
  String get reviewTris => 'ତ୍ରିଭୁଜ';

  @override
  String get reviewTexture => 'ଟେକ୍ସଚର୍';

  @override
  String get reviewSymmetry => 'ସମମିତି';

  @override
  String get yes => 'ହଁ';

  @override
  String get no => 'ନା';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (ସିଁବାର ଶୀର୍ଷ: $count)';
  }

  @override
  String get reconvertAgain => 'ପୁଣି ରୂପାନ୍ତର କରନ୍ତୁ';

  @override
  String get reconvertSymmetry => 'ସମମିତି ସହ ପୁଣି';

  @override
  String get radialMenu => 'ଚାରିପାଖରେ ସଜ୍ଜା (ରେଡିଆଲ୍)';

  @override
  String get noSymmetry => 'ସମମିତି ବିନା';

  @override
  String get backToConcept => 'କନ୍ସେପ୍ଟକୁ ଫେରନ୍ତୁ';

  @override
  String get show3d => '3D ମଡେଲ୍ ଦେଖାନ୍ତୁ';

  @override
  String get rejectedToast => 'ପ୍ରତ୍ୟାଖ୍ୟାତ';

  @override
  String get rerollToast => 'ରିରୋଲ୍ Spark କୁ ପଠାଗଲା';

  @override
  String get approvedToast => 'ଅନୁମୋଦିତ → ରୂପାନ୍ତର';

  @override
  String errorPrefix(String error) {
    return 'ତ୍ରୁଟି: $error';
  }

  @override
  String get allSorted => 'ସବୁ ବାଛି ହୋଇଗଲା। Composer ରୁ ନୂଆ ବ୍ୟାଚ୍ ପଠାଇବେ?';

  @override
  String get newShort => 'ନୂଆ';

  @override
  String get charactersEmpty =>
      'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ଚରିତ୍ର ନାହିଁ।\nମାନବାକୃତି ଚରିତ୍ରର ଫଟୋ ବା ଛବିରୁ ଆରମ୍ଭ କରନ୍ତୁ।';

  @override
  String get newCharacter => 'ନୂଆ ଚରିତ୍ର';

  @override
  String get creating => 'ତିଆରି ହେଉଛି…';

  @override
  String get generate => 'ତିଆରି କରନ୍ତୁ';

  @override
  String get nameLabel => 'ନାମ';

  @override
  String get prepPhoto => 'ଫଟୋ ପ୍ରସ୍ତୁତ କରନ୍ତୁ';

  @override
  String get prepPhotoHelp =>
      'ପୃଷ୍ଠଭୂମି ହଟାଏ; ହାତ ଶରୀରରେ ଲାଗିଥିଲେ ସେଗୁଡ଼ିକୁ A-ପୋଜ୍‌କୁ ଟାଣି ଆଣେ, ଏବଂ ଗୋଇଠି ତଳେ ଗୋଡ଼ ନଥିଲେ ସେଗୁଡ଼ିକୁ ପୂରଣ କରେ। ଏହା ବିନା ଯୋଡ଼ା ହୋଇଥିବା ଅଙ୍ଗରେ ରିଗ୍ ପ୍ରାୟତଃ ବିଫଳ ହୁଏ।';

  @override
  String get animationsLabel => 'ଆନିମେସନ୍';

  @override
  String libraryLoadFailed(String error) {
    return 'ଲାଇବ୍ରେରୀ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ: $error';
  }

  @override
  String get libraryEmpty =>
      'ଲାଇବ୍ରେରୀ ଖାଲି। କ୍ଲିପ୍‌ଗୁଡ଼ିକ NAS ରେ seed_animlib.py ସ୍କ୍ରିପ୍ଟ ଦ୍ୱାରା ପଞ୍ଜୀକୃତ ହୁଏ।';

  @override
  String get gallery => 'ଗ୍ୟାଲେରୀ';

  @override
  String get camera => 'କ୍ୟାମେରା';

  @override
  String get characterFallback => 'ଚରିତ୍ର';

  @override
  String get downloadGlb => 'GLB ଡାଉନଲୋଡ୍';

  @override
  String get downloadFbx => 'FBX ଡାଉନଲୋଡ୍';

  @override
  String get downloadZip => 'ସବୁ ଡାଉନଲୋଡ୍ (ZIP)';

  @override
  String get sendRoblox => 'Roblox କୁ ପଠାନ୍ତୁ';

  @override
  String get sendLuanti => 'Luanti କୁ ପଠାନ୍ତୁ';

  @override
  String exportQueued(String target) {
    return '$target କୁ ଏକ୍ସପୋର୍ଟ ଧାଡ଼ିରେ ରଖାଗଲା';
  }

  @override
  String get clipsTitle => 'କ୍ଲିପ୍';

  @override
  String get exportsTitle => 'ଏକ୍ସପୋର୍ଟ';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ଚେଷ୍ଟା $attempt)';
  }

  @override
  String get retryStep => 'ପଦକ୍ଷେପ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String stepOf(int step, int total) {
    return 'ପଦକ୍ଷେପ $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'କେବଳ ugc.ol1n.com ପାଇଁ ଦରକାର (Tailscale ବିନା ପ୍ରବେଶ)।';

  @override
  String get saveAndTest => 'ସଞ୍ଚୟ ଓ ପରୀକ୍ଷା';

  @override
  String connOk(int count) {
    return 'ସଂଯୋଗ ଠିକ୍ ଅଛି (ଲୋଡ୍ ହୋଇଥିବା କାମ: $count)';
  }

  @override
  String connFailed(String error) {
    return 'ଉପଲବ୍ଧ ନାହିଁ: $error';
  }
}
