// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get navQueue => 'Черга';

  @override
  String get navCharacters => 'Персонажі';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get retry => 'Спробувати ще раз';

  @override
  String nasUnavailable(String error) {
    return 'NAS недоступний: $error';
  }

  @override
  String get promptLabel => 'Промпт предмета';

  @override
  String get categoriesLabel => 'Категорії';

  @override
  String get catHelmet => 'Шолом';

  @override
  String get catBack => 'Крила / спина';

  @override
  String get catSword => 'Меч';

  @override
  String get catFront => 'Нагрудник';

  @override
  String get catHat => 'Шапка';

  @override
  String get catHair => 'Волосся (ризиковано)';

  @override
  String get styleLabel => 'Стиль';

  @override
  String get collectionLabel => 'Колекція';

  @override
  String get radialTitle => 'Прикраса по колу';

  @override
  String get radialSubtitle => 'радіальна симетрія – торти, корони';

  @override
  String variantsPerCategory(int count) {
    return 'Варіантів на категорію: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Згенерувати $count предмета',
      many: 'Згенерувати $count предметів',
      few: 'Згенерувати $count предмети',
      one: 'Згенерувати $count предмет',
    );
    return '$_temp0 (~$minutes хв)';
  }

  @override
  String composerSent(int sent) {
    return 'Надіслано завдань: $sent – Spark генерує (~4 хв на штуку, по одному)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Надіслано: $sent, помилки: $errors';
  }

  @override
  String get queueEmpty =>
      'На NAS поки нічого немає – надішліть пакет із Composer.';

  @override
  String get stNew => 'Чекає на тріаж';

  @override
  String get stRemeshing => 'Перераховується в TRELLIS (~4 хв)';

  @override
  String get stApproved => 'У черзі на конвертацію';

  @override
  String get stConverting => 'Конвертується';

  @override
  String get stConverted => 'Сконвертовано – чекає на 3D-перевірку';

  @override
  String get stPacked => 'Запаковано для Studio';

  @override
  String get stFailed => 'Помилка';

  @override
  String get stRejected => 'Відхилено';

  @override
  String get stRerolled => 'Згенеровано заново';

  @override
  String get tapFor3d => 'торкніться для 3D';

  @override
  String get pack => 'Запакувати';

  @override
  String sparkSection(int count) {
    return 'Створюється на Spark ($count)';
  }

  @override
  String get sgQueued => 'чекає в черзі';

  @override
  String get sgConcept => 'малює концепт';

  @override
  String get sgCleanplate => 'прибирає фон';

  @override
  String get sgMesh => 'моделює в 3D (~4 хв)';

  @override
  String get sgPush => 'надсилає на NAS';

  @override
  String get sgDone => 'готово';

  @override
  String get sgFailed => 'помилка';

  @override
  String get reviewTris => 'трикутники';

  @override
  String get reviewTexture => 'текстура';

  @override
  String get reviewSymmetry => 'симетрія';

  @override
  String get yes => 'так';

  @override
  String get no => 'ні';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (вершини шва: $count)';
  }

  @override
  String get reconvertAgain => 'Конвертувати знову';

  @override
  String get reconvertSymmetry => 'Знову із симетрією';

  @override
  String get radialMenu => 'Прикраса по колу (радіальна)';

  @override
  String get noSymmetry => 'Без симетрії';

  @override
  String get backToConcept => 'Назад до концепту';

  @override
  String get show3d => 'Показати 3D-модель';

  @override
  String get rejectedToast => 'Відхилено';

  @override
  String get rerollToast => 'Reroll надіслано на Spark';

  @override
  String get approvedToast => 'Схвалено → конвертація';

  @override
  String errorPrefix(String error) {
    return 'Помилка: $error';
  }

  @override
  String get allSorted => 'Усе розібрано. Надіслати новий пакет із Composer?';

  @override
  String get newShort => 'Новий';

  @override
  String get charactersEmpty =>
      'Персонажів поки немає.\nПочніть із фото або зображення гуманоїдного персонажа.';

  @override
  String get newCharacter => 'Новий персонаж';

  @override
  String get creating => 'Створюю…';

  @override
  String get generate => 'Згенерувати';

  @override
  String get nameLabel => 'Ім\'я';

  @override
  String get prepPhoto => 'Підготувати фото';

  @override
  String get prepPhotoHelp =>
      'Прибирає фон; якщо руки прилипли до тіла, відводить їх у A-позу, а якщо бракує ніг нижче щиколоток, домальовує їх. Без цього риг часто не спрацьовує на зрослих кінцівках.';

  @override
  String get animationsLabel => 'Анімації';

  @override
  String libraryLoadFailed(String error) {
    return 'Не вдалося завантажити бібліотеку: $error';
  }

  @override
  String get libraryEmpty =>
      'Бібліотека порожня. Кліпи реєструються скриптом seed_animlib.py на NAS.';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get characterFallback => 'Персонаж';

  @override
  String get downloadGlb => 'Завантажити GLB';

  @override
  String get downloadFbx => 'Завантажити FBX';

  @override
  String get downloadZip => 'Завантажити все (ZIP)';

  @override
  String get sendRoblox => 'Надіслати в Roblox';

  @override
  String get sendLuanti => 'Надіслати в Luanti';

  @override
  String exportQueued(String target) {
    return 'Експорт у $target поставлено в чергу';
  }

  @override
  String get clipsTitle => 'Кліпи';

  @override
  String get exportsTitle => 'Експорти';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (спроба $attempt)';
  }

  @override
  String get retryStep => 'Повторити крок';

  @override
  String stepOf(int step, int total) {
    return 'крок $step із $total';
  }

  @override
  String get cfAccessHelp =>
      'Потрібно лише для ugc.ol1n.com (доступ без Tailscale).';

  @override
  String get saveAndTest => 'Зберегти й перевірити';

  @override
  String connOk(int count) {
    return 'З\'єднання в порядку (завантажено завдань: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Недоступно: $error';
  }
}
