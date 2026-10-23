// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CheckScan';

  @override
  String get pendingEditHint =>
      'Сначала загрузите позиции чека, чтобы редактировать покупку';

  @override
  String get receiptMissing => 'Чек не найден или удалён';

  @override
  String get qrTimeUnknown => 'Время из QR, часовой пояс ещё не подтверждён';

  @override
  String get discountInformational =>
      'Скидка показана справочно и уже учтена в итоге';

  @override
  String get welcomeTitle => 'Чеки превращаются в историю трат';

  @override
  String get welcomeDescription =>
      'Сканируйте нижний QR-код фискального чека, чтобы сохранить покупку и её позиции.';

  @override
  String get localOnly => 'Ваши чеки хранятся только на этом устройстве.';

  @override
  String get scanTab => 'Скан';

  @override
  String get historyTab => 'История';

  @override
  String get statsTab => 'Статистика';

  @override
  String get settingsTab => 'Настройки';

  @override
  String get scanTitle => 'Сканировать чек';

  @override
  String get scanHint => 'Наведите на нижний QR-код чека';

  @override
  String get scanDescription =>
      'QR-код обычно находится внизу чека, рядом с названием ОФД.';

  @override
  String get gallery => 'Из галереи';

  @override
  String get pasteLink => 'Вставить ссылку';

  @override
  String get receiptLink => 'Ссылка на чек ОФД';

  @override
  String get pasteFromClipboard => 'Вставить из буфера';

  @override
  String get loadReceipt => 'Получить чек';

  @override
  String get loadingReceipt => 'Получаем чек…';

  @override
  String get analyzingPhoto => 'Ищем QR-код на фото…';

  @override
  String get flashOn => 'Включить фонарик';

  @override
  String get flashOff => 'Выключить фонарик';

  @override
  String get scanAgain => 'Сканировать ещё';

  @override
  String get cameraPermissionTitle => 'Нужен доступ к камере';

  @override
  String get cameraPermissionDescription =>
      'Разрешите доступ к камере, чтобы сканировать QR-коды чеков. Вы также можете выбрать фото или вставить ссылку.';

  @override
  String get openAppSettings => 'Открыть настройки';

  @override
  String get grantPermission => 'Разрешить доступ';

  @override
  String get cameraUnavailable =>
      'Камера недоступна. Выберите фото или вставьте ссылку на чек.';

  @override
  String get qrNotFound =>
      'Не нашли QR чека. Сфотографируйте нижний QR ближе и ровнее';

  @override
  String get notReceiptQr => 'Это не QR чека';

  @override
  String get invalidLink => 'Проверьте ссылку на чек ОФД';

  @override
  String get emptyClipboard => 'В буфере обмена нет ссылки';

  @override
  String get rawQr => 'Содержимое QR-кода';

  @override
  String get unknownOfdTitle => 'Неизвестный оператор';

  @override
  String unknownOfdMessage(String host) {
    return 'Ссылка ведёт на $host. Поддержка этого ОФД пока не добавлена.';
  }

  @override
  String get duplicateTitle => 'Этот чек уже добавлен';

  @override
  String get duplicateMessage => 'Покупка уже есть в вашей истории.';

  @override
  String get openReceipt => 'Открыть чек';

  @override
  String get receiptSaved => 'Чек сохранён';

  @override
  String get savedOffline => 'Чек сохранён. Загрузим, когда появится интернет';

  @override
  String get noNetwork => 'Нет подключения к интернету';

  @override
  String get ofdCertificateError =>
      'Не удалось проверить сертификат ОФД. Проверьте дату на устройстве и повторите позже.';

  @override
  String get ofdTimeout => 'ОФД не ответил вовремя. Попробуйте ещё раз';

  @override
  String get ofdUnavailable => 'ОФД временно недоступен';

  @override
  String get receiptNotFound =>
      'ОФД ещё не получил чек, попробуйте через несколько минут';

  @override
  String get parseError => 'Не удалось разобрать ответ ОФД';

  @override
  String get unsafeRedirect => 'ОФД перенаправил запрос на неизвестный адрес';

  @override
  String get unexpectedError =>
      'Не удалось выполнить действие. Попробуйте ещё раз';

  @override
  String get retry => 'Повторить';

  @override
  String get pending => 'Ожидает загрузки';

  @override
  String get errorStatus => 'Ошибка загрузки';

  @override
  String get needsReview => 'Проверить';

  @override
  String get edited => 'Изменён';

  @override
  String get sumMismatch =>
      'Сумма позиций отличается от итога чека. Проверьте данные';

  @override
  String get timeZoneAssumed =>
      'Часовой пояс не указан ОФД. Использовано время Казахстана (UTC+5)';

  @override
  String get receiptTitle => 'Чек';

  @override
  String get editReceipt => 'Редактировать чек';

  @override
  String get storeName => 'Название магазина';

  @override
  String get unknownStore => 'Магазин пока неизвестен';

  @override
  String get storeAddress => 'Адрес';

  @override
  String get purchaseDate => 'Дата покупки';

  @override
  String get purchaseTime => 'Время покупки';

  @override
  String get total => 'Итого';

  @override
  String get discount => 'Скидка';

  @override
  String get vat => 'НДС';

  @override
  String get paymentType => 'Способ оплаты';

  @override
  String get paymentCash => 'Наличные';

  @override
  String get paymentCard => 'Карта';

  @override
  String get paymentMixed => 'Смешанная оплата';

  @override
  String get sellerBin => 'БИН продавца';

  @override
  String get kkmRegNumber => 'РНМ кассы';

  @override
  String get kkmSerial => 'Заводской номер кассы';

  @override
  String get fiscalSign => 'Фискальный признак';

  @override
  String get receiptNumber => 'Номер чека';

  @override
  String get ofd => 'Оператор фискальных данных';

  @override
  String get items => 'Позиции';

  @override
  String get itemName => 'Название товара';

  @override
  String get itemRawName => 'Название в ОФД';

  @override
  String get quantity => 'Количество';

  @override
  String get unit => 'Единица';

  @override
  String get unitPrice => 'Цена за единицу';

  @override
  String get itemSum => 'Сумма позиции';

  @override
  String get barcode => 'Штрихкод';

  @override
  String get ntin => 'NTIN';

  @override
  String get addItem => 'Добавить позицию';

  @override
  String get editItem => 'Редактировать позицию';

  @override
  String get deleteItem => 'Удалить позицию';

  @override
  String get noItems => 'Позиции ещё не загружены';

  @override
  String get note => 'Заметка';

  @override
  String get noteHint => 'Например, покупки для поездки';

  @override
  String get category => 'Категория';

  @override
  String get receiptCategory => 'Категория чека';

  @override
  String get chooseCategory => 'Выбрать категорию';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get add => 'Добавить';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get done => 'Готово';

  @override
  String get back => 'Назад';

  @override
  String get openInOfd => 'Открыть в ОФД';

  @override
  String get openLinkFailed => 'Не удалось открыть ссылку';

  @override
  String get receiptDeleted => 'Чек удалён';

  @override
  String get undo => 'Отменить';

  @override
  String get deleteReceiptTitle => 'Удалить чек?';

  @override
  String get deleteReceiptMessage =>
      'Чек и все его позиции будут удалены из истории.';

  @override
  String get changesSaved => 'Изменения сохранены';

  @override
  String get requiredField => 'Заполните поле';

  @override
  String get invalidAmount => 'Введите корректную сумму';

  @override
  String get invalidQuantity => 'Количество должно быть больше нуля';

  @override
  String get invalidDate => 'Введите корректную дату';

  @override
  String get historyTitle => 'История покупок';

  @override
  String get emptyHistoryTitle => 'Здесь появятся ваши покупки';

  @override
  String get emptyHistoryDescription =>
      'Отсканируйте первый чек или выберите его фото из галереи.';

  @override
  String get noSearchResults => 'Покупки не найдены';

  @override
  String get noSearchResultsDescription =>
      'Измените запрос или сбросьте фильтры.';

  @override
  String get searchHint => 'Магазин или товар';

  @override
  String get search => 'Поиск';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get filters => 'Фильтры';

  @override
  String get period => 'Период';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get day => 'День';

  @override
  String get week => 'Неделя';

  @override
  String get month => 'Месяц';

  @override
  String get year => 'Год';

  @override
  String get allTime => 'За всё время';

  @override
  String get customPeriod => 'Свой период';

  @override
  String get dateFrom => 'С даты';

  @override
  String get dateTo => 'По дату';

  @override
  String get store => 'Магазин';

  @override
  String get allStores => 'Все магазины';

  @override
  String get allCategories => 'Все категории';

  @override
  String get amountFrom => 'Сумма от';

  @override
  String get amountTo => 'Сумма до';

  @override
  String get retryPending => 'Повторить загрузку черновиков';

  @override
  String get retryingPending => 'Загружаем черновики…';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count позиции',
      many: '$count позиций',
      few: '$count позиции',
      one: '$count позиция',
      zero: 'Нет позиций',
    );
    return '$_temp0';
  }

  @override
  String receiptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count чека',
      many: '$count чеков',
      few: '$count чека',
      one: '$count чек',
      zero: 'Нет чеков',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Ваши расходы';

  @override
  String get emptyStatsTitle => 'Пока нечего сравнивать';

  @override
  String get emptyStatsDescription =>
      'Добавьте чеки, и здесь появится статистика ваших покупок.';

  @override
  String get totalSpent => 'Всего потрачено';

  @override
  String get receiptCountLabel => 'Количество чеков';

  @override
  String get averageReceipt => 'Средний чек';

  @override
  String get previousPeriod => 'Предыдущий период';

  @override
  String get nextPeriod => 'Следующий период';

  @override
  String get comparedToPrevious => 'К предыдущему периоду';

  @override
  String get noPreviousPeriodData => 'Нет данных за предыдущий период';

  @override
  String get byCategory => 'По категориям';

  @override
  String get spendingByDay => 'Расходы по дням';

  @override
  String get spendingByWeek => 'Расходы по неделям';

  @override
  String get spendingByMonth => 'Расходы по месяцам';

  @override
  String get topStores => 'Топ магазинов';

  @override
  String get topProducts => 'Топ товаров';

  @override
  String get byAmount => 'По сумме';

  @override
  String get byFrequency => 'По частоте';

  @override
  String get viewPurchases => 'Показать покупки';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get addCategory => 'Добавить категорию';

  @override
  String get editCategory => 'Редактировать категорию';

  @override
  String get categoryName => 'Название категории';

  @override
  String get categoryColor => 'Цвет';

  @override
  String get categoryIcon => 'Значок';

  @override
  String get deleteCategoryTitle => 'Удалить категорию?';

  @override
  String get deleteCategoryMessage =>
      'Позиции этой категории будут отнесены к «Прочее».';

  @override
  String get builtInCategory => 'Встроенная категория';

  @override
  String get categoryRules => 'Правила категорий';

  @override
  String get addRule => 'Добавить правило';

  @override
  String get keyword => 'Ключевое слово';

  @override
  String get rulePattern => 'Слово в названии или штрихкод';

  @override
  String get rememberCategoryTitle => 'Запомнить категорию?';

  @override
  String rememberCategoryMessage(String name) {
    return 'Применять эту категорию ко всем покупкам «$name»?';
  }

  @override
  String get remember => 'Запомнить';

  @override
  String get onlyThisItem => 'Только для этой позиции';

  @override
  String get categoryGroceries => 'Продукты';

  @override
  String get categoryDairy => 'Молочное';

  @override
  String get categoryMeatFish => 'Мясо и рыба';

  @override
  String get categoryFruitVegetables => 'Овощи и фрукты';

  @override
  String get categoryBakery => 'Хлеб и выпечка';

  @override
  String get categorySweets => 'Сладости и снеки';

  @override
  String get categoryDrinks => 'Напитки';

  @override
  String get categoryAlcohol => 'Алкоголь';

  @override
  String get categoryHousehold => 'Бытовая химия';

  @override
  String get categoryPersonalCare => 'Гигиена и уход';

  @override
  String get categoryPharmacy => 'Аптека';

  @override
  String get categoryClothing => 'Одежда';

  @override
  String get categoryElectronics => 'Электроника';

  @override
  String get categoryRestaurants => 'Кафе и рестораны';

  @override
  String get categoryTransport => 'Транспорт и топливо';

  @override
  String get categoryOther => 'Прочее';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get appearance => 'Оформление';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get currency => 'Валюта';

  @override
  String get currencyKzt => 'Казахстанский тенге (₸)';

  @override
  String get numberFormat => 'Формат сумм';

  @override
  String get dataManagement => 'Ваши данные';

  @override
  String get exportCsv => 'Экспорт CSV';

  @override
  String get exportCsvDescription => 'Чеки и позиции для Excel';

  @override
  String get exportBackup => 'Сохранить JSON-бэкап';

  @override
  String get exportBackupDescription =>
      'Резервная копия чеков, категорий и правил';

  @override
  String get importBackup => 'Импорт JSON-бэкапа';

  @override
  String get importBackupDescription =>
      'Объединить с текущими данными без дублей';

  @override
  String get exporting => 'Готовим файл…';

  @override
  String get importing => 'Восстанавливаем данные…';

  @override
  String importSucceeded(int added, int duplicates) {
    return 'Добавлено чеков: $added. Пропущено дублей: $duplicates.';
  }

  @override
  String get invalidBackup => 'Этот файл не похож на резервную копию CheckScan';

  @override
  String get unsupportedBackup =>
      'Эта версия резервной копии пока не поддерживается';

  @override
  String get exportFailed => 'Не удалось подготовить файл';

  @override
  String get deleteAllData => 'Удалить все данные';

  @override
  String get deleteAllTitle => 'Удалить все данные?';

  @override
  String get deleteAllMessage =>
      'Будут удалены все чеки, категории и правила на этом устройстве. Сначала можно сохранить JSON-бэкап.';

  @override
  String get deleteAllConfirmTitle => 'Подтвердите удаление';

  @override
  String get deleteAllConfirmMessage =>
      'Восстановить данные без резервной копии не получится.';

  @override
  String get deleteAllConfirm => 'Удалить безвозвратно';

  @override
  String get allDataDeleted => 'Все данные удалены';

  @override
  String get about => 'О приложении';

  @override
  String get aboutDescription =>
      'CheckScan помогает учитывать расходы по фискальным чекам Казахстана. Для получения чека приложение обращается к его ОФД. Телеметрии и облачной синхронизации нет.';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get privacy => 'Хранение данных';

  @override
  String get debugTitle => 'Диагностика QR и ОФД';

  @override
  String get debugRawQr => 'Исходная строка QR';

  @override
  String get debugDecodedQr => 'Строка после HTML-декодирования';

  @override
  String get debugResponse => 'Ответ ОФД';

  @override
  String get debugCopy => 'Скопировать диагностику';

  @override
  String get copied => 'Скопировано';

  @override
  String get sendToDeveloper => 'Отправить разработчику';

  @override
  String get loading => 'Загрузка…';

  @override
  String get refresh => 'Обновить';

  @override
  String get manualEntry => 'Ввести вручную';

  @override
  String get newPurchase => 'Новая покупка';

  @override
  String get addedManually => 'Добавлено вручную';

  @override
  String get addAtLeastOneItem => 'Добавьте хотя бы одну позицию';

  @override
  String get manualEntryHint =>
      'Чек не сканируется? Введите товары, цены и категории вручную.';
}
