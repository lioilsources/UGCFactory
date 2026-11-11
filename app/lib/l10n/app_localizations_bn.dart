// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get navQueue => 'সারি';

  @override
  String get navCharacters => 'চরিত্র';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String nasUnavailable(String error) {
    return 'NAS পাওয়া যাচ্ছে না: $error';
  }

  @override
  String get promptLabel => 'আইটেমের প্রম্পট';

  @override
  String get categoriesLabel => 'বিভাগ';

  @override
  String get catHelmet => 'হেলমেট';

  @override
  String get catBack => 'ডানা / পিঠ';

  @override
  String get catSword => 'তলোয়ার';

  @override
  String get catFront => 'বুকের বর্ম';

  @override
  String get catHat => 'টুপি';

  @override
  String get catHair => 'চুল (ঝুঁকিপূর্ণ)';

  @override
  String get styleLabel => 'স্টাইল';

  @override
  String get collectionLabel => 'সংগ্রহ';

  @override
  String get radialTitle => 'চারদিকে অলংকরণ';

  @override
  String get radialSubtitle => 'রেডিয়াল প্রতিসাম্য – কেক, মুকুট';

  @override
  String variantsPerCategory(int count) {
    return 'প্রতি বিভাগে ভ্যারিয়েন্ট: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count আইটেম তৈরি করুন',
      one: '$count আইটেম তৈরি করুন',
    );
    return '$_temp0 (~$minutes মিনিট)';
  }

  @override
  String composerSent(int sent) {
    return 'পাঠানো কাজ: $sent – Spark তৈরি করছে (~প্রতিটি 4 মিনিট, একটার পর একটা)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'পাঠানো হয়েছে: $sent, ত্রুটি: $errors';
  }

  @override
  String get queueEmpty => 'NAS-এ এখনও কিছু নেই – Composer থেকে ব্যাচ পাঠান।';

  @override
  String get stNew => 'ট্রায়াজের অপেক্ষায়';

  @override
  String get stRemeshing => 'TRELLIS-এ পুনরায় গণনা হচ্ছে (~4 মিনিট)';

  @override
  String get stApproved => 'রূপান্তরের সারিতে';

  @override
  String get stConverting => 'রূপান্তর হচ্ছে';

  @override
  String get stConverted => 'রূপান্তরিত – 3D রিভিউয়ের অপেক্ষায়';

  @override
  String get stPacked => 'Studio-র জন্য প্যাক করা';

  @override
  String get stFailed => 'ব্যর্থ';

  @override
  String get stRejected => 'প্রত্যাখ্যাত';

  @override
  String get stRerolled => 'আবার তৈরি হয়েছে';

  @override
  String get tapFor3d => '3D দেখতে ট্যাপ করুন';

  @override
  String get pack => 'প্যাক করুন';

  @override
  String sparkSection(int count) {
    return 'Spark-এ তৈরি হচ্ছে ($count)';
  }

  @override
  String get sgQueued => 'সারিতে অপেক্ষা করছে';

  @override
  String get sgConcept => 'কনসেপ্ট আঁকছে';

  @override
  String get sgCleanplate => 'ব্যাকগ্রাউন্ড সরাচ্ছে';

  @override
  String get sgMesh => '3D মডেল বানাচ্ছে (~4 মিনিট)';

  @override
  String get sgPush => 'NAS-এ পাঠাচ্ছে';

  @override
  String get sgDone => 'সম্পন্ন';

  @override
  String get sgFailed => 'ব্যর্থ';

  @override
  String get reviewTris => 'ত্রিভুজ';

  @override
  String get reviewTexture => 'টেক্সচার';

  @override
  String get reviewSymmetry => 'প্রতিসাম্য';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (সিমের ভার্টেক্স: $count)';
  }

  @override
  String get reconvertAgain => 'আবার রূপান্তর করুন';

  @override
  String get reconvertSymmetry => 'প্রতিসাম্য দিয়ে আবার';

  @override
  String get radialMenu => 'চারদিকে অলংকরণ (রেডিয়াল)';

  @override
  String get noSymmetry => 'প্রতিসাম্য ছাড়া';

  @override
  String get backToConcept => 'কনসেপ্টে ফিরুন';

  @override
  String get show3d => '3D মডেল দেখান';

  @override
  String get rejectedToast => 'প্রত্যাখ্যাত';

  @override
  String get rerollToast => 'রিরোল Spark-এ পাঠানো হয়েছে';

  @override
  String get approvedToast => 'অনুমোদিত → রূপান্তর';

  @override
  String errorPrefix(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get allSorted => 'সব বাছাই শেষ। Composer থেকে নতুন ব্যাচ পাঠাবেন?';

  @override
  String get newShort => 'নতুন';

  @override
  String get charactersEmpty =>
      'এখনও কোনো চরিত্র নেই।\nমানব-আকৃতির চরিত্রের ছবি বা ফটো দিয়ে শুরু করুন।';

  @override
  String get newCharacter => 'নতুন চরিত্র';

  @override
  String get creating => 'তৈরি হচ্ছে…';

  @override
  String get generate => 'তৈরি করুন';

  @override
  String get nameLabel => 'নাম';

  @override
  String get prepPhoto => 'ছবি প্রস্তুত করুন';

  @override
  String get prepPhotoHelp =>
      'ব্যাকগ্রাউন্ড সরায়; হাত শরীরে লেগে থাকলে সেগুলো A-পোজে সরিয়ে আনে, আর গোড়ালির নিচে পা না থাকলে তা পূরণ করে। এটা ছাড়া জোড়া লাগা অঙ্গে রিগ প্রায়ই ব্যর্থ হয়।';

  @override
  String get animationsLabel => 'অ্যানিমেশন';

  @override
  String libraryLoadFailed(String error) {
    return 'লাইব্রেরি লোড করা যায়নি: $error';
  }

  @override
  String get libraryEmpty =>
      'লাইব্রেরি খালি। ক্লিপগুলো NAS-এ seed_animlib.py স্ক্রিপ্ট দিয়ে নিবন্ধিত হয়।';

  @override
  String get gallery => 'গ্যালারি';

  @override
  String get camera => 'ক্যামেরা';

  @override
  String get characterFallback => 'চরিত্র';

  @override
  String get downloadGlb => 'GLB ডাউনলোড';

  @override
  String get downloadFbx => 'FBX ডাউনলোড';

  @override
  String get downloadZip => 'সব ডাউনলোড (ZIP)';

  @override
  String get sendRoblox => 'Roblox-এ পাঠান';

  @override
  String get sendLuanti => 'Luanti-তে পাঠান';

  @override
  String exportQueued(String target) {
    return '$target-এ এক্সপোর্ট সারিতে দেওয়া হয়েছে';
  }

  @override
  String get clipsTitle => 'ক্লিপ';

  @override
  String get exportsTitle => 'এক্সপোর্ট';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (প্রচেষ্টা $attempt)';
  }

  @override
  String get retryStep => 'ধাপটি আবার চেষ্টা করুন';

  @override
  String stepOf(int step, int total) {
    return 'ধাপ $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'শুধু ugc.ol1n.com-এর জন্য দরকার (Tailscale ছাড়া প্রবেশ)।';

  @override
  String get saveAndTest => 'সংরক্ষণ ও পরীক্ষা';

  @override
  String connOk(int count) {
    return 'সংযোগ ঠিক আছে (লোড করা কাজ: $count)';
  }

  @override
  String connFailed(String error) {
    return 'পাওয়া যাচ্ছে না: $error';
  }
}
