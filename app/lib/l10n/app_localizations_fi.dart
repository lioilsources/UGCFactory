// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get navQueue => 'Jono';

  @override
  String get navCharacters => 'Hahmot';

  @override
  String get navSettings => 'Asetukset';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String nasUnavailable(String error) {
    return 'NAS ei ole käytettävissä: $error';
  }

  @override
  String get promptLabel => 'Kohteen prompt';

  @override
  String get categoriesLabel => 'Luokat';

  @override
  String get catHelmet => 'Kypärä';

  @override
  String get catBack => 'Siivet / selkä';

  @override
  String get catSword => 'Miekka';

  @override
  String get catFront => 'Rintapanssari';

  @override
  String get catHat => 'Lakki';

  @override
  String get catHair => 'Hiukset (riskialtis)';

  @override
  String get styleLabel => 'Tyyli';

  @override
  String get collectionLabel => 'Kokoelma';

  @override
  String get radialTitle => 'Koristelu ympäri';

  @override
  String get radialSubtitle => 'säteittäinen symmetria – kakut, kruunut';

  @override
  String variantsPerCategory(int count) {
    return 'Versioita luokkaa kohti: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Luo $count kohdetta',
      one: 'Luo $count kohde',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Lähetetyt työt: $sent – Spark generoi (~4 min kappale, yksi kerrallaan)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Lähetetty: $sent, virheet: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS:lla ei ole vielä mitään – lähetä erä Composerista.';

  @override
  String get stNew => 'Odottaa triagea';

  @override
  String get stRemeshing => 'Lasketaan uudelleen TRELLISissä (~4 min)';

  @override
  String get stApproved => 'Muunnosjonossa';

  @override
  String get stConverting => 'Muunnetaan';

  @override
  String get stConverted => 'Muunnettu – odottaa 3D-tarkistusta';

  @override
  String get stPacked => 'Paketoitu Studiota varten';

  @override
  String get stFailed => 'Epäonnistui';

  @override
  String get stRejected => 'Hylätty';

  @override
  String get stRerolled => 'Luotu uudelleen';

  @override
  String get tapFor3d => 'napauta nähdäksesi 3D';

  @override
  String get pack => 'Paketoi';

  @override
  String sparkSection(int count) {
    return 'Tehdään Sparkilla ($count)';
  }

  @override
  String get sgQueued => 'odottaa jonossa';

  @override
  String get sgConcept => 'piirtää konseptia';

  @override
  String get sgCleanplate => 'poistaa taustaa';

  @override
  String get sgMesh => 'mallintaa 3D:nä (~4 min)';

  @override
  String get sgPush => 'lähettää NAS:lle';

  @override
  String get sgDone => 'valmis';

  @override
  String get sgFailed => 'epäonnistui';

  @override
  String get reviewTris => 'kolmiot';

  @override
  String get reviewTexture => 'tekstuuri';

  @override
  String get reviewSymmetry => 'symmetria';

  @override
  String get yes => 'kyllä';

  @override
  String get no => 'ei';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (saumapisteitä: $count)';
  }

  @override
  String get reconvertAgain => 'Muunna uudelleen';

  @override
  String get reconvertSymmetry => 'Uudelleen symmetrialla';

  @override
  String get radialMenu => 'Koristelu ympäri (säteittäinen)';

  @override
  String get noSymmetry => 'Ei symmetriaa';

  @override
  String get backToConcept => 'Takaisin konseptiin';

  @override
  String get show3d => 'Näytä 3D-malli';

  @override
  String get rejectedToast => 'Hylätty';

  @override
  String get rerollToast => 'Reroll lähetetty Sparkille';

  @override
  String get approvedToast => 'Hyväksytty → muunnos';

  @override
  String errorPrefix(String error) {
    return 'Virhe: $error';
  }

  @override
  String get allSorted =>
      'Kaikki lajiteltu. Lähetetäänkö uusi erä Composerista?';

  @override
  String get newShort => 'Uusi';

  @override
  String get charactersEmpty =>
      'Ei vielä yhtään hahmoa.\nAloita valokuvalla tai kuvalla humanoidihahmosta.';

  @override
  String get newCharacter => 'Uusi hahmo';

  @override
  String get creating => 'Luodaan…';

  @override
  String get generate => 'Luo';

  @override
  String get nameLabel => 'Nimi';

  @override
  String get prepPhoto => 'Valmistele kuva';

  @override
  String get prepPhotoHelp =>
      'Poistaa taustan; jos kädet ovat kiinni kehossa, se vetää ne A-asentoon, ja jos jalat puuttuvat nilkkojen alta, se täydentää ne. Ilman tätä rig epäonnistuu usein yhteen kasvaneilla raajoilla.';

  @override
  String get animationsLabel => 'Animaatiot';

  @override
  String libraryLoadFailed(String error) {
    return 'Kirjastoa ei voitu ladata: $error';
  }

  @override
  String get libraryEmpty =>
      'Kirjasto on tyhjä. Klipit rekisteröidään NAS:n skriptillä seed_animlib.py.';

  @override
  String get gallery => 'Galleria';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Hahmo';

  @override
  String get downloadGlb => 'Lataa GLB';

  @override
  String get downloadFbx => 'Lataa FBX';

  @override
  String get downloadZip => 'Lataa kaikki (ZIP)';

  @override
  String get sendRoblox => 'Lähetä Robloxiin';

  @override
  String get sendLuanti => 'Lähetä Luantiin';

  @override
  String exportQueued(String target) {
    return 'Vienti kohteeseen $target lisätty jonoon';
  }

  @override
  String get clipsTitle => 'Klipit';

  @override
  String get exportsTitle => 'Viennit';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (yritys $attempt)';
  }

  @override
  String get retryStep => 'Yritä vaihetta uudelleen';

  @override
  String stepOf(int step, int total) {
    return 'vaihe $step/$total';
  }

  @override
  String get cfAccessHelp =>
      'Tarvitaan vain osoitteelle ugc.ol1n.com (pääsy ilman Tailscalea).';

  @override
  String get saveAndTest => 'Tallenna ja testaa';

  @override
  String connOk(int count) {
    return 'Yhteys OK (ladattuja töitä: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Ei saatavilla: $error';
  }
}
