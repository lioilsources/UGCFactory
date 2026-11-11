// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get navQueue => 'Hàng đợi';

  @override
  String get navCharacters => 'Nhân vật';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get retry => 'Thử lại';

  @override
  String nasUnavailable(String error) {
    return 'NAS không khả dụng: $error';
  }

  @override
  String get promptLabel => 'Prompt của vật phẩm';

  @override
  String get categoriesLabel => 'Danh mục';

  @override
  String get catHelmet => 'Mũ giáp';

  @override
  String get catBack => 'Cánh / lưng';

  @override
  String get catSword => 'Kiếm';

  @override
  String get catFront => 'Giáp ngực';

  @override
  String get catHat => 'Mũ len';

  @override
  String get catHair => 'Tóc (rủi ro)';

  @override
  String get styleLabel => 'Phong cách';

  @override
  String get collectionLabel => 'Bộ sưu tập';

  @override
  String get radialTitle => 'Trang trí bao quanh';

  @override
  String get radialSubtitle => 'đối xứng tỏa tròn – bánh kem, vương miện';

  @override
  String variantsPerCategory(int count) {
    return 'Số biến thể mỗi danh mục: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tạo $count vật phẩm',
    );
    return '$_temp0 (~$minutes phút)';
  }

  @override
  String composerSent(int sent) {
    return 'Số tác vụ đã gửi: $sent – Spark đang tạo (~4 phút mỗi món, lần lượt từng món)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Đã gửi: $sent, lỗi: $errors';
  }

  @override
  String get queueEmpty => 'Trên NAS chưa có gì – hãy gửi một lô từ Composer.';

  @override
  String get stNew => 'Chờ phân loại';

  @override
  String get stRemeshing => 'Đang tính lại trong TRELLIS (~4 phút)';

  @override
  String get stApproved => 'Trong hàng đợi chuyển đổi';

  @override
  String get stConverting => 'Đang chuyển đổi';

  @override
  String get stConverted => 'Đã chuyển đổi – chờ duyệt 3D';

  @override
  String get stPacked => 'Đã đóng gói cho Studio';

  @override
  String get stFailed => 'Thất bại';

  @override
  String get stRejected => 'Đã từ chối';

  @override
  String get stRerolled => 'Đã tạo lại';

  @override
  String get tapFor3d => 'chạm để xem 3D';

  @override
  String get pack => 'Đóng gói';

  @override
  String sparkSection(int count) {
    return 'Đang tạo trên Spark ($count)';
  }

  @override
  String get sgQueued => 'đang chờ trong hàng đợi';

  @override
  String get sgConcept => 'đang vẽ concept';

  @override
  String get sgCleanplate => 'đang xóa nền';

  @override
  String get sgMesh => 'đang dựng mô hình 3D (~4 phút)';

  @override
  String get sgPush => 'đang gửi lên NAS';

  @override
  String get sgDone => 'xong';

  @override
  String get sgFailed => 'thất bại';

  @override
  String get reviewTris => 'tam giác';

  @override
  String get reviewTexture => 'kết cấu';

  @override
  String get reviewSymmetry => 'đối xứng';

  @override
  String get yes => 'có';

  @override
  String get no => 'không';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (đỉnh đường may: $count)';
  }

  @override
  String get reconvertAgain => 'Chuyển đổi lại';

  @override
  String get reconvertSymmetry => 'Làm lại với đối xứng';

  @override
  String get radialMenu => 'Trang trí bao quanh (tỏa tròn)';

  @override
  String get noSymmetry => 'Không đối xứng';

  @override
  String get backToConcept => 'Quay lại concept';

  @override
  String get show3d => 'Xem mô hình 3D';

  @override
  String get rejectedToast => 'Đã từ chối';

  @override
  String get rerollToast => 'Đã gửi reroll tới Spark';

  @override
  String get approvedToast => 'Đã duyệt → chuyển đổi';

  @override
  String errorPrefix(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get allSorted => 'Đã phân loại hết. Gửi một lô mới từ Composer?';

  @override
  String get newShort => 'Mới';

  @override
  String get charactersEmpty =>
      'Chưa có nhân vật nào.\nHãy bắt đầu bằng ảnh chụp hoặc hình của một nhân vật hình người.';

  @override
  String get newCharacter => 'Nhân vật mới';

  @override
  String get creating => 'Đang tạo…';

  @override
  String get generate => 'Tạo';

  @override
  String get nameLabel => 'Tên';

  @override
  String get prepPhoto => 'Chuẩn bị ảnh';

  @override
  String get prepPhotoHelp =>
      'Xóa nền; nếu tay dính vào thân, sẽ tách ra tư thế chữ A, và nếu thiếu chân dưới mắt cá thì bổ sung. Nếu không, rig thường thất bại với các chi dính liền.';

  @override
  String get animationsLabel => 'Hoạt ảnh';

  @override
  String libraryLoadFailed(String error) {
    return 'Không tải được thư viện: $error';
  }

  @override
  String get libraryEmpty =>
      'Thư viện trống. Các clip được đăng ký bằng script seed_animlib.py trên NAS.';

  @override
  String get gallery => 'Thư viện ảnh';

  @override
  String get camera => 'Máy ảnh';

  @override
  String get characterFallback => 'Nhân vật';

  @override
  String get downloadGlb => 'Tải GLB';

  @override
  String get downloadFbx => 'Tải FBX';

  @override
  String get downloadZip => 'Tải tất cả (ZIP)';

  @override
  String get sendRoblox => 'Gửi tới Roblox';

  @override
  String get sendLuanti => 'Gửi tới Luanti';

  @override
  String exportQueued(String target) {
    return 'Đã xếp hàng xuất sang $target';
  }

  @override
  String get clipsTitle => 'Clip';

  @override
  String get exportsTitle => 'Bản xuất';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (lần thử $attempt)';
  }

  @override
  String get retryStep => 'Thử lại bước này';

  @override
  String stepOf(int step, int total) {
    return 'bước $step/$total';
  }

  @override
  String get cfAccessHelp =>
      'Chỉ cần cho ugc.ol1n.com (truy cập không qua Tailscale).';

  @override
  String get saveAndTest => 'Lưu và kiểm tra';

  @override
  String connOk(int count) {
    return 'Kết nối ổn (số tác vụ đã tải: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Không khả dụng: $error';
  }
}
