// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get navQueue => 'Baris gilir';

  @override
  String get navCharacters => 'Watak';

  @override
  String get navSettings => 'Tetapan';

  @override
  String get retry => 'Cuba lagi';

  @override
  String nasUnavailable(String error) {
    return 'NAS tidak tersedia: $error';
  }

  @override
  String get promptLabel => 'Prompt item';

  @override
  String get categoriesLabel => 'Kategori';

  @override
  String get catHelmet => 'Topi keledar';

  @override
  String get catBack => 'Sayap / belakang';

  @override
  String get catSword => 'Pedang';

  @override
  String get catFront => 'Perisai dada';

  @override
  String get catHat => 'Topi';

  @override
  String get catHair => 'Rambut (berisiko)';

  @override
  String get styleLabel => 'Gaya';

  @override
  String get collectionLabel => 'Koleksi';

  @override
  String get radialTitle => 'Hiasan sekeliling';

  @override
  String get radialSubtitle => 'simetri jejari – kek, mahkota';

  @override
  String variantsPerCategory(int count) {
    return 'Varian setiap kategori: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jana $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tugas dihantar: $sent – Spark sedang menjana (~4 min setiap satu, satu demi satu)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Dihantar: $sent, ralat: $errors';
  }

  @override
  String get queueEmpty =>
      'Belum ada apa-apa pada NAS – hantar kelompok daripada Composer.';

  @override
  String get stNew => 'Menunggu triaj';

  @override
  String get stRemeshing => 'Dikira semula dalam TRELLIS (~4 min)';

  @override
  String get stApproved => 'Dalam baris gilir penukaran';

  @override
  String get stConverting => 'Sedang ditukar';

  @override
  String get stConverted => 'Telah ditukar – menunggu semakan 3D';

  @override
  String get stPacked => 'Dibungkus untuk Studio';

  @override
  String get stFailed => 'Gagal';

  @override
  String get stRejected => 'Ditolak';

  @override
  String get stRerolled => 'Dijana semula';

  @override
  String get tapFor3d => 'ketik untuk 3D';

  @override
  String get pack => 'Bungkus';

  @override
  String sparkSection(int count) {
    return 'Sedang dibuat di Spark ($count)';
  }

  @override
  String get sgQueued => 'menunggu dalam baris gilir';

  @override
  String get sgConcept => 'melukis konsep';

  @override
  String get sgCleanplate => 'membuang latar belakang';

  @override
  String get sgMesh => 'memodel 3D (~4 min)';

  @override
  String get sgPush => 'menghantar ke NAS';

  @override
  String get sgDone => 'siap';

  @override
  String get sgFailed => 'gagal';

  @override
  String get reviewTris => 'segi tiga';

  @override
  String get reviewTexture => 'tekstur';

  @override
  String get reviewSymmetry => 'simetri';

  @override
  String get yes => 'ya';

  @override
  String get no => 'tidak';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (bucu jahitan: $count)';
  }

  @override
  String get reconvertAgain => 'Tukar semula';

  @override
  String get reconvertSymmetry => 'Sekali lagi dengan simetri';

  @override
  String get radialMenu => 'Hiasan sekeliling (jejari)';

  @override
  String get noSymmetry => 'Tanpa simetri';

  @override
  String get backToConcept => 'Kembali ke konsep';

  @override
  String get show3d => 'Tunjuk model 3D';

  @override
  String get rejectedToast => 'Ditolak';

  @override
  String get rerollToast => 'Reroll dihantar ke Spark';

  @override
  String get approvedToast => 'Diluluskan → penukaran';

  @override
  String errorPrefix(String error) {
    return 'Ralat: $error';
  }

  @override
  String get allSorted =>
      'Semua sudah disusun. Hantar kelompok baharu daripada Composer?';

  @override
  String get newShort => 'Baharu';

  @override
  String get charactersEmpty =>
      'Belum ada watak.\nMulakan dengan foto atau gambar watak humanoid.';

  @override
  String get newCharacter => 'Watak baharu';

  @override
  String get creating => 'Mencipta…';

  @override
  String get generate => 'Jana';

  @override
  String get nameLabel => 'Nama';

  @override
  String get prepPhoto => 'Sediakan foto';

  @override
  String get prepPhotoHelp =>
      'Membuang latar belakang; jika lengan melekat pada badan, ia menariknya ke A-pose, dan jika kaki di bawah buku lali tiada, ia melengkapkannya. Tanpa ini rig sering gagal pada anggota badan yang bercantum.';

  @override
  String get animationsLabel => 'Animasi';

  @override
  String libraryLoadFailed(String error) {
    return 'Pustaka tidak dapat dimuatkan: $error';
  }

  @override
  String get libraryEmpty =>
      'Pustaka kosong. Klip didaftarkan dengan skrip seed_animlib.py pada NAS.';

  @override
  String get gallery => 'Galeri';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Watak';

  @override
  String get downloadGlb => 'Muat turun GLB';

  @override
  String get downloadFbx => 'Muat turun FBX';

  @override
  String get downloadZip => 'Muat turun semua (ZIP)';

  @override
  String get sendRoblox => 'Hantar ke Roblox';

  @override
  String get sendLuanti => 'Hantar ke Luanti';

  @override
  String exportQueued(String target) {
    return 'Eksport ke $target dimasukkan ke baris gilir';
  }

  @override
  String get clipsTitle => 'Klip';

  @override
  String get exportsTitle => 'Eksport';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (percubaan $attempt)';
  }

  @override
  String get retryStep => 'Cuba langkah semula';

  @override
  String stepOf(int step, int total) {
    return 'langkah $step daripada $total';
  }

  @override
  String get cfAccessHelp =>
      'Hanya diperlukan untuk ugc.ol1n.com (akses tanpa Tailscale).';

  @override
  String get saveAndTest => 'Simpan dan uji';

  @override
  String connOk(int count) {
    return 'Sambungan OK (tugas dimuatkan: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Tidak tersedia: $error';
  }
}
