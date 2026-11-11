// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navQueue => 'Очередь';

  @override
  String get navCharacters => 'Персонажи';

  @override
  String get navSettings => 'Настройки';

  @override
  String get retry => 'Повторить';

  @override
  String nasUnavailable(String error) {
    return 'NAS недоступен: $error';
  }

  @override
  String get promptLabel => 'Промпт предмета';

  @override
  String get categoriesLabel => 'Категории';

  @override
  String get catHelmet => 'Шлем';

  @override
  String get catBack => 'Крылья / спина';

  @override
  String get catSword => 'Меч';

  @override
  String get catFront => 'Нагрудник';

  @override
  String get catHat => 'Шапка';

  @override
  String get catHair => 'Волосы (рискованно)';

  @override
  String get styleLabel => 'Стиль';

  @override
  String get collectionLabel => 'Коллекция';

  @override
  String get radialTitle => 'Украшение по кругу';

  @override
  String get radialSubtitle => 'радиальная симметрия – торты, короны';

  @override
  String variantsPerCategory(int count) {
    return 'Вариантов на категорию: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сгенерировать $count предмета',
      many: 'Сгенерировать $count предметов',
      few: 'Сгенерировать $count предмета',
      one: 'Сгенерировать $count предмет',
    );
    return '$_temp0 (~$minutes мин)';
  }

  @override
  String composerSent(int sent) {
    return 'Отправлено задач: $sent – Spark генерирует (~4 мин на штуку, по одной)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Отправлено: $sent, ошибки: $errors';
  }

  @override
  String get queueEmpty =>
      'На NAS пока ничего нет – отправьте пакет из Composer.';

  @override
  String get stNew => 'Ждёт триажа';

  @override
  String get stRemeshing => 'Пересчитывается в TRELLIS (~4 мин)';

  @override
  String get stApproved => 'В очереди на конвертацию';

  @override
  String get stConverting => 'Конвертируется';

  @override
  String get stConverted => 'Сконвертировано – ждёт 3D-проверки';

  @override
  String get stPacked => 'Упаковано для Studio';

  @override
  String get stFailed => 'Ошибка';

  @override
  String get stRejected => 'Отклонено';

  @override
  String get stRerolled => 'Сгенерировано заново';

  @override
  String get tapFor3d => 'нажмите для 3D';

  @override
  String get pack => 'Упаковать';

  @override
  String sparkSection(int count) {
    return 'Создаётся на Spark ($count)';
  }

  @override
  String get sgQueued => 'ждёт в очереди';

  @override
  String get sgConcept => 'рисует концепт';

  @override
  String get sgCleanplate => 'убирает фон';

  @override
  String get sgMesh => 'моделирует в 3D (~4 мин)';

  @override
  String get sgPush => 'отправляет на NAS';

  @override
  String get sgDone => 'готово';

  @override
  String get sgFailed => 'ошибка';

  @override
  String get reviewTris => 'треугольники';

  @override
  String get reviewTexture => 'текстура';

  @override
  String get reviewSymmetry => 'симметрия';

  @override
  String get yes => 'да';

  @override
  String get no => 'нет';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (вершины шва: $count)';
  }

  @override
  String get reconvertAgain => 'Конвертировать снова';

  @override
  String get reconvertSymmetry => 'Снова с симметрией';

  @override
  String get radialMenu => 'Украшение по кругу (радиальное)';

  @override
  String get noSymmetry => 'Без симметрии';

  @override
  String get backToConcept => 'Назад к концепту';

  @override
  String get show3d => 'Показать 3D-модель';

  @override
  String get rejectedToast => 'Отклонено';

  @override
  String get rerollToast => 'Reroll отправлен на Spark';

  @override
  String get approvedToast => 'Одобрено → конвертация';

  @override
  String errorPrefix(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get allSorted => 'Всё разобрано. Отправить новый пакет из Composer?';

  @override
  String get newShort => 'Новый';

  @override
  String get charactersEmpty =>
      'Персонажей пока нет.\nНачните с фото или картинки гуманоидного персонажа.';

  @override
  String get newCharacter => 'Новый персонаж';

  @override
  String get creating => 'Создаю…';

  @override
  String get generate => 'Сгенерировать';

  @override
  String get nameLabel => 'Имя';

  @override
  String get prepPhoto => 'Подготовить фото';

  @override
  String get prepPhotoHelp =>
      'Убирает фон; если руки прилипли к телу, отводит их в A-позу, а если не хватает ног ниже лодыжек, дорисовывает их. Без этого риг часто не срабатывает на сросшихся конечностях.';

  @override
  String get animationsLabel => 'Анимации';

  @override
  String libraryLoadFailed(String error) {
    return 'Не удалось загрузить библиотеку: $error';
  }

  @override
  String get libraryEmpty =>
      'Библиотека пуста. Клипы регистрируются скриптом seed_animlib.py на NAS.';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get characterFallback => 'Персонаж';

  @override
  String get downloadGlb => 'Скачать GLB';

  @override
  String get downloadFbx => 'Скачать FBX';

  @override
  String get downloadZip => 'Скачать всё (ZIP)';

  @override
  String get sendRoblox => 'Отправить в Roblox';

  @override
  String get sendLuanti => 'Отправить в Luanti';

  @override
  String exportQueued(String target) {
    return 'Экспорт в $target поставлен в очередь';
  }

  @override
  String get clipsTitle => 'Клипы';

  @override
  String get exportsTitle => 'Экспорты';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (попытка $attempt)';
  }

  @override
  String get retryStep => 'Повторить шаг';

  @override
  String stepOf(int step, int total) {
    return 'шаг $step из $total';
  }

  @override
  String get cfAccessHelp =>
      'Нужно только для ugc.ol1n.com (доступ без Tailscale).';

  @override
  String get saveAndTest => 'Сохранить и проверить';

  @override
  String connOk(int count) {
    return 'Соединение в порядке (загружено задач: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Недоступно: $error';
  }
}
