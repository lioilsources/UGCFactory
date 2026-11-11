// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navQueue => 'Coda';

  @override
  String get navCharacters => 'Personaggi';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get retry => 'Riprova';

  @override
  String nasUnavailable(String error) {
    return 'NAS non disponibile: $error';
  }

  @override
  String get promptLabel => 'Prompt dell\'item';

  @override
  String get categoriesLabel => 'Categorie';

  @override
  String get catHelmet => 'Elmo';

  @override
  String get catBack => 'Ali / schiena';

  @override
  String get catSword => 'Spada';

  @override
  String get catFront => 'Corazza';

  @override
  String get catHat => 'Berretto';

  @override
  String get catHair => 'Capelli (rischioso)';

  @override
  String get styleLabel => 'Stile';

  @override
  String get collectionLabel => 'Collezione';

  @override
  String get radialTitle => 'Decorazione tutto intorno';

  @override
  String get radialSubtitle => 'simmetria radiale – torte, corone';

  @override
  String variantsPerCategory(int count) {
    return 'Varianti per categoria: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Genera $count item',
      one: 'Genera $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Lavori inviati: $sent – Spark sta generando (~4 min a pezzo, uno alla volta)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Inviati: $sent, errori: $errors';
  }

  @override
  String get queueEmpty =>
      'Ancora niente sul NAS – invia un lotto dal Composer.';

  @override
  String get stNew => 'In attesa di triage';

  @override
  String get stRemeshing => 'In ricalcolo in TRELLIS (~4 min)';

  @override
  String get stApproved => 'In coda per la conversione';

  @override
  String get stConverting => 'In conversione';

  @override
  String get stConverted => 'Convertito – in attesa della revisione 3D';

  @override
  String get stPacked => 'Impacchettato per Studio';

  @override
  String get stFailed => 'Non riuscito';

  @override
  String get stRejected => 'Rifiutato';

  @override
  String get stRerolled => 'Rigenerato';

  @override
  String get tapFor3d => 'tocca per il 3D';

  @override
  String get pack => 'Impacchetta';

  @override
  String sparkSection(int count) {
    return 'In produzione su Spark ($count)';
  }

  @override
  String get sgQueued => 'in attesa in coda';

  @override
  String get sgConcept => 'disegna il concept';

  @override
  String get sgCleanplate => 'rimuove lo sfondo';

  @override
  String get sgMesh => 'modella in 3D (~4 min)';

  @override
  String get sgPush => 'invia al NAS';

  @override
  String get sgDone => 'fatto';

  @override
  String get sgFailed => 'non riuscito';

  @override
  String get reviewTris => 'triangoli';

  @override
  String get reviewTexture => 'texture';

  @override
  String get reviewSymmetry => 'simmetria';

  @override
  String get yes => 'sì';

  @override
  String get no => 'no';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vertici di cucitura: $count)';
  }

  @override
  String get reconvertAgain => 'Converti di nuovo';

  @override
  String get reconvertSymmetry => 'Di nuovo con simmetria';

  @override
  String get radialMenu => 'Decorazione tutto intorno (radiale)';

  @override
  String get noSymmetry => 'Senza simmetria';

  @override
  String get backToConcept => 'Torna al concept';

  @override
  String get show3d => 'Mostra il modello 3D';

  @override
  String get rejectedToast => 'Rifiutato';

  @override
  String get rerollToast => 'Reroll inviato a Spark';

  @override
  String get approvedToast => 'Approvato → conversione';

  @override
  String errorPrefix(String error) {
    return 'Errore: $error';
  }

  @override
  String get allSorted =>
      'Tutto smistato. Inviare un nuovo lotto dal Composer?';

  @override
  String get newShort => 'Nuovo';

  @override
  String get charactersEmpty =>
      'Ancora nessun personaggio.\nInizia con una foto o un\'immagine di un personaggio umanoide.';

  @override
  String get newCharacter => 'Nuovo personaggio';

  @override
  String get creating => 'Creazione…';

  @override
  String get generate => 'Genera';

  @override
  String get nameLabel => 'Nome';

  @override
  String get prepPhoto => 'Prepara la foto';

  @override
  String get prepPhotoHelp =>
      'Rimuove lo sfondo; se le braccia sono attaccate al corpo le allontana in una A-pose, e se mancano le gambe sotto le caviglie le completa. Senza questo il rig spesso fallisce con arti fusi.';

  @override
  String get animationsLabel => 'Animazioni';

  @override
  String libraryLoadFailed(String error) {
    return 'Impossibile caricare la libreria: $error';
  }

  @override
  String get libraryEmpty =>
      'La libreria è vuota. I clip si registrano con lo script seed_animlib.py sul NAS.';

  @override
  String get gallery => 'Galleria';

  @override
  String get camera => 'Fotocamera';

  @override
  String get characterFallback => 'Personaggio';

  @override
  String get downloadGlb => 'Scarica GLB';

  @override
  String get downloadFbx => 'Scarica FBX';

  @override
  String get downloadZip => 'Scarica tutto (ZIP)';

  @override
  String get sendRoblox => 'Invia a Roblox';

  @override
  String get sendLuanti => 'Invia a Luanti';

  @override
  String exportQueued(String target) {
    return 'Esportazione verso $target in coda';
  }

  @override
  String get clipsTitle => 'Clip';

  @override
  String get exportsTitle => 'Esportazioni';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (tentativo $attempt)';
  }

  @override
  String get retryStep => 'Riprova il passaggio';

  @override
  String stepOf(int step, int total) {
    return 'passaggio $step di $total';
  }

  @override
  String get cfAccessHelp =>
      'Serve solo per ugc.ol1n.com (accesso senza Tailscale).';

  @override
  String get saveAndTest => 'Salva e verifica';

  @override
  String connOk(int count) {
    return 'Connessione OK (lavori caricati: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Non disponibile: $error';
  }
}
