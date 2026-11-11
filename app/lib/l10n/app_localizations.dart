import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nb'),
    Locale('nl'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @navQueue.
  ///
  /// In cs, this message translates to:
  /// **'Fronta'**
  String get navQueue;

  /// No description provided for @navCharacters.
  ///
  /// In cs, this message translates to:
  /// **'Postavy'**
  String get navCharacters;

  /// No description provided for @navSettings.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get navSettings;

  /// No description provided for @retry.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get retry;

  /// No description provided for @nasUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'NAS nedostupný: {error}'**
  String nasUnavailable(String error);

  /// No description provided for @promptLabel.
  ///
  /// In cs, this message translates to:
  /// **'Prompt itemu'**
  String get promptLabel;

  /// No description provided for @categoriesLabel.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get categoriesLabel;

  /// No description provided for @catHelmet.
  ///
  /// In cs, this message translates to:
  /// **'Helma'**
  String get catHelmet;

  /// No description provided for @catBack.
  ///
  /// In cs, this message translates to:
  /// **'Křídla / záda'**
  String get catBack;

  /// No description provided for @catSword.
  ///
  /// In cs, this message translates to:
  /// **'Meč'**
  String get catSword;

  /// No description provided for @catFront.
  ///
  /// In cs, this message translates to:
  /// **'Hrudní plát'**
  String get catFront;

  /// No description provided for @catHat.
  ///
  /// In cs, this message translates to:
  /// **'Čepice'**
  String get catHat;

  /// No description provided for @catHair.
  ///
  /// In cs, this message translates to:
  /// **'Vlasy (riziko)'**
  String get catHair;

  /// No description provided for @styleLabel.
  ///
  /// In cs, this message translates to:
  /// **'Styl'**
  String get styleLabel;

  /// No description provided for @collectionLabel.
  ///
  /// In cs, this message translates to:
  /// **'Kolekce'**
  String get collectionLabel;

  /// No description provided for @radialTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zdobení dokola'**
  String get radialTitle;

  /// No description provided for @radialSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'radiální symetrie – dorty, korunky'**
  String get radialSubtitle;

  /// No description provided for @variantsPerCategory.
  ///
  /// In cs, this message translates to:
  /// **'Varianty na kategorii: {count}'**
  String variantsPerCategory(int count);

  /// No description provided for @generateItems.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Vygenerovat {count} item} few{Vygenerovat {count} itemy} many{Vygenerovat {count} itemu} other{Vygenerovat {count} itemů}} (~{minutes} min)'**
  String generateItems(int count, int minutes);

  /// No description provided for @composerSent.
  ///
  /// In cs, this message translates to:
  /// **'Odesláno úloh: {sent} – Spark generuje (~4 min/kus, sériově)'**
  String composerSent(int sent);

  /// No description provided for @composerSentErrors.
  ///
  /// In cs, this message translates to:
  /// **'Odesláno: {sent}, chyby: {errors}'**
  String composerSentErrors(int sent, String errors);

  /// No description provided for @queueEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Na NASu zatím nic – pošli batch v Composeru.'**
  String get queueEmpty;

  /// No description provided for @stNew.
  ///
  /// In cs, this message translates to:
  /// **'Čeká na triage'**
  String get stNew;

  /// No description provided for @stRemeshing.
  ///
  /// In cs, this message translates to:
  /// **'Přepočítává se v TRELLIS (~4 min)'**
  String get stRemeshing;

  /// No description provided for @stApproved.
  ///
  /// In cs, this message translates to:
  /// **'Ve frontě na konverzi'**
  String get stApproved;

  /// No description provided for @stConverting.
  ///
  /// In cs, this message translates to:
  /// **'Konvertuje se'**
  String get stConverting;

  /// No description provided for @stConverted.
  ///
  /// In cs, this message translates to:
  /// **'Zkonvertováno – čeká na 3D review'**
  String get stConverted;

  /// No description provided for @stPacked.
  ///
  /// In cs, this message translates to:
  /// **'Zabaleno pro Studio'**
  String get stPacked;

  /// No description provided for @stFailed.
  ///
  /// In cs, this message translates to:
  /// **'Selhalo'**
  String get stFailed;

  /// No description provided for @stRejected.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnuto'**
  String get stRejected;

  /// No description provided for @stRerolled.
  ///
  /// In cs, this message translates to:
  /// **'Rerollnuto'**
  String get stRerolled;

  /// No description provided for @tapFor3d.
  ///
  /// In cs, this message translates to:
  /// **'klepni pro 3D'**
  String get tapFor3d;

  /// No description provided for @pack.
  ///
  /// In cs, this message translates to:
  /// **'Zabalit'**
  String get pack;

  /// No description provided for @sparkSection.
  ///
  /// In cs, this message translates to:
  /// **'Vyrábí se na Sparku ({count})'**
  String sparkSection(int count);

  /// No description provided for @sgQueued.
  ///
  /// In cs, this message translates to:
  /// **'čeká ve frontě'**
  String get sgQueued;

  /// No description provided for @sgConcept.
  ///
  /// In cs, this message translates to:
  /// **'kreslí koncept'**
  String get sgConcept;

  /// No description provided for @sgCleanplate.
  ///
  /// In cs, this message translates to:
  /// **'odmazává pozadí'**
  String get sgCleanplate;

  /// No description provided for @sgMesh.
  ///
  /// In cs, this message translates to:
  /// **'modeluje 3D (~4 min)'**
  String get sgMesh;

  /// No description provided for @sgPush.
  ///
  /// In cs, this message translates to:
  /// **'posílá na NAS'**
  String get sgPush;

  /// No description provided for @sgDone.
  ///
  /// In cs, this message translates to:
  /// **'hotovo'**
  String get sgDone;

  /// No description provided for @sgFailed.
  ///
  /// In cs, this message translates to:
  /// **'selhalo'**
  String get sgFailed;

  /// No description provided for @reviewTris.
  ///
  /// In cs, this message translates to:
  /// **'trojúhelníky'**
  String get reviewTris;

  /// No description provided for @reviewTexture.
  ///
  /// In cs, this message translates to:
  /// **'textura'**
  String get reviewTexture;

  /// No description provided for @reviewSymmetry.
  ///
  /// In cs, this message translates to:
  /// **'symetrie'**
  String get reviewSymmetry;

  /// No description provided for @yes.
  ///
  /// In cs, this message translates to:
  /// **'ano'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In cs, this message translates to:
  /// **'ne'**
  String get no;

  /// No description provided for @seamVerts.
  ///
  /// In cs, this message translates to:
  /// **'{symmetry} (švů: {count})'**
  String seamVerts(String symmetry, int count);

  /// No description provided for @reconvertAgain.
  ///
  /// In cs, this message translates to:
  /// **'Konvertovat znovu'**
  String get reconvertAgain;

  /// No description provided for @reconvertSymmetry.
  ///
  /// In cs, this message translates to:
  /// **'Znovu se symetrií'**
  String get reconvertSymmetry;

  /// No description provided for @radialMenu.
  ///
  /// In cs, this message translates to:
  /// **'Zdobení dokola (radiální)'**
  String get radialMenu;

  /// No description provided for @noSymmetry.
  ///
  /// In cs, this message translates to:
  /// **'Bez symetrie'**
  String get noSymmetry;

  /// No description provided for @backToConcept.
  ///
  /// In cs, this message translates to:
  /// **'Zpět na koncept'**
  String get backToConcept;

  /// No description provided for @show3d.
  ///
  /// In cs, this message translates to:
  /// **'Ukaž 3D model'**
  String get show3d;

  /// No description provided for @rejectedToast.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnuto'**
  String get rejectedToast;

  /// No description provided for @rerollToast.
  ///
  /// In cs, this message translates to:
  /// **'Reroll poslán na Spark'**
  String get rerollToast;

  /// No description provided for @approvedToast.
  ///
  /// In cs, this message translates to:
  /// **'Schváleno → konverze'**
  String get approvedToast;

  /// No description provided for @errorPrefix.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {error}'**
  String errorPrefix(String error);

  /// No description provided for @allSorted.
  ///
  /// In cs, this message translates to:
  /// **'Vše roztříděno. Poslat nový batch v Composeru?'**
  String get allSorted;

  /// No description provided for @newShort.
  ///
  /// In cs, this message translates to:
  /// **'Nová'**
  String get newShort;

  /// No description provided for @charactersEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádná postava.\nZačni fotkou nebo obrázkem humanoidní postavy.'**
  String get charactersEmpty;

  /// No description provided for @newCharacter.
  ///
  /// In cs, this message translates to:
  /// **'Nová postava'**
  String get newCharacter;

  /// No description provided for @creating.
  ///
  /// In cs, this message translates to:
  /// **'Zakládám…'**
  String get creating;

  /// No description provided for @generate.
  ///
  /// In cs, this message translates to:
  /// **'Vygenerovat'**
  String get generate;

  /// No description provided for @nameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get nameLabel;

  /// No description provided for @prepPhoto.
  ///
  /// In cs, this message translates to:
  /// **'Připravit fotku'**
  String get prepPhoto;

  /// No description provided for @prepPhotoHelp.
  ///
  /// In cs, this message translates to:
  /// **'Odstraní pozadí; když jsou ruce přilepené k tělu, odtáhne je do A-pózy, a když chybí nohy pod kotníky, domyslí je. Bez toho rig u srostlých končetin často selže.'**
  String get prepPhotoHelp;

  /// No description provided for @animationsLabel.
  ///
  /// In cs, this message translates to:
  /// **'Animace'**
  String get animationsLabel;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In cs, this message translates to:
  /// **'Knihovnu se nepodařilo načíst: {error}'**
  String libraryLoadFailed(String error);

  /// No description provided for @libraryEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Knihovna je prázdná. Klipy se registrují skriptem seed_animlib.py na NASu.'**
  String get libraryEmpty;

  /// No description provided for @gallery.
  ///
  /// In cs, this message translates to:
  /// **'Galerie'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In cs, this message translates to:
  /// **'Fotoaparát'**
  String get camera;

  /// No description provided for @characterFallback.
  ///
  /// In cs, this message translates to:
  /// **'Postava'**
  String get characterFallback;

  /// No description provided for @downloadGlb.
  ///
  /// In cs, this message translates to:
  /// **'Stáhnout GLB'**
  String get downloadGlb;

  /// No description provided for @downloadFbx.
  ///
  /// In cs, this message translates to:
  /// **'Stáhnout FBX'**
  String get downloadFbx;

  /// No description provided for @downloadZip.
  ///
  /// In cs, this message translates to:
  /// **'Stáhnout vše (ZIP)'**
  String get downloadZip;

  /// No description provided for @sendRoblox.
  ///
  /// In cs, this message translates to:
  /// **'Poslat do Robloxu'**
  String get sendRoblox;

  /// No description provided for @sendLuanti.
  ///
  /// In cs, this message translates to:
  /// **'Poslat do Luanti'**
  String get sendLuanti;

  /// No description provided for @exportQueued.
  ///
  /// In cs, this message translates to:
  /// **'Export do {target} zařazen'**
  String exportQueued(String target);

  /// No description provided for @clipsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Klipy'**
  String get clipsTitle;

  /// No description provided for @exportsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Exporty'**
  String get exportsTitle;

  /// No description provided for @stepAttempt.
  ///
  /// In cs, this message translates to:
  /// **'{step} (pokus {attempt})'**
  String stepAttempt(String step, int attempt);

  /// No description provided for @retryStep.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit krok znovu'**
  String get retryStep;

  /// No description provided for @stepOf.
  ///
  /// In cs, this message translates to:
  /// **'krok {step} z {total}'**
  String stepOf(int step, int total);

  /// No description provided for @cfAccessHelp.
  ///
  /// In cs, this message translates to:
  /// **'Potřeba jen pro ugc.ol1n.com (přístup bez Tailscale).'**
  String get cfAccessHelp;

  /// No description provided for @saveAndTest.
  ///
  /// In cs, this message translates to:
  /// **'Uložit a otestovat'**
  String get saveAndTest;

  /// No description provided for @connOk.
  ///
  /// In cs, this message translates to:
  /// **'Spojení OK (načteno úloh: {count})'**
  String connOk(int count);

  /// No description provided for @connFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nedostupné: {error}'**
  String connFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'gu',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'ms',
    'nb',
    'nl',
    'or',
    'pa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
