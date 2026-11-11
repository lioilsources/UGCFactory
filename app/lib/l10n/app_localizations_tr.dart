// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get navQueue => 'Kuyruk';

  @override
  String get navCharacters => 'Karakterler';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get retry => 'Tekrar dene';

  @override
  String nasUnavailable(String error) {
    return 'NAS kullanılamıyor: $error';
  }

  @override
  String get promptLabel => 'Öğe istemi';

  @override
  String get categoriesLabel => 'Kategoriler';

  @override
  String get catHelmet => 'Miğfer';

  @override
  String get catBack => 'Kanatlar / sırt';

  @override
  String get catSword => 'Kılıç';

  @override
  String get catFront => 'Göğüslük';

  @override
  String get catHat => 'Bere';

  @override
  String get catHair => 'Saç (riskli)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Koleksiyon';

  @override
  String get radialTitle => 'Etrafı saran süsleme';

  @override
  String get radialSubtitle => 'radyal simetri – pastalar, taçlar';

  @override
  String variantsPerCategory(int count) {
    return 'Kategori başına varyant: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe üret',
      one: '$count öğe üret',
    );
    return '$_temp0 (~$minutes dk)';
  }

  @override
  String composerSent(int sent) {
    return 'Gönderilen işler: $sent – Spark üretiyor (parça başına ~4 dk, sırayla)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Gönderilen: $sent, hatalar: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS\'ta henüz bir şey yok – Composer\'dan bir toplu iş gönderin.';

  @override
  String get stNew => 'Triyaj bekliyor';

  @override
  String get stRemeshing => 'TRELLIS\'te yeniden hesaplanıyor (~4 dk)';

  @override
  String get stApproved => 'Dönüştürme kuyruğunda';

  @override
  String get stConverting => 'Dönüştürülüyor';

  @override
  String get stConverted => 'Dönüştürüldü – 3D incelemesi bekliyor';

  @override
  String get stPacked => 'Studio için paketlendi';

  @override
  String get stFailed => 'Başarısız';

  @override
  String get stRejected => 'Reddedildi';

  @override
  String get stRerolled => 'Yeniden üretildi';

  @override
  String get tapFor3d => '3D için dokunun';

  @override
  String get pack => 'Paketle';

  @override
  String sparkSection(int count) {
    return 'Spark\'ta üretiliyor ($count)';
  }

  @override
  String get sgQueued => 'kuyrukta bekliyor';

  @override
  String get sgConcept => 'konsepti çiziyor';

  @override
  String get sgCleanplate => 'arka planı kaldırıyor';

  @override
  String get sgMesh => '3D modelliyor (~4 dk)';

  @override
  String get sgPush => 'NAS\'a gönderiyor';

  @override
  String get sgDone => 'bitti';

  @override
  String get sgFailed => 'başarısız';

  @override
  String get reviewTris => 'üçgenler';

  @override
  String get reviewTexture => 'doku';

  @override
  String get reviewSymmetry => 'simetri';

  @override
  String get yes => 'evet';

  @override
  String get no => 'hayır';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (dikiş köşeleri: $count)';
  }

  @override
  String get reconvertAgain => 'Yeniden dönüştür';

  @override
  String get reconvertSymmetry => 'Simetriyle yeniden';

  @override
  String get radialMenu => 'Etrafı saran süsleme (radyal)';

  @override
  String get noSymmetry => 'Simetri yok';

  @override
  String get backToConcept => 'Konsepte dön';

  @override
  String get show3d => '3D modeli göster';

  @override
  String get rejectedToast => 'Reddedildi';

  @override
  String get rerollToast => 'Reroll Spark\'a gönderildi';

  @override
  String get approvedToast => 'Onaylandı → dönüştürme';

  @override
  String errorPrefix(String error) {
    return 'Hata: $error';
  }

  @override
  String get allSorted =>
      'Hepsi ayıklandı. Composer\'dan yeni bir toplu iş gönderilsin mi?';

  @override
  String get newShort => 'Yeni';

  @override
  String get charactersEmpty =>
      'Henüz karakter yok.\nİnsansı bir karakterin fotoğrafı veya görseliyle başlayın.';

  @override
  String get newCharacter => 'Yeni karakter';

  @override
  String get creating => 'Oluşturuluyor…';

  @override
  String get generate => 'Üret';

  @override
  String get nameLabel => 'Ad';

  @override
  String get prepPhoto => 'Fotoğrafı hazırla';

  @override
  String get prepPhotoHelp =>
      'Arka planı kaldırır; kollar gövdeye yapışıksa onları A-pozuna açar, bilek altında bacaklar eksikse tamamlar. Bu olmadan, kaynaşmış uzuvlarda rig sık sık başarısız olur.';

  @override
  String get animationsLabel => 'Animasyonlar';

  @override
  String libraryLoadFailed(String error) {
    return 'Kütüphane yüklenemedi: $error';
  }

  @override
  String get libraryEmpty =>
      'Kütüphane boş. Klipler NAS\'ta seed_animlib.py betiğiyle kaydedilir.';

  @override
  String get gallery => 'Galeri';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Karakter';

  @override
  String get downloadGlb => 'GLB indir';

  @override
  String get downloadFbx => 'FBX indir';

  @override
  String get downloadZip => 'Hepsini indir (ZIP)';

  @override
  String get sendRoblox => 'Roblox\'a gönder';

  @override
  String get sendLuanti => 'Luanti\'ye gönder';

  @override
  String exportQueued(String target) {
    return '$target dışa aktarımı kuyruğa alındı';
  }

  @override
  String get clipsTitle => 'Klipler';

  @override
  String get exportsTitle => 'Dışa aktarımlar';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step ($attempt. deneme)';
  }

  @override
  String get retryStep => 'Adımı tekrar dene';

  @override
  String stepOf(int step, int total) {
    return 'adım $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'Yalnızca ugc.ol1n.com için gerekir (Tailscale olmadan erişim).';

  @override
  String get saveAndTest => 'Kaydet ve sına';

  @override
  String connOk(int count) {
    return 'Bağlantı tamam (yüklenen işler: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Kullanılamıyor: $error';
  }
}
