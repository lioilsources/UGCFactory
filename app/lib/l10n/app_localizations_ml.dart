// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get navQueue => 'ക്യൂ';

  @override
  String get navCharacters => 'കഥാപാത്രങ്ങൾ';

  @override
  String get navSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String nasUnavailable(String error) {
    return 'NAS ലഭ്യമല്ല: $error';
  }

  @override
  String get promptLabel => 'ഇനത്തിന്റെ പ്രോംപ്റ്റ്';

  @override
  String get categoriesLabel => 'വിഭാഗങ്ങൾ';

  @override
  String get catHelmet => 'ഹെൽമെറ്റ്';

  @override
  String get catBack => 'ചിറകുകൾ / പുറം';

  @override
  String get catSword => 'വാൾ';

  @override
  String get catFront => 'നെഞ്ചുകവചം';

  @override
  String get catHat => 'തൊപ്പി';

  @override
  String get catHair => 'മുടി (അപകടസാധ്യത)';

  @override
  String get styleLabel => 'ശൈലി';

  @override
  String get collectionLabel => 'ശേഖരം';

  @override
  String get radialTitle => 'ചുറ്റും അലങ്കാരം';

  @override
  String get radialSubtitle => 'റേഡിയൽ സമമിതി – കേക്കുകൾ, കിരീടങ്ങൾ';

  @override
  String variantsPerCategory(int count) {
    return 'ഓരോ വിഭാഗത്തിനും വകഭേദങ്ങൾ: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഇനങ്ങൾ സൃഷ്ടിക്കുക',
      one: '$count ഇനം സൃഷ്ടിക്കുക',
    );
    return '$_temp0 (~$minutes മിനിറ്റ്)';
  }

  @override
  String composerSent(int sent) {
    return 'അയച്ച ജോലികൾ: $sent – Spark സൃഷ്ടിക്കുന്നു (~ഓരോന്നിനും 4 മിനിറ്റ്, ഒന്നിനുപിന്നാലെ ഒന്ന്)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'അയച്ചത്: $sent, പിശകുകൾ: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS-ൽ ഇതുവരെ ഒന്നുമില്ല – Composer-ൽ നിന്ന് ബാച്ച് അയയ്ക്കുക.';

  @override
  String get stNew => 'ട്രയാജിനായി കാത്തിരിക്കുന്നു';

  @override
  String get stRemeshing => 'TRELLIS-ൽ വീണ്ടും കണക്കാക്കുന്നു (~4 മിനിറ്റ്)';

  @override
  String get stApproved => 'പരിവർത്തന ക്യൂവിൽ';

  @override
  String get stConverting => 'പരിവർത്തനം ചെയ്യുന്നു';

  @override
  String get stConverted =>
      'പരിവർത്തനം ചെയ്തു – 3D അവലോകനത്തിനായി കാത്തിരിക്കുന്നു';

  @override
  String get stPacked => 'Studio-യ്ക്കായി പാക്ക് ചെയ്തു';

  @override
  String get stFailed => 'പരാജയപ്പെട്ടു';

  @override
  String get stRejected => 'നിരസിച്ചു';

  @override
  String get stRerolled => 'വീണ്ടും സൃഷ്ടിച്ചു';

  @override
  String get tapFor3d => '3D കാണാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get pack => 'പാക്ക് ചെയ്യുക';

  @override
  String sparkSection(int count) {
    return 'Spark-ൽ നിർമ്മിക്കുന്നു ($count)';
  }

  @override
  String get sgQueued => 'ക്യൂവിൽ കാത്തിരിക്കുന്നു';

  @override
  String get sgConcept => 'ആശയം വരയ്ക്കുന്നു';

  @override
  String get sgCleanplate => 'പശ്ചാത്തലം നീക്കുന്നു';

  @override
  String get sgMesh => '3D മോഡലിംഗ് (~4 മിനിറ്റ്)';

  @override
  String get sgPush => 'NAS-ലേക്ക് അയയ്ക്കുന്നു';

  @override
  String get sgDone => 'പൂർത്തിയായി';

  @override
  String get sgFailed => 'പരാജയപ്പെട്ടു';

  @override
  String get reviewTris => 'ത്രികോണങ്ങൾ';

  @override
  String get reviewTexture => 'ടെക്സ്ചർ';

  @override
  String get reviewSymmetry => 'സമമിതി';

  @override
  String get yes => 'അതെ';

  @override
  String get no => 'അല്ല';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (തുന്നൽ ശീർഷങ്ങൾ: $count)';
  }

  @override
  String get reconvertAgain => 'വീണ്ടും പരിവർത്തനം ചെയ്യുക';

  @override
  String get reconvertSymmetry => 'സമമിതിയോടെ വീണ്ടും';

  @override
  String get radialMenu => 'ചുറ്റും അലങ്കാരം (റേഡിയൽ)';

  @override
  String get noSymmetry => 'സമമിതി ഇല്ലാതെ';

  @override
  String get backToConcept => 'ആശയത്തിലേക്ക് മടങ്ങുക';

  @override
  String get show3d => '3D മോഡൽ കാണിക്കുക';

  @override
  String get rejectedToast => 'നിരസിച്ചു';

  @override
  String get rerollToast => 'റീറോൾ Spark-ലേക്ക് അയച്ചു';

  @override
  String get approvedToast => 'അംഗീകരിച്ചു → പരിവർത്തനം';

  @override
  String errorPrefix(String error) {
    return 'പിശക്: $error';
  }

  @override
  String get allSorted =>
      'എല്ലാം തരംതിരിച്ചു. Composer-ൽ നിന്ന് പുതിയ ബാച്ച് അയയ്ക്കണോ?';

  @override
  String get newShort => 'പുതിയത്';

  @override
  String get charactersEmpty =>
      'ഇതുവരെ കഥാപാത്രങ്ങളില്ല.\nമനുഷ്യരൂപമുള്ള കഥാപാത്രത്തിന്റെ ഫോട്ടോയിൽ നിന്നോ ചിത്രത്തിൽ നിന്നോ തുടങ്ങുക.';

  @override
  String get newCharacter => 'പുതിയ കഥാപാത്രം';

  @override
  String get creating => 'സൃഷ്ടിക്കുന്നു…';

  @override
  String get generate => 'സൃഷ്ടിക്കുക';

  @override
  String get nameLabel => 'പേര്';

  @override
  String get prepPhoto => 'ഫോട്ടോ തയ്യാറാക്കുക';

  @override
  String get prepPhotoHelp =>
      'പശ്ചാത്തലം നീക്കുന്നു; കൈകൾ ശരീരത്തോട് ഒട്ടിയിരുന്നാൽ A-പോസിലേക്ക് മാറ്റുന്നു, കണങ്കാലിനു താഴെ കാലുകൾ ഇല്ലെങ്കിൽ അവ പൂരിപ്പിക്കുന്നു. ഇതില്ലാതെ ഒട്ടിച്ചേർന്ന അവയവങ്ങളിൽ റിഗ് പലപ്പോഴും പരാജയപ്പെടും.';

  @override
  String get animationsLabel => 'ആനിമേഷനുകൾ';

  @override
  String libraryLoadFailed(String error) {
    return 'ലൈബ്രറി ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get libraryEmpty =>
      'ലൈബ്രറി ശൂന്യമാണ്. ക്ലിപ്പുകൾ NAS-ലെ seed_animlib.py സ്ക്രിപ്റ്റ് ഉപയോഗിച്ച് രജിസ്റ്റർ ചെയ്യുന്നു.';

  @override
  String get gallery => 'ഗാലറി';

  @override
  String get camera => 'ക്യാമറ';

  @override
  String get characterFallback => 'കഥാപാത്രം';

  @override
  String get downloadGlb => 'GLB ഡൗൺലോഡ്';

  @override
  String get downloadFbx => 'FBX ഡൗൺലോഡ്';

  @override
  String get downloadZip => 'എല്ലാം ഡൗൺലോഡ് (ZIP)';

  @override
  String get sendRoblox => 'Roblox-ലേക്ക് അയയ്ക്കുക';

  @override
  String get sendLuanti => 'Luanti-ലേക്ക് അയയ്ക്കുക';

  @override
  String exportQueued(String target) {
    return '$target-ലേക്കുള്ള എക്സ്പോർട്ട് ക്യൂവിൽ ചേർത്തു';
  }

  @override
  String get clipsTitle => 'ക്ലിപ്പുകൾ';

  @override
  String get exportsTitle => 'എക്സ്പോർട്ടുകൾ';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ശ്രമം $attempt)';
  }

  @override
  String get retryStep => 'ഘട്ടം വീണ്ടും ശ്രമിക്കുക';

  @override
  String stepOf(int step, int total) {
    return 'ഘട്ടം $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'ugc.ol1n.com-ന് മാത്രം ആവശ്യമാണ് (Tailscale ഇല്ലാതെ ആക്സസ്).';

  @override
  String get saveAndTest => 'സേവ് ചെയ്ത് പരിശോധിക്കുക';

  @override
  String connOk(int count) {
    return 'കണക്ഷൻ ശരി (ലോഡ് ചെയ്ത ജോലികൾ: $count)';
  }

  @override
  String connFailed(String error) {
    return 'ലഭ്യമല്ല: $error';
  }
}
