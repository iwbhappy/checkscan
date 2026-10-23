import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'CheckScan'**
  String get appTitle;

  /// No description provided for @pendingEditHint.
  ///
  /// In ru, this message translates to:
  /// **'Сначала загрузите позиции чека, чтобы редактировать покупку'**
  String get pendingEditHint;

  /// No description provided for @receiptMissing.
  ///
  /// In ru, this message translates to:
  /// **'Чек не найден или удалён'**
  String get receiptMissing;

  /// No description provided for @qrTimeUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Время из QR, часовой пояс ещё не подтверждён'**
  String get qrTimeUnknown;

  /// No description provided for @discountInformational.
  ///
  /// In ru, this message translates to:
  /// **'Скидка показана справочно и уже учтена в итоге'**
  String get discountInformational;

  /// No description provided for @welcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чеки превращаются в историю трат'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сканируйте нижний QR-код фискального чека, чтобы сохранить покупку и её позиции.'**
  String get welcomeDescription;

  /// No description provided for @localOnly.
  ///
  /// In ru, this message translates to:
  /// **'Ваши чеки хранятся только на этом устройстве.'**
  String get localOnly;

  /// No description provided for @scanTab.
  ///
  /// In ru, this message translates to:
  /// **'Скан'**
  String get scanTab;

  /// No description provided for @historyTab.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get historyTab;

  /// No description provided for @statsTab.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statsTab;

  /// No description provided for @settingsTab.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTab;

  /// No description provided for @scanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать чек'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In ru, this message translates to:
  /// **'Наведите на нижний QR-код чека'**
  String get scanHint;

  /// No description provided for @scanDescription.
  ///
  /// In ru, this message translates to:
  /// **'QR-код обычно находится внизу чека, рядом с названием ОФД.'**
  String get scanDescription;

  /// No description provided for @gallery.
  ///
  /// In ru, this message translates to:
  /// **'Из галереи'**
  String get gallery;

  /// No description provided for @pasteLink.
  ///
  /// In ru, this message translates to:
  /// **'Вставить ссылку'**
  String get pasteLink;

  /// No description provided for @receiptLink.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на чек ОФД'**
  String get receiptLink;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In ru, this message translates to:
  /// **'Вставить из буфера'**
  String get pasteFromClipboard;

  /// No description provided for @loadReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Получить чек'**
  String get loadReceipt;

  /// No description provided for @loadingReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Получаем чек…'**
  String get loadingReceipt;

  /// No description provided for @analyzingPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Ищем QR-код на фото…'**
  String get analyzingPhoto;

  /// No description provided for @flashOn.
  ///
  /// In ru, this message translates to:
  /// **'Включить фонарик'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключить фонарик'**
  String get flashOff;

  /// No description provided for @scanAgain.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать ещё'**
  String get scanAgain;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нужен доступ к камере'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionDescription.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите доступ к камере, чтобы сканировать QR-коды чеков. Вы также можете выбрать фото или вставить ссылку.'**
  String get cameraPermissionDescription;

  /// No description provided for @openAppSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get openAppSettings;

  /// No description provided for @grantPermission.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить доступ'**
  String get grantPermission;

  /// No description provided for @cameraUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна. Выберите фото или вставьте ссылку на чек.'**
  String get cameraUnavailable;

  /// No description provided for @qrNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Не нашли QR чека. Сфотографируйте нижний QR ближе и ровнее'**
  String get qrNotFound;

  /// No description provided for @notReceiptQr.
  ///
  /// In ru, this message translates to:
  /// **'Это не QR чека'**
  String get notReceiptQr;

  /// No description provided for @invalidLink.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте ссылку на чек ОФД'**
  String get invalidLink;

  /// No description provided for @emptyClipboard.
  ///
  /// In ru, this message translates to:
  /// **'В буфере обмена нет ссылки'**
  String get emptyClipboard;

  /// No description provided for @rawQr.
  ///
  /// In ru, this message translates to:
  /// **'Содержимое QR-кода'**
  String get rawQr;

  /// No description provided for @unknownOfdTitle.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестный оператор'**
  String get unknownOfdTitle;

  /// No description provided for @unknownOfdMessage.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка ведёт на {host}. Поддержка этого ОФД пока не добавлена.'**
  String unknownOfdMessage(String host);

  /// No description provided for @duplicateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Этот чек уже добавлен'**
  String get duplicateTitle;

  /// No description provided for @duplicateMessage.
  ///
  /// In ru, this message translates to:
  /// **'Покупка уже есть в вашей истории.'**
  String get duplicateMessage;

  /// No description provided for @openReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Открыть чек'**
  String get openReceipt;

  /// No description provided for @receiptSaved.
  ///
  /// In ru, this message translates to:
  /// **'Чек сохранён'**
  String get receiptSaved;

  /// No description provided for @savedOffline.
  ///
  /// In ru, this message translates to:
  /// **'Чек сохранён. Загрузим, когда появится интернет'**
  String get savedOffline;

  /// No description provided for @noNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к интернету'**
  String get noNetwork;

  /// No description provided for @ofdCertificateError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить сертификат ОФД. Проверьте дату на устройстве и повторите позже.'**
  String get ofdCertificateError;

  /// No description provided for @ofdTimeout.
  ///
  /// In ru, this message translates to:
  /// **'ОФД не ответил вовремя. Попробуйте ещё раз'**
  String get ofdTimeout;

  /// No description provided for @ofdUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ОФД временно недоступен'**
  String get ofdUnavailable;

  /// No description provided for @receiptNotFound.
  ///
  /// In ru, this message translates to:
  /// **'ОФД ещё не получил чек, попробуйте через несколько минут'**
  String get receiptNotFound;

  /// No description provided for @parseError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось разобрать ответ ОФД'**
  String get parseError;

  /// No description provided for @unsafeRedirect.
  ///
  /// In ru, this message translates to:
  /// **'ОФД перенаправил запрос на неизвестный адрес'**
  String get unsafeRedirect;

  /// No description provided for @unexpectedError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить действие. Попробуйте ещё раз'**
  String get unexpectedError;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @pending.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает загрузки'**
  String get pending;

  /// No description provided for @errorStatus.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки'**
  String get errorStatus;

  /// No description provided for @needsReview.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get needsReview;

  /// No description provided for @edited.
  ///
  /// In ru, this message translates to:
  /// **'Изменён'**
  String get edited;

  /// No description provided for @sumMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Сумма позиций отличается от итога чека. Проверьте данные'**
  String get sumMismatch;

  /// No description provided for @timeZoneAssumed.
  ///
  /// In ru, this message translates to:
  /// **'Часовой пояс не указан ОФД. Использовано время Казахстана (UTC+5)'**
  String get timeZoneAssumed;

  /// No description provided for @receiptTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чек'**
  String get receiptTitle;

  /// No description provided for @editReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать чек'**
  String get editReceipt;

  /// No description provided for @storeName.
  ///
  /// In ru, this message translates to:
  /// **'Название магазина'**
  String get storeName;

  /// No description provided for @unknownStore.
  ///
  /// In ru, this message translates to:
  /// **'Магазин пока неизвестен'**
  String get unknownStore;

  /// No description provided for @storeAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get storeAddress;

  /// No description provided for @purchaseDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата покупки'**
  String get purchaseDate;

  /// No description provided for @purchaseTime.
  ///
  /// In ru, this message translates to:
  /// **'Время покупки'**
  String get purchaseTime;

  /// No description provided for @total.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get total;

  /// No description provided for @discount.
  ///
  /// In ru, this message translates to:
  /// **'Скидка'**
  String get discount;

  /// No description provided for @vat.
  ///
  /// In ru, this message translates to:
  /// **'НДС'**
  String get vat;

  /// No description provided for @paymentType.
  ///
  /// In ru, this message translates to:
  /// **'Способ оплаты'**
  String get paymentType;

  /// No description provided for @paymentCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get paymentCash;

  /// No description provided for @paymentCard.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get paymentCard;

  /// No description provided for @paymentMixed.
  ///
  /// In ru, this message translates to:
  /// **'Смешанная оплата'**
  String get paymentMixed;

  /// No description provided for @sellerBin.
  ///
  /// In ru, this message translates to:
  /// **'БИН продавца'**
  String get sellerBin;

  /// No description provided for @kkmRegNumber.
  ///
  /// In ru, this message translates to:
  /// **'РНМ кассы'**
  String get kkmRegNumber;

  /// No description provided for @kkmSerial.
  ///
  /// In ru, this message translates to:
  /// **'Заводской номер кассы'**
  String get kkmSerial;

  /// No description provided for @fiscalSign.
  ///
  /// In ru, this message translates to:
  /// **'Фискальный признак'**
  String get fiscalSign;

  /// No description provided for @receiptNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер чека'**
  String get receiptNumber;

  /// No description provided for @ofd.
  ///
  /// In ru, this message translates to:
  /// **'Оператор фискальных данных'**
  String get ofd;

  /// No description provided for @items.
  ///
  /// In ru, this message translates to:
  /// **'Позиции'**
  String get items;

  /// No description provided for @itemName.
  ///
  /// In ru, this message translates to:
  /// **'Название товара'**
  String get itemName;

  /// No description provided for @itemRawName.
  ///
  /// In ru, this message translates to:
  /// **'Название в ОФД'**
  String get itemRawName;

  /// No description provided for @quantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In ru, this message translates to:
  /// **'Единица'**
  String get unit;

  /// No description provided for @unitPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена за единицу'**
  String get unitPrice;

  /// No description provided for @itemSum.
  ///
  /// In ru, this message translates to:
  /// **'Сумма позиции'**
  String get itemSum;

  /// No description provided for @barcode.
  ///
  /// In ru, this message translates to:
  /// **'Штрихкод'**
  String get barcode;

  /// No description provided for @ntin.
  ///
  /// In ru, this message translates to:
  /// **'NTIN'**
  String get ntin;

  /// No description provided for @addItem.
  ///
  /// In ru, this message translates to:
  /// **'Добавить позицию'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать позицию'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In ru, this message translates to:
  /// **'Удалить позицию'**
  String get deleteItem;

  /// No description provided for @noItems.
  ///
  /// In ru, this message translates to:
  /// **'Позиции ещё не загружены'**
  String get noItems;

  /// No description provided for @note.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, покупки для поездки'**
  String get noteHint;

  /// No description provided for @category.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get category;

  /// No description provided for @receiptCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория чека'**
  String get receiptCategory;

  /// No description provided for @chooseCategory.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать категорию'**
  String get chooseCategory;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @openInOfd.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в ОФД'**
  String get openInOfd;

  /// No description provided for @openLinkFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть ссылку'**
  String get openLinkFailed;

  /// No description provided for @receiptDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Чек удалён'**
  String get receiptDeleted;

  /// No description provided for @undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get undo;

  /// No description provided for @deleteReceiptTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить чек?'**
  String get deleteReceiptTitle;

  /// No description provided for @deleteReceiptMessage.
  ///
  /// In ru, this message translates to:
  /// **'Чек и все его позиции будут удалены из истории.'**
  String get deleteReceiptMessage;

  /// No description provided for @changesSaved.
  ///
  /// In ru, this message translates to:
  /// **'Изменения сохранены'**
  String get changesSaved;

  /// No description provided for @requiredField.
  ///
  /// In ru, this message translates to:
  /// **'Заполните поле'**
  String get requiredField;

  /// No description provided for @invalidAmount.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную сумму'**
  String get invalidAmount;

  /// No description provided for @invalidQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество должно быть больше нуля'**
  String get invalidQuantity;

  /// No description provided for @invalidDate.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную дату'**
  String get invalidDate;

  /// No description provided for @historyTitle.
  ///
  /// In ru, this message translates to:
  /// **'История покупок'**
  String get historyTitle;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся ваши покупки'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistoryDescription.
  ///
  /// In ru, this message translates to:
  /// **'Отсканируйте первый чек или выберите его фото из галереи.'**
  String get emptyHistoryDescription;

  /// No description provided for @noSearchResults.
  ///
  /// In ru, this message translates to:
  /// **'Покупки не найдены'**
  String get noSearchResults;

  /// No description provided for @noSearchResultsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Измените запрос или сбросьте фильтры.'**
  String get noSearchResultsDescription;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Магазин или товар'**
  String get searchHint;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @clearSearch.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get clearSearch;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @period.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get period;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday;

  /// No description provided for @day.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get day;

  /// No description provided for @week.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get week;

  /// No description provided for @month.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get month;

  /// No description provided for @year.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get year;

  /// No description provided for @allTime.
  ///
  /// In ru, this message translates to:
  /// **'За всё время'**
  String get allTime;

  /// No description provided for @customPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Свой период'**
  String get customPeriod;

  /// No description provided for @dateFrom.
  ///
  /// In ru, this message translates to:
  /// **'С даты'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In ru, this message translates to:
  /// **'По дату'**
  String get dateTo;

  /// No description provided for @store.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get store;

  /// No description provided for @allStores.
  ///
  /// In ru, this message translates to:
  /// **'Все магазины'**
  String get allStores;

  /// No description provided for @allCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get allCategories;

  /// No description provided for @amountFrom.
  ///
  /// In ru, this message translates to:
  /// **'Сумма от'**
  String get amountFrom;

  /// No description provided for @amountTo.
  ///
  /// In ru, this message translates to:
  /// **'Сумма до'**
  String get amountTo;

  /// No description provided for @retryPending.
  ///
  /// In ru, this message translates to:
  /// **'Повторить загрузку черновиков'**
  String get retryPending;

  /// No description provided for @retryingPending.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем черновики…'**
  String get retryingPending;

  /// No description provided for @itemsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет позиций} one{{count} позиция} few{{count} позиции} many{{count} позиций} other{{count} позиции}}'**
  String itemsCount(int count);

  /// No description provided for @receiptsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет чеков} one{{count} чек} few{{count} чека} many{{count} чеков} other{{count} чека}}'**
  String receiptsCount(int count);

  /// No description provided for @statsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваши расходы'**
  String get statsTitle;

  /// No description provided for @emptyStatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нечего сравнивать'**
  String get emptyStatsTitle;

  /// No description provided for @emptyStatsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте чеки, и здесь появится статистика ваших покупок.'**
  String get emptyStatsDescription;

  /// No description provided for @totalSpent.
  ///
  /// In ru, this message translates to:
  /// **'Всего потрачено'**
  String get totalSpent;

  /// No description provided for @receiptCountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Количество чеков'**
  String get receiptCountLabel;

  /// No description provided for @averageReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Средний чек'**
  String get averageReceipt;

  /// No description provided for @previousPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий период'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Следующий период'**
  String get nextPeriod;

  /// No description provided for @comparedToPrevious.
  ///
  /// In ru, this message translates to:
  /// **'К предыдущему периоду'**
  String get comparedToPrevious;

  /// No description provided for @noPreviousPeriodData.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных за предыдущий период'**
  String get noPreviousPeriodData;

  /// No description provided for @byCategory.
  ///
  /// In ru, this message translates to:
  /// **'По категориям'**
  String get byCategory;

  /// No description provided for @spendingByDay.
  ///
  /// In ru, this message translates to:
  /// **'Расходы по дням'**
  String get spendingByDay;

  /// No description provided for @spendingByWeek.
  ///
  /// In ru, this message translates to:
  /// **'Расходы по неделям'**
  String get spendingByWeek;

  /// No description provided for @spendingByMonth.
  ///
  /// In ru, this message translates to:
  /// **'Расходы по месяцам'**
  String get spendingByMonth;

  /// No description provided for @topStores.
  ///
  /// In ru, this message translates to:
  /// **'Топ магазинов'**
  String get topStores;

  /// No description provided for @topProducts.
  ///
  /// In ru, this message translates to:
  /// **'Топ товаров'**
  String get topProducts;

  /// No description provided for @byAmount.
  ///
  /// In ru, this message translates to:
  /// **'По сумме'**
  String get byAmount;

  /// No description provided for @byFrequency.
  ///
  /// In ru, this message translates to:
  /// **'По частоте'**
  String get byFrequency;

  /// No description provided for @viewPurchases.
  ///
  /// In ru, this message translates to:
  /// **'Показать покупки'**
  String get viewPurchases;

  /// No description provided for @categoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categoriesTitle;

  /// No description provided for @addCategory.
  ///
  /// In ru, this message translates to:
  /// **'Добавить категорию'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать категорию'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In ru, this message translates to:
  /// **'Название категории'**
  String get categoryName;

  /// No description provided for @categoryColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get categoryColor;

  /// No description provided for @categoryIcon.
  ///
  /// In ru, this message translates to:
  /// **'Значок'**
  String get categoryIcon;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить категорию?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In ru, this message translates to:
  /// **'Позиции этой категории будут отнесены к «Прочее».'**
  String get deleteCategoryMessage;

  /// No description provided for @builtInCategory.
  ///
  /// In ru, this message translates to:
  /// **'Встроенная категория'**
  String get builtInCategory;

  /// No description provided for @categoryRules.
  ///
  /// In ru, this message translates to:
  /// **'Правила категорий'**
  String get categoryRules;

  /// No description provided for @addRule.
  ///
  /// In ru, this message translates to:
  /// **'Добавить правило'**
  String get addRule;

  /// No description provided for @keyword.
  ///
  /// In ru, this message translates to:
  /// **'Ключевое слово'**
  String get keyword;

  /// No description provided for @rulePattern.
  ///
  /// In ru, this message translates to:
  /// **'Слово в названии или штрихкод'**
  String get rulePattern;

  /// No description provided for @rememberCategoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запомнить категорию?'**
  String get rememberCategoryTitle;

  /// No description provided for @rememberCategoryMessage.
  ///
  /// In ru, this message translates to:
  /// **'Применять эту категорию ко всем покупкам «{name}»?'**
  String rememberCategoryMessage(String name);

  /// No description provided for @remember.
  ///
  /// In ru, this message translates to:
  /// **'Запомнить'**
  String get remember;

  /// No description provided for @onlyThisItem.
  ///
  /// In ru, this message translates to:
  /// **'Только для этой позиции'**
  String get onlyThisItem;

  /// No description provided for @categoryGroceries.
  ///
  /// In ru, this message translates to:
  /// **'Продукты'**
  String get categoryGroceries;

  /// No description provided for @categoryDairy.
  ///
  /// In ru, this message translates to:
  /// **'Молочное'**
  String get categoryDairy;

  /// No description provided for @categoryMeatFish.
  ///
  /// In ru, this message translates to:
  /// **'Мясо и рыба'**
  String get categoryMeatFish;

  /// No description provided for @categoryFruitVegetables.
  ///
  /// In ru, this message translates to:
  /// **'Овощи и фрукты'**
  String get categoryFruitVegetables;

  /// No description provided for @categoryBakery.
  ///
  /// In ru, this message translates to:
  /// **'Хлеб и выпечка'**
  String get categoryBakery;

  /// No description provided for @categorySweets.
  ///
  /// In ru, this message translates to:
  /// **'Сладости и снеки'**
  String get categorySweets;

  /// No description provided for @categoryDrinks.
  ///
  /// In ru, this message translates to:
  /// **'Напитки'**
  String get categoryDrinks;

  /// No description provided for @categoryAlcohol.
  ///
  /// In ru, this message translates to:
  /// **'Алкоголь'**
  String get categoryAlcohol;

  /// No description provided for @categoryHousehold.
  ///
  /// In ru, this message translates to:
  /// **'Бытовая химия'**
  String get categoryHousehold;

  /// No description provided for @categoryPersonalCare.
  ///
  /// In ru, this message translates to:
  /// **'Гигиена и уход'**
  String get categoryPersonalCare;

  /// No description provided for @categoryPharmacy.
  ///
  /// In ru, this message translates to:
  /// **'Аптека'**
  String get categoryPharmacy;

  /// No description provided for @categoryClothing.
  ///
  /// In ru, this message translates to:
  /// **'Одежда'**
  String get categoryClothing;

  /// No description provided for @categoryElectronics.
  ///
  /// In ru, this message translates to:
  /// **'Электроника'**
  String get categoryElectronics;

  /// No description provided for @categoryRestaurants.
  ///
  /// In ru, this message translates to:
  /// **'Кафе и рестораны'**
  String get categoryRestaurants;

  /// No description provided for @categoryTransport.
  ///
  /// In ru, this message translates to:
  /// **'Транспорт и топливо'**
  String get categoryTransport;

  /// No description provided for @categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Прочее'**
  String get categoryOther;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @currency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get currency;

  /// No description provided for @currencyKzt.
  ///
  /// In ru, this message translates to:
  /// **'Казахстанский тенге (₸)'**
  String get currencyKzt;

  /// No description provided for @numberFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат сумм'**
  String get numberFormat;

  /// No description provided for @dataManagement.
  ///
  /// In ru, this message translates to:
  /// **'Ваши данные'**
  String get dataManagement;

  /// No description provided for @exportCsv.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvDescription.
  ///
  /// In ru, this message translates to:
  /// **'Чеки и позиции для Excel'**
  String get exportCsvDescription;

  /// No description provided for @exportBackup.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить JSON-бэкап'**
  String get exportBackup;

  /// No description provided for @exportBackupDescription.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия чеков, категорий и правил'**
  String get exportBackupDescription;

  /// No description provided for @importBackup.
  ///
  /// In ru, this message translates to:
  /// **'Импорт JSON-бэкапа'**
  String get importBackup;

  /// No description provided for @importBackupDescription.
  ///
  /// In ru, this message translates to:
  /// **'Объединить с текущими данными без дублей'**
  String get importBackupDescription;

  /// No description provided for @exporting.
  ///
  /// In ru, this message translates to:
  /// **'Готовим файл…'**
  String get exporting;

  /// No description provided for @importing.
  ///
  /// In ru, this message translates to:
  /// **'Восстанавливаем данные…'**
  String get importing;

  /// No description provided for @importSucceeded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено чеков: {added}. Пропущено дублей: {duplicates}.'**
  String importSucceeded(int added, int duplicates);

  /// No description provided for @invalidBackup.
  ///
  /// In ru, this message translates to:
  /// **'Этот файл не похож на резервную копию CheckScan'**
  String get invalidBackup;

  /// No description provided for @unsupportedBackup.
  ///
  /// In ru, this message translates to:
  /// **'Эта версия резервной копии пока не поддерживается'**
  String get unsupportedBackup;

  /// No description provided for @exportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подготовить файл'**
  String get exportFailed;

  /// No description provided for @deleteAllData.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все данные'**
  String get deleteAllData;

  /// No description provided for @deleteAllTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все данные?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllMessage.
  ///
  /// In ru, this message translates to:
  /// **'Будут удалены все чеки, категории и правила на этом устройстве. Сначала можно сохранить JSON-бэкап.'**
  String get deleteAllMessage;

  /// No description provided for @deleteAllConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите удаление'**
  String get deleteAllConfirmTitle;

  /// No description provided for @deleteAllConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить данные без резервной копии не получится.'**
  String get deleteAllConfirmMessage;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить безвозвратно'**
  String get deleteAllConfirm;

  /// No description provided for @allDataDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Все данные удалены'**
  String get allDataDeleted;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In ru, this message translates to:
  /// **'CheckScan помогает учитывать расходы по фискальным чекам Казахстана. Для получения чека приложение обращается к его ОФД. Телеметрии и облачной синхронизации нет.'**
  String get aboutDescription;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String version(String version);

  /// No description provided for @privacy.
  ///
  /// In ru, this message translates to:
  /// **'Хранение данных'**
  String get privacy;

  /// No description provided for @debugTitle.
  ///
  /// In ru, this message translates to:
  /// **'Диагностика QR и ОФД'**
  String get debugTitle;

  /// No description provided for @debugRawQr.
  ///
  /// In ru, this message translates to:
  /// **'Исходная строка QR'**
  String get debugRawQr;

  /// No description provided for @debugDecodedQr.
  ///
  /// In ru, this message translates to:
  /// **'Строка после HTML-декодирования'**
  String get debugDecodedQr;

  /// No description provided for @debugResponse.
  ///
  /// In ru, this message translates to:
  /// **'Ответ ОФД'**
  String get debugResponse;

  /// No description provided for @debugCopy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать диагностику'**
  String get debugCopy;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @sendToDeveloper.
  ///
  /// In ru, this message translates to:
  /// **'Отправить разработчику'**
  String get sendToDeveloper;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка…'**
  String get loading;

  /// No description provided for @refresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get refresh;

  /// No description provided for @manualEntry.
  ///
  /// In ru, this message translates to:
  /// **'Ввести вручную'**
  String get manualEntry;

  /// No description provided for @newPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Новая покупка'**
  String get newPurchase;

  /// No description provided for @addedManually.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено вручную'**
  String get addedManually;

  /// No description provided for @addAtLeastOneItem.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы одну позицию'**
  String get addAtLeastOneItem;

  /// No description provided for @manualEntryHint.
  ///
  /// In ru, this message translates to:
  /// **'Чек не сканируется? Введите товары, цены и категории вручную.'**
  String get manualEntryHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
