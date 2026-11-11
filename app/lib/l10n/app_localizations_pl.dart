// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get navQueue => 'Kolejka';

  @override
  String get navCharacters => 'Postacie';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String nasUnavailable(String error) {
    return 'NAS niedostępny: $error';
  }

  @override
  String get promptLabel => 'Prompt przedmiotu';

  @override
  String get categoriesLabel => 'Kategorie';

  @override
  String get catHelmet => 'Hełm';

  @override
  String get catBack => 'Skrzydła / plecy';

  @override
  String get catSword => 'Miecz';

  @override
  String get catFront => 'Napierśnik';

  @override
  String get catHat => 'Czapka';

  @override
  String get catHair => 'Włosy (ryzykowne)';

  @override
  String get styleLabel => 'Styl';

  @override
  String get collectionLabel => 'Kolekcja';

  @override
  String get radialTitle => 'Zdobienie dookoła';

  @override
  String get radialSubtitle => 'symetria promienista – torty, korony';

  @override
  String variantsPerCategory(int count) {
    return 'Wariantów na kategorię: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wygeneruj $count itemu',
      many: 'Wygeneruj $count itemów',
      few: 'Wygeneruj $count itemy',
      one: 'Wygeneruj $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Wysłane zadania: $sent – Spark generuje (~4 min na sztukę, po kolei)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Wysłano: $sent, błędy: $errors';
  }

  @override
  String get queueEmpty =>
      'Na NAS-ie jeszcze nic nie ma – wyślij paczkę z Composera.';

  @override
  String get stNew => 'Czeka na triage';

  @override
  String get stRemeshing => 'Przeliczane w TRELLIS (~4 min)';

  @override
  String get stApproved => 'W kolejce do konwersji';

  @override
  String get stConverting => 'Konwertowanie';

  @override
  String get stConverted => 'Skonwertowano – czeka na przegląd 3D';

  @override
  String get stPacked => 'Spakowano dla Studio';

  @override
  String get stFailed => 'Nie powiodło się';

  @override
  String get stRejected => 'Odrzucono';

  @override
  String get stRerolled => 'Wygenerowano ponownie';

  @override
  String get tapFor3d => 'stuknij, by zobaczyć 3D';

  @override
  String get pack => 'Spakuj';

  @override
  String sparkSection(int count) {
    return 'Powstaje na Sparku ($count)';
  }

  @override
  String get sgQueued => 'czeka w kolejce';

  @override
  String get sgConcept => 'rysuje koncept';

  @override
  String get sgCleanplate => 'usuwa tło';

  @override
  String get sgMesh => 'modeluje w 3D (~4 min)';

  @override
  String get sgPush => 'wysyła na NAS';

  @override
  String get sgDone => 'gotowe';

  @override
  String get sgFailed => 'nie powiodło się';

  @override
  String get reviewTris => 'trójkąty';

  @override
  String get reviewTexture => 'tekstura';

  @override
  String get reviewSymmetry => 'symetria';

  @override
  String get yes => 'tak';

  @override
  String get no => 'nie';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (wierzchołki szwu: $count)';
  }

  @override
  String get reconvertAgain => 'Konwertuj ponownie';

  @override
  String get reconvertSymmetry => 'Jeszcze raz z symetrią';

  @override
  String get radialMenu => 'Zdobienie dookoła (promieniste)';

  @override
  String get noSymmetry => 'Bez symetrii';

  @override
  String get backToConcept => 'Wróć do konceptu';

  @override
  String get show3d => 'Pokaż model 3D';

  @override
  String get rejectedToast => 'Odrzucono';

  @override
  String get rerollToast => 'Reroll wysłany na Spark';

  @override
  String get approvedToast => 'Zatwierdzono → konwersja';

  @override
  String errorPrefix(String error) {
    return 'Błąd: $error';
  }

  @override
  String get allSorted =>
      'Wszystko posortowane. Wysłać nową paczkę z Composera?';

  @override
  String get newShort => 'Nowa';

  @override
  String get charactersEmpty =>
      'Nie ma jeszcze żadnej postaci.\nZacznij od zdjęcia lub obrazka postaci humanoidalnej.';

  @override
  String get newCharacter => 'Nowa postać';

  @override
  String get creating => 'Tworzenie…';

  @override
  String get generate => 'Generuj';

  @override
  String get nameLabel => 'Nazwa';

  @override
  String get prepPhoto => 'Przygotuj zdjęcie';

  @override
  String get prepPhotoHelp =>
      'Usuwa tło; jeśli ręce są przyklejone do ciała, odsuwa je do A-pozy, a jeśli brakuje nóg poniżej kostek, dopowiada je. Bez tego rig często zawodzi przy zrośniętych kończynach.';

  @override
  String get animationsLabel => 'Animacje';

  @override
  String libraryLoadFailed(String error) {
    return 'Nie udało się wczytać biblioteki: $error';
  }

  @override
  String get libraryEmpty =>
      'Biblioteka jest pusta. Klipy rejestruje się skryptem seed_animlib.py na NAS-ie.';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Aparat';

  @override
  String get characterFallback => 'Postać';

  @override
  String get downloadGlb => 'Pobierz GLB';

  @override
  String get downloadFbx => 'Pobierz FBX';

  @override
  String get downloadZip => 'Pobierz wszystko (ZIP)';

  @override
  String get sendRoblox => 'Wyślij do Robloxa';

  @override
  String get sendLuanti => 'Wyślij do Luanti';

  @override
  String exportQueued(String target) {
    return 'Eksport do $target dodany do kolejki';
  }

  @override
  String get clipsTitle => 'Klipy';

  @override
  String get exportsTitle => 'Eksporty';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (próba $attempt)';
  }

  @override
  String get retryStep => 'Ponów krok';

  @override
  String stepOf(int step, int total) {
    return 'krok $step z $total';
  }

  @override
  String get cfAccessHelp =>
      'Potrzebne tylko dla ugc.ol1n.com (dostęp bez Tailscale).';

  @override
  String get saveAndTest => 'Zapisz i sprawdź';

  @override
  String connOk(int count) {
    return 'Połączenie OK (wczytane zadania: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Niedostępne: $error';
  }
}
