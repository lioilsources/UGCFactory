// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navQueue => 'Antrean';

  @override
  String get navCharacters => 'Karakter';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get retry => 'Coba lagi';

  @override
  String nasUnavailable(String error) {
    return 'NAS tidak tersedia: $error';
  }

  @override
  String get promptLabel => 'Prompt item';

  @override
  String get categoriesLabel => 'Kategori';

  @override
  String get catHelmet => 'Helm';

  @override
  String get catBack => 'Sayap / punggung';

  @override
  String get catSword => 'Pedang';

  @override
  String get catFront => 'Pelindung dada';

  @override
  String get catHat => 'Topi';

  @override
  String get catHair => 'Rambut (berisiko)';

  @override
  String get styleLabel => 'Gaya';

  @override
  String get collectionLabel => 'Koleksi';

  @override
  String get radialTitle => 'Hiasan di sekeliling';

  @override
  String get radialSubtitle => 'simetri radial – kue, mahkota';

  @override
  String variantsPerCategory(int count) {
    return 'Varian per kategori: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buat $count item',
    );
    return '$_temp0 (~$minutes mnt)';
  }

  @override
  String composerSent(int sent) {
    return 'Tugas terkirim: $sent – Spark sedang membuat (~4 menit per buah, satu per satu)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Terkirim: $sent, kesalahan: $errors';
  }

  @override
  String get queueEmpty =>
      'Belum ada apa pun di NAS – kirim batch dari Composer.';

  @override
  String get stNew => 'Menunggu triase';

  @override
  String get stRemeshing => 'Dihitung ulang di TRELLIS (~4 menit)';

  @override
  String get stApproved => 'Dalam antrean konversi';

  @override
  String get stConverting => 'Sedang dikonversi';

  @override
  String get stConverted => 'Terkonversi – menunggu tinjauan 3D';

  @override
  String get stPacked => 'Dikemas untuk Studio';

  @override
  String get stFailed => 'Gagal';

  @override
  String get stRejected => 'Ditolak';

  @override
  String get stRerolled => 'Dibuat ulang';

  @override
  String get tapFor3d => 'ketuk untuk 3D';

  @override
  String get pack => 'Kemas';

  @override
  String sparkSection(int count) {
    return 'Sedang dibuat di Spark ($count)';
  }

  @override
  String get sgQueued => 'menunggu dalam antrean';

  @override
  String get sgConcept => 'menggambar konsep';

  @override
  String get sgCleanplate => 'menghapus latar belakang';

  @override
  String get sgMesh => 'memodelkan 3D (~4 menit)';

  @override
  String get sgPush => 'mengirim ke NAS';

  @override
  String get sgDone => 'selesai';

  @override
  String get sgFailed => 'gagal';

  @override
  String get reviewTris => 'segitiga';

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
    return '$symmetry (titik sambungan: $count)';
  }

  @override
  String get reconvertAgain => 'Konversi ulang';

  @override
  String get reconvertSymmetry => 'Ulangi dengan simetri';

  @override
  String get radialMenu => 'Hiasan di sekeliling (radial)';

  @override
  String get noSymmetry => 'Tanpa simetri';

  @override
  String get backToConcept => 'Kembali ke konsep';

  @override
  String get show3d => 'Tampilkan model 3D';

  @override
  String get rejectedToast => 'Ditolak';

  @override
  String get rerollToast => 'Reroll dikirim ke Spark';

  @override
  String get approvedToast => 'Disetujui → konversi';

  @override
  String errorPrefix(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get allSorted =>
      'Semua sudah dipilah. Kirim batch baru dari Composer?';

  @override
  String get newShort => 'Baru';

  @override
  String get charactersEmpty =>
      'Belum ada karakter.\nMulailah dengan foto atau gambar karakter humanoid.';

  @override
  String get newCharacter => 'Karakter baru';

  @override
  String get creating => 'Membuat…';

  @override
  String get generate => 'Buat';

  @override
  String get nameLabel => 'Nama';

  @override
  String get prepPhoto => 'Siapkan foto';

  @override
  String get prepPhotoHelp =>
      'Menghapus latar belakang; jika lengan menempel di badan, ditarik ke A-pose, dan jika kaki di bawah pergelangan tidak ada, dilengkapi. Tanpa ini rig sering gagal pada anggota tubuh yang menyatu.';

  @override
  String get animationsLabel => 'Animasi';

  @override
  String libraryLoadFailed(String error) {
    return 'Pustaka tidak dapat dimuat: $error';
  }

  @override
  String get libraryEmpty =>
      'Pustaka kosong. Klip didaftarkan dengan skrip seed_animlib.py di NAS.';

  @override
  String get gallery => 'Galeri';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Karakter';

  @override
  String get downloadGlb => 'Unduh GLB';

  @override
  String get downloadFbx => 'Unduh FBX';

  @override
  String get downloadZip => 'Unduh semua (ZIP)';

  @override
  String get sendRoblox => 'Kirim ke Roblox';

  @override
  String get sendLuanti => 'Kirim ke Luanti';

  @override
  String exportQueued(String target) {
    return 'Ekspor ke $target masuk antrean';
  }

  @override
  String get clipsTitle => 'Klip';

  @override
  String get exportsTitle => 'Ekspor';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (percobaan $attempt)';
  }

  @override
  String get retryStep => 'Coba langkah lagi';

  @override
  String stepOf(int step, int total) {
    return 'langkah $step dari $total';
  }

  @override
  String get cfAccessHelp =>
      'Hanya diperlukan untuk ugc.ol1n.com (akses tanpa Tailscale).';

  @override
  String get saveAndTest => 'Simpan dan uji';

  @override
  String connOk(int count) {
    return 'Koneksi OK (tugas dimuat: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Tidak tersedia: $error';
  }
}
