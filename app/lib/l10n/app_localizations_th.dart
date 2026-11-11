// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get navQueue => 'คิว';

  @override
  String get navCharacters => 'ตัวละคร';

  @override
  String get navSettings => 'การตั้งค่า';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String nasUnavailable(String error) {
    return 'ใช้ NAS ไม่ได้: $error';
  }

  @override
  String get promptLabel => 'พรอมต์ของไอเทม';

  @override
  String get categoriesLabel => 'หมวดหมู่';

  @override
  String get catHelmet => 'หมวกเกราะ';

  @override
  String get catBack => 'ปีก / หลัง';

  @override
  String get catSword => 'ดาบ';

  @override
  String get catFront => 'เกราะอก';

  @override
  String get catHat => 'หมวก';

  @override
  String get catHair => 'ผม (เสี่ยง)';

  @override
  String get styleLabel => 'สไตล์';

  @override
  String get collectionLabel => 'คอลเลกชัน';

  @override
  String get radialTitle => 'ลวดลายรอบด้าน';

  @override
  String get radialSubtitle => 'สมมาตรแบบรัศมี – เค้ก มงกุฎ';

  @override
  String variantsPerCategory(int count) {
    return 'จำนวนแบบต่อหมวดหมู่: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'สร้าง $count ไอเทม',
    );
    return '$_temp0 (~$minutes นาที)';
  }

  @override
  String composerSent(int sent) {
    return 'งานที่ส่งแล้ว: $sent – Spark กำลังสร้าง (ชิ้นละ ~4 นาที ทีละชิ้น)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'ส่งแล้ว: $sent ข้อผิดพลาด: $errors';
  }

  @override
  String get queueEmpty => 'ใน NAS ยังไม่มีอะไร – ส่งแบตช์จาก Composer';

  @override
  String get stNew => 'รอการคัดแยก';

  @override
  String get stRemeshing => 'กำลังคำนวณใหม่ใน TRELLIS (~4 นาที)';

  @override
  String get stApproved => 'อยู่ในคิวแปลงไฟล์';

  @override
  String get stConverting => 'กำลังแปลงไฟล์';

  @override
  String get stConverted => 'แปลงแล้ว – รอตรวจสอบ 3D';

  @override
  String get stPacked => 'แพ็กสำหรับ Studio แล้ว';

  @override
  String get stFailed => 'ล้มเหลว';

  @override
  String get stRejected => 'ถูกปฏิเสธ';

  @override
  String get stRerolled => 'สร้างใหม่แล้ว';

  @override
  String get tapFor3d => 'แตะเพื่อดู 3D';

  @override
  String get pack => 'แพ็ก';

  @override
  String sparkSection(int count) {
    return 'กำลังสร้างบน Spark ($count)';
  }

  @override
  String get sgQueued => 'รออยู่ในคิว';

  @override
  String get sgConcept => 'กำลังวาดคอนเซ็ปต์';

  @override
  String get sgCleanplate => 'กำลังลบพื้นหลัง';

  @override
  String get sgMesh => 'กำลังโมเดล 3D (~4 นาที)';

  @override
  String get sgPush => 'กำลังส่งไป NAS';

  @override
  String get sgDone => 'เสร็จแล้ว';

  @override
  String get sgFailed => 'ล้มเหลว';

  @override
  String get reviewTris => 'สามเหลี่ยม';

  @override
  String get reviewTexture => 'เท็กซ์เจอร์';

  @override
  String get reviewSymmetry => 'สมมาตร';

  @override
  String get yes => 'ใช่';

  @override
  String get no => 'ไม่';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (จุดยอดตะเข็บ: $count)';
  }

  @override
  String get reconvertAgain => 'แปลงใหม่';

  @override
  String get reconvertSymmetry => 'ทำใหม่พร้อมสมมาตร';

  @override
  String get radialMenu => 'ลวดลายรอบด้าน (รัศมี)';

  @override
  String get noSymmetry => 'ไม่มีสมมาตร';

  @override
  String get backToConcept => 'กลับไปที่คอนเซ็ปต์';

  @override
  String get show3d => 'แสดงโมเดล 3D';

  @override
  String get rejectedToast => 'ปฏิเสธแล้ว';

  @override
  String get rerollToast => 'ส่งรีโรลไป Spark แล้ว';

  @override
  String get approvedToast => 'อนุมัติแล้ว → แปลงไฟล์';

  @override
  String errorPrefix(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String get allSorted => 'คัดแยกครบแล้ว ส่งแบตช์ใหม่จาก Composer ไหม';

  @override
  String get newShort => 'ใหม่';

  @override
  String get charactersEmpty =>
      'ยังไม่มีตัวละคร\nเริ่มจากรูปถ่ายหรือภาพของตัวละครรูปร่างมนุษย์';

  @override
  String get newCharacter => 'ตัวละครใหม่';

  @override
  String get creating => 'กำลังสร้าง…';

  @override
  String get generate => 'สร้าง';

  @override
  String get nameLabel => 'ชื่อ';

  @override
  String get prepPhoto => 'เตรียมรูปถ่าย';

  @override
  String get prepPhotoHelp =>
      'ลบพื้นหลัง ถ้าแขนติดกับลำตัวจะแยกออกมาเป็นท่า A และถ้าขาใต้ข้อเท้าขาดไปจะเติมให้ หากไม่ทำ rig มักล้มเหลวกับแขนขาที่ติดกัน';

  @override
  String get animationsLabel => 'แอนิเมชัน';

  @override
  String libraryLoadFailed(String error) {
    return 'โหลดไลบรารีไม่ได้: $error';
  }

  @override
  String get libraryEmpty =>
      'ไลบรารีว่างเปล่า คลิปลงทะเบียนด้วยสคริปต์ seed_animlib.py บน NAS';

  @override
  String get gallery => 'แกลเลอรี';

  @override
  String get camera => 'กล้อง';

  @override
  String get characterFallback => 'ตัวละคร';

  @override
  String get downloadGlb => 'ดาวน์โหลด GLB';

  @override
  String get downloadFbx => 'ดาวน์โหลด FBX';

  @override
  String get downloadZip => 'ดาวน์โหลดทั้งหมด (ZIP)';

  @override
  String get sendRoblox => 'ส่งไป Roblox';

  @override
  String get sendLuanti => 'ส่งไป Luanti';

  @override
  String exportQueued(String target) {
    return 'เพิ่มการส่งออกไป $target เข้าคิวแล้ว';
  }

  @override
  String get clipsTitle => 'คลิป';

  @override
  String get exportsTitle => 'การส่งออก';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ครั้งที่ $attempt)';
  }

  @override
  String get retryStep => 'ลองขั้นตอนอีกครั้ง';

  @override
  String stepOf(int step, int total) {
    return 'ขั้นตอนที่ $step จาก $total';
  }

  @override
  String get cfAccessHelp =>
      'จำเป็นเฉพาะ ugc.ol1n.com (เข้าถึงโดยไม่ใช้ Tailscale)';

  @override
  String get saveAndTest => 'บันทึกและทดสอบ';

  @override
  String connOk(int count) {
    return 'เชื่อมต่อได้ (งานที่โหลด: $count)';
  }

  @override
  String connFailed(String error) {
    return 'ใช้งานไม่ได้: $error';
  }
}
