// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get navQueue => 'క్యూ';

  @override
  String get navCharacters => 'పాత్రలు';

  @override
  String get navSettings => 'సెట్టింగ్‌లు';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String nasUnavailable(String error) {
    return 'NAS అందుబాటులో లేదు: $error';
  }

  @override
  String get promptLabel => 'వస్తువు ప్రాంప్ట్';

  @override
  String get categoriesLabel => 'వర్గాలు';

  @override
  String get catHelmet => 'హెల్మెట్';

  @override
  String get catBack => 'రెక్కలు / వీపు';

  @override
  String get catSword => 'ఖడ్గం';

  @override
  String get catFront => 'ఛాతీ కవచం';

  @override
  String get catHat => 'టోపీ';

  @override
  String get catHair => 'జుట్టు (ప్రమాదకరం)';

  @override
  String get styleLabel => 'శైలి';

  @override
  String get collectionLabel => 'సేకరణ';

  @override
  String get radialTitle => 'చుట్టూ అలంకరణ';

  @override
  String get radialSubtitle => 'రేడియల్ సౌష్టవం – కేకులు, కిరీటాలు';

  @override
  String variantsPerCategory(int count) {
    return 'ప్రతి వర్గానికి వేరియంట్లు: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వస్తువులను సృష్టించండి',
      one: '$count వస్తువును సృష్టించండి',
    );
    return '$_temp0 (~$minutes నిమి)';
  }

  @override
  String composerSent(int sent) {
    return 'పంపిన పనులు: $sent – Spark సృష్టిస్తోంది (~ఒక్కొక్కటికి 4 నిమిషాలు, ఒకదాని తర్వాత ఒకటి)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'పంపినవి: $sent, లోపాలు: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS లో ఇంకా ఏమీ లేదు – Composer నుండి బ్యాచ్ పంపండి.';

  @override
  String get stNew => 'ట్రయాజ్ కోసం వేచి ఉంది';

  @override
  String get stRemeshing => 'TRELLIS లో మళ్లీ లెక్కిస్తోంది (~4 నిమిషాలు)';

  @override
  String get stApproved => 'మార్పిడి క్యూలో';

  @override
  String get stConverting => 'మార్చబడుతోంది';

  @override
  String get stConverted => 'మార్చబడింది – 3D సమీక్ష కోసం వేచి ఉంది';

  @override
  String get stPacked => 'Studio కోసం ప్యాక్ చేయబడింది';

  @override
  String get stFailed => 'విఫలమైంది';

  @override
  String get stRejected => 'తిరస్కరించబడింది';

  @override
  String get stRerolled => 'మళ్లీ సృష్టించబడింది';

  @override
  String get tapFor3d => '3D కోసం ట్యాప్ చేయండి';

  @override
  String get pack => 'ప్యాక్ చేయండి';

  @override
  String sparkSection(int count) {
    return 'Spark లో తయారవుతున్నాయి ($count)';
  }

  @override
  String get sgQueued => 'క్యూలో వేచి ఉంది';

  @override
  String get sgConcept => 'కాన్సెప్ట్ గీస్తోంది';

  @override
  String get sgCleanplate => 'నేపథ్యం తొలగిస్తోంది';

  @override
  String get sgMesh => '3D మోడలింగ్ (~4 నిమిషాలు)';

  @override
  String get sgPush => 'NAS కు పంపుతోంది';

  @override
  String get sgDone => 'పూర్తయింది';

  @override
  String get sgFailed => 'విఫలమైంది';

  @override
  String get reviewTris => 'త్రిభుజాలు';

  @override
  String get reviewTexture => 'టెక్స్చర్';

  @override
  String get reviewSymmetry => 'సౌష్టవం';

  @override
  String get yes => 'అవును';

  @override
  String get no => 'కాదు';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (కుట్టు శీర్షాలు: $count)';
  }

  @override
  String get reconvertAgain => 'మళ్లీ మార్చండి';

  @override
  String get reconvertSymmetry => 'సౌష్టవంతో మళ్లీ';

  @override
  String get radialMenu => 'చుట్టూ అలంకరణ (రేడియల్)';

  @override
  String get noSymmetry => 'సౌష్టవం లేకుండా';

  @override
  String get backToConcept => 'కాన్సెప్ట్‌కు తిరిగి';

  @override
  String get show3d => '3D మోడల్ చూపించు';

  @override
  String get rejectedToast => 'తిరస్కరించబడింది';

  @override
  String get rerollToast => 'రీరోల్ Spark కు పంపబడింది';

  @override
  String get approvedToast => 'ఆమోదించబడింది → మార్పిడి';

  @override
  String errorPrefix(String error) {
    return 'లోపం: $error';
  }

  @override
  String get allSorted =>
      'అన్నీ క్రమబద్ధీకరించబడ్డాయి. Composer నుండి కొత్త బ్యాచ్ పంపాలా?';

  @override
  String get newShort => 'కొత్త';

  @override
  String get charactersEmpty =>
      'ఇంకా పాత్రలు లేవు.\nమానవాకృతి పాత్ర ఫోటో లేదా చిత్రంతో ప్రారంభించండి.';

  @override
  String get newCharacter => 'కొత్త పాత్ర';

  @override
  String get creating => 'సృష్టిస్తోంది…';

  @override
  String get generate => 'సృష్టించండి';

  @override
  String get nameLabel => 'పేరు';

  @override
  String get prepPhoto => 'ఫోటోను సిద్ధం చేయండి';

  @override
  String get prepPhotoHelp =>
      'నేపథ్యాన్ని తొలగిస్తుంది; చేతులు శరీరానికి అతుక్కుని ఉంటే వాటిని A-పోజ్‌కు లాగుతుంది, చీలమండల కింద కాళ్లు లేకపోతే వాటిని పూరిస్తుంది. ఇది లేకుండా కలిసిపోయిన అవయవాలపై రిగ్ తరచూ విఫలమవుతుంది.';

  @override
  String get animationsLabel => 'యానిమేషన్‌లు';

  @override
  String libraryLoadFailed(String error) {
    return 'లైబ్రరీని లోడ్ చేయలేకపోయాం: $error';
  }

  @override
  String get libraryEmpty =>
      'లైబ్రరీ ఖాళీగా ఉంది. క్లిప్‌లు NAS లో seed_animlib.py స్క్రిప్ట్‌తో నమోదు చేయబడతాయి.';

  @override
  String get gallery => 'గ్యాలరీ';

  @override
  String get camera => 'కెమెరా';

  @override
  String get characterFallback => 'పాత్ర';

  @override
  String get downloadGlb => 'GLB డౌన్‌లోడ్';

  @override
  String get downloadFbx => 'FBX డౌన్‌లోడ్';

  @override
  String get downloadZip => 'అన్నీ డౌన్‌లోడ్ (ZIP)';

  @override
  String get sendRoblox => 'Roblox కు పంపండి';

  @override
  String get sendLuanti => 'Luanti కు పంపండి';

  @override
  String exportQueued(String target) {
    return '$target కు ఎగుమతి క్యూలో చేర్చబడింది';
  }

  @override
  String get clipsTitle => 'క్లిప్‌లు';

  @override
  String get exportsTitle => 'ఎగుమతులు';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ప్రయత్నం $attempt)';
  }

  @override
  String get retryStep => 'దశను మళ్లీ ప్రయత్నించండి';

  @override
  String stepOf(int step, int total) {
    return 'దశ $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'ugc.ol1n.com కు మాత్రమే అవసరం (Tailscale లేకుండా యాక్సెస్).';

  @override
  String get saveAndTest => 'సేవ్ చేసి పరీక్షించండి';

  @override
  String connOk(int count) {
    return 'కనెక్షన్ సరిగ్గా ఉంది (లోడ్ అయిన పనులు: $count)';
  }

  @override
  String connFailed(String error) {
    return 'అందుబాటులో లేదు: $error';
  }
}
