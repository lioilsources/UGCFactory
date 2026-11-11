// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navQueue => 'Warteschlange';

  @override
  String get navCharacters => 'Figuren';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String nasUnavailable(String error) {
    return 'NAS nicht erreichbar: $error';
  }

  @override
  String get promptLabel => 'Prompt des Items';

  @override
  String get categoriesLabel => 'Kategorien';

  @override
  String get catHelmet => 'Helm';

  @override
  String get catBack => 'Flügel / Rücken';

  @override
  String get catSword => 'Schwert';

  @override
  String get catFront => 'Brustpanzer';

  @override
  String get catHat => 'Mütze';

  @override
  String get catHair => 'Haare (riskant)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Kollektion';

  @override
  String get radialTitle => 'Rundum-Verzierung';

  @override
  String get radialSubtitle => 'radiale Symmetrie – Torten, Kronen';

  @override
  String variantsPerCategory(int count) {
    return 'Varianten pro Kategorie: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Items generieren',
      one: '$count Item generieren',
    );
    return '$_temp0 (~$minutes Min.)';
  }

  @override
  String composerSent(int sent) {
    return 'Gesendete Aufträge: $sent – Spark generiert (~4 Min. pro Stück, nacheinander)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Gesendet: $sent, Fehler: $errors';
  }

  @override
  String get queueEmpty =>
      'Auf dem NAS ist noch nichts – sende einen Batch aus dem Composer.';

  @override
  String get stNew => 'Wartet auf Triage';

  @override
  String get stRemeshing => 'Wird in TRELLIS neu berechnet (~4 Min.)';

  @override
  String get stApproved => 'In der Warteschlange zur Konvertierung';

  @override
  String get stConverting => 'Wird konvertiert';

  @override
  String get stConverted => 'Konvertiert – wartet auf 3D-Review';

  @override
  String get stPacked => 'Für Studio verpackt';

  @override
  String get stFailed => 'Fehlgeschlagen';

  @override
  String get stRejected => 'Abgelehnt';

  @override
  String get stRerolled => 'Neu gewürfelt';

  @override
  String get tapFor3d => 'tippen für 3D';

  @override
  String get pack => 'Verpacken';

  @override
  String sparkSection(int count) {
    return 'Wird auf Spark erzeugt ($count)';
  }

  @override
  String get sgQueued => 'wartet in der Schlange';

  @override
  String get sgConcept => 'zeichnet das Konzept';

  @override
  String get sgCleanplate => 'entfernt den Hintergrund';

  @override
  String get sgMesh => 'modelliert in 3D (~4 Min.)';

  @override
  String get sgPush => 'sendet an das NAS';

  @override
  String get sgDone => 'fertig';

  @override
  String get sgFailed => 'fehlgeschlagen';

  @override
  String get reviewTris => 'Dreiecke';

  @override
  String get reviewTexture => 'Textur';

  @override
  String get reviewSymmetry => 'Symmetrie';

  @override
  String get yes => 'ja';

  @override
  String get no => 'nein';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (Nahtpunkte: $count)';
  }

  @override
  String get reconvertAgain => 'Erneut konvertieren';

  @override
  String get reconvertSymmetry => 'Nochmal mit Symmetrie';

  @override
  String get radialMenu => 'Rundum-Verzierung (radial)';

  @override
  String get noSymmetry => 'Ohne Symmetrie';

  @override
  String get backToConcept => 'Zurück zum Konzept';

  @override
  String get show3d => '3D-Modell zeigen';

  @override
  String get rejectedToast => 'Abgelehnt';

  @override
  String get rerollToast => 'Reroll an Spark gesendet';

  @override
  String get approvedToast => 'Genehmigt → Konvertierung';

  @override
  String errorPrefix(String error) {
    return 'Fehler: $error';
  }

  @override
  String get allSorted =>
      'Alles sortiert. Einen neuen Batch aus dem Composer senden?';

  @override
  String get newShort => 'Neu';

  @override
  String get charactersEmpty =>
      'Noch keine Figur.\nBeginne mit einem Foto oder Bild einer humanoiden Figur.';

  @override
  String get newCharacter => 'Neue Figur';

  @override
  String get creating => 'Wird angelegt…';

  @override
  String get generate => 'Generieren';

  @override
  String get nameLabel => 'Name';

  @override
  String get prepPhoto => 'Foto vorbereiten';

  @override
  String get prepPhotoHelp =>
      'Entfernt den Hintergrund; sind die Arme am Körper angeklebt, zieht es sie in eine A-Pose, und fehlen die Beine unterhalb der Knöchel, ergänzt es sie. Ohne das scheitert das Rig bei verwachsenen Gliedmaßen oft.';

  @override
  String get animationsLabel => 'Animationen';

  @override
  String libraryLoadFailed(String error) {
    return 'Die Bibliothek konnte nicht geladen werden: $error';
  }

  @override
  String get libraryEmpty =>
      'Die Bibliothek ist leer. Clips werden mit dem Skript seed_animlib.py auf dem NAS registriert.';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Figur';

  @override
  String get downloadGlb => 'GLB herunterladen';

  @override
  String get downloadFbx => 'FBX herunterladen';

  @override
  String get downloadZip => 'Alles herunterladen (ZIP)';

  @override
  String get sendRoblox => 'An Roblox senden';

  @override
  String get sendLuanti => 'An Luanti senden';

  @override
  String exportQueued(String target) {
    return 'Export nach $target eingereiht';
  }

  @override
  String get clipsTitle => 'Clips';

  @override
  String get exportsTitle => 'Exporte';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (Versuch $attempt)';
  }

  @override
  String get retryStep => 'Schritt erneut versuchen';

  @override
  String stepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get cfAccessHelp =>
      'Nur für ugc.ol1n.com nötig (Zugriff ohne Tailscale).';

  @override
  String get saveAndTest => 'Speichern und testen';

  @override
  String connOk(int count) {
    return 'Verbindung OK (geladene Aufträge: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Nicht erreichbar: $error';
  }
}
