import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beltech/core/api/api_exception.dart';
import 'package:beltech/core/theme/app_theme.dart';
import 'package:beltech/core/utils/phone_utils.dart';
import 'package:beltech/core/utils/text_utils.dart';
import 'package:beltech/models/payment.dart';
import 'package:beltech/models/payment_flow_spec.dart';
import 'package:beltech/models/station.dart';
import 'package:beltech/models/user.dart';
import 'package:beltech/models/vehicle.dart';
import 'package:beltech/screens/auth/sign_up_screen.dart';
import 'package:beltech/services/payment_service.dart';
import 'package:beltech/services/station_service.dart';
import 'package:beltech/widgets/bike_bottom_nav.dart';
import 'package:beltech/widgets/password_input.dart';
import 'package:beltech/widgets/rn_button.dart';
import 'package:beltech/widgets/vehicle_menu.dart';

void main() {
  testWidgets('bottom navigation is anchored and forwards taps', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: BikeBottomNav(
            index: selectedIndex,
            onChanged: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    final scaffoldRect = tester.getRect(find.byType(Scaffold));
    final navigationRect = tester.getRect(find.byType(BikeBottomNav));
    expect(navigationRect.bottom, closeTo(scaffoldRect.bottom, 0.1));
    expect(navigationRect.top, greaterThan(scaffoldRect.center.dy));

    await tester.tap(find.text('Карта'));
    expect(selectedIndex, 1);
  });

  testWidgets('bottom navigation follows the active theme', (tester) async {
    Widget build(ThemeData theme) => MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: BikeBottomNav(index: 0, onChanged: (_) {}),
      ),
    );

    await tester.pumpWidget(build(AppTheme.light));
    final light = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.decoration is BoxDecoration)
        .map((c) => (c.decoration! as BoxDecoration).color)
        .whereType<Color>()
        .toList();
    await tester.pumpWidget(build(AppTheme.dark));
    await tester.pumpAndSettle();
    final dark = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.decoration is BoxDecoration)
        .map((c) => (c.decoration! as BoxDecoration).color)
        .whereType<Color>()
        .toList();
    expect(light, isNotEmpty);
    expect(dark, isNotEmpty);
    expect(light.first, isNot(dark.first));
  });

  testWidgets('bottom navigation highlights only the active tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: BikeBottomNav(index: 0, onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Color? colorOf(String label) => tester
        .widgetList<Text>(find.text(label))
        .map((t) => t.style?.color)
        .whereType<Color>()
        .firstOrNull;

    final home = colorOf('Главная');
    final map = colorOf('Карта');
    expect(home, isNotNull);
    expect(map, isNotNull);
    expect(home, isNot(map));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: BikeBottomNav(index: 3, onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pay = colorOf('Оплата');
    expect(pay, home);
    expect(colorOf('Карта'), isNot(pay));
    expect(colorOf('Главная'), isNot(pay));
  });

  test('normalizes API html and preserves regular slashes', () {
    expect(
      cleanApiText('Пн<br \\/> Сб<br/>&#40;дом&#41; 26/13'),
      'Пн\nСб\n(дом) 26/13',
    );
    expect(cleanApiText('&lt; 3.5 т &gt;'), '< 3.5 т >');
    expect(cleanApiText('&amp;lt; 3.5 т &amp;gt;'), '< 3.5 т >');
    expect(cleanApiText('Масса < 3.5 т >'), 'Масса < 3.5 т >');
  });

  test('normalizes nested legal profile and vehicle aliases', () {
    final profile = UserProfile.fromJson({
      'data': {
        'isLegal': true,
        'organization': {
          'unp': '123456789',
          'companyName': 'ООО Тест',
          'address': 'Минск',
        },
        'bank': {'bic': 'BIC', 'account': 'BY00'},
      },
    });
    final vehicle = Vehicle.fromJson({
      'vehicleId': '8',
      'vehicleName': 'Geely',
      'vehicleRegNumber': '6442XE-7',
      'certNumber': 'KA777445',
    });

    expect(profile.isLegal, isTrue);
    expect(profile.unp, '123456789');
    expect(profile.nameOrg, 'ООО Тест');
    expect(profile.bankBic, 'BIC');
    expect(vehicle.id, 8);
    expect(vehicle.vehiclePassport, 'KA777445');
  });

  test('extracts station number and identifies admission permits', () {
    final station = DiagnosticStation.fromJson({
      'id': 1,
      'title': 'ДС №255 — диагностическая станция',
    });
    final permit = PaymentService.fromJson({
      'id': 10,
      'title': 'Получение разрешения на допуск',
    });

    expect(station.stationNumber, 'ДС №255');
    expect(permit.isAdmissionPermit, isTrue);
    expect(permit.requiresVehicle, isFalse);
  });

  test('parses scalar vehicle field values', () {
    final field = VehicleTypeField.fromJson({
      'name': 'MASSA',
      'values': ['1500', '3000'],
    });

    expect(field.values?.map((value) => value.apiValue), [1500, 3000]);
    expect(field.values?.every((value) => value.id > 0), isTrue);
  });

  test('inherits slot day and service ids from the API group', () {
    final group = StationDaySlots.fromJson({
      'serviceId': 204883,
      'dayId': 1622741,
      'slots': [
        {'timeSlot': '08:00'},
      ],
    });

    expect(group.slots.single.timeSlot, '08:00');
    expect(group.slots.single.dayId, 1622741);
    expect(group.slots.single.serviceId, 204883);
  });

  test('translates technical payment field names', () {
    final field = VehicleTypeField.fromJson({
      'name': 'TRANS_MOTOR',
      'title': 'motor',
    });

    expect(field.title, 'Тип двигателя');
  });

  test('normalizes payment history order and service fields', () {
    final item = PaymentHistoryItem.fromJson({
      'id': 7,
      'orderId': 'order-7',
      'service': 'Техосмотр',
      'date': '25.09.2026',
      'price': '55',
    });

    expect(item.orderId, 'order-7');
    expect(item.serviceName, 'Техосмотр');
    expect(item.visitDate, '25.09.2026');
  });

  test('extracts OPLATI links from scalar order responses', () {
    final order = OrderInfo.fromJson({'data': 'oplati://payment?id=42'});

    expect(order.linkToPay, 'oplati://payment?id=42');
  });

  test('reads the order number from the plain id field', () {
    final order = OrderInfo.fromJson({'id': 1647148, 'payService': 'webpay'});

    expect(order.orderId, '1647148');
  });

  test('reads documents from alternative order response keys', () {
    final order = OrderInfo.fromJson({
      'orderId': 55,
      'docs': [
        {'title': 'Счёт', 'href': 'https://example.com/invoice.pdf'},
      ],
    });

    expect(order.documents?.length, 1);
    expect(order.documents?.first.title, 'Счёт');
  });

  test('keeps the ERIP instruction from a legal order response', () {
    final order = OrderInfo.fromJson({
      'orderId': 77,
      'infoHtml': '<p>Оплатите в ЕРИП</p>',
    });

    expect(order.orderId, '77');
    expect(order.infoHtml, '<p>Оплатите в ЕРИП</p>');
  });

  test('card and ERIP orders report the same payable amount', () {
    // Расчёт стоимости даёт 59,20: это цена без печати диагностической
    // карты. Заказ на 5,00 дороже, и именно эту сумму списывают — обоими
    // способами. Приложение обязано показывать итог заказа, а не расчёт,
    // иначе перед оплатой видна одна цифра, а с карты списывается другая.
    const quote = '59.20';
    const charged = '64.20';

    final card = OrderInfo.fromJson({
      'orderId': 1902665,
      'payMethod': 58341,
      'payService': 'webpay',
      'webpayForm': {
        'action': 'https://payment.webpay.by',
        'wsb_storeid': 941711284,
        'wsb_order_num': 1902665,
        'wsb_currency_id': 'BYN',
        'wsb_total': charged,
        'wsb_invoice_item_name':
            'Проведение государственного технического осмотра',
        'wsb_invoice_item_quantity': 1,
        'wsb_invoice_item_price': charged,
        'wsb_signature': '06ec18576a51e7843812d3bcc30cbe594ce50e7f',
      },
    });
    final erip = OrderInfo.fromJson({
      'orderId': 1902783,
      'payMethod': 58342,
      'payService': 'erip',
      // Настоящий текст инструкции: в нём есть и путь по меню ЕРИП, и номер
      // заказа, и сумма, и срок действия. Суммой является только последнее
      // число перед словом «руб».
      'info':
          'Для оплаты услуги через систему "Расчет" (ЕРИП) выберите '
          'последовательно следующие пункты:<br>\r\n <br>\r\n'
          ' Система "Расчёт" (ЕРИП) &gt; Прочие платежи &gt; БЕЛТЕХОСМОТР '
          '&gt; Техосмотр<br>\r\n <br>\r\n'
          'Номер заказа: 250321 на сумму $charged руб.<br>\r\n <br>\r\n'
          'Номер заказа действителен в течение 20 суток с момента получения',
    });

    expect(PriceInfo.fromResponse({'price': quote}).price, quote);
    expect(card.price, charged);
    expect(erip.price, charged);
    expect(card.price, erip.price);
  });

  test('an order without an amount does not invent one', () {
    // Прицеп 0,75–3,5 т сервер не оценивает: расчёт приходит нулевым, и в
    // заказе суммы нет ни в подписанной форме, ни в тексте инструкции.
    // Показывать расчёт или ноль нельзя — оплата по неизвестной цене.
    final card = OrderInfo.fromJson({
      'orderId': 1902675,
      'payMethod': 58341,
      'payService': 'webpay',
      'webpayForm': {
        'action': 'https://payment.webpay.by/1',
        'wsb_total': null,
      },
    });
    final erip = OrderInfo.fromJson({
      'orderId': 1902678,
      'payMethod': 58342,
      'payService': 'erip',
      'info':
          'Номер заказа: 250311 на сумму  руб.<br>\r\n <br>\r\n'
          'Номер заказа действителен в течение 20 суток',
    });

    expect(card.price, isNull);
    expect(erip.price, isNull);
    expect(eripInstructionAmount(erip.info), isNull);
  });

  test('a zero total is treated as no price at all', () {
    // Ноль — это отсутствие цены, а не цена: подставлять его в оплату нельзя.
    final order = OrderInfo.fromJson({
      'orderId': 1,
      'webpayForm': {'wsb_total': '0.00'},
    });
    final erip = OrderInfo.fromJson({
      'orderId': 2,
      'info': 'Оплатите на сумму 0 руб.',
    });

    expect(order.price, isNull);
    expect(erip.price, isNull);
  });

  test('reads the ERIP amount from the instruction text', () {
    expect(
      eripInstructionAmount('Номер заказа: 250307 на сумму 64.2 руб.'),
      '64.2',
    );
    expect(eripInstructionAmount('оплата 83,70 рублей'), '83,70');
    // Валюта в инструкции пишется по-разному: «р.» и «BYN» — то же «руб».
    expect(
      eripInstructionAmount('Номер заказа: 250307 на сумму 10,50 р.'),
      '10,50',
    );
    expect(
      eripInstructionAmount('Номер заказа: 250307 на сумму 10.50 BYN'),
      '10.50',
    );
    expect(
      eripInstructionAmount('Номер заказа: 250307 на сумму 10,50 бел. руб.'),
      '10,50',
    );
    // Номер заказа и срок действия суммой не являются.
    expect(
      eripInstructionAmount(
        'Номер заказа: 250307 действителен 20 суток с момента получения',
      ),
      isNull,
    );
    expect(eripInstructionAmount(''), isNull);
    expect(eripInstructionAmount(null), isNull);
  });

  test(
    'a chosen bank transfer is not turned into a card payment by the server',
    () {
      // Юрлицо выбрало безналичный расчёт, а сервер вернул в заказе webpay.
      // Выбор пользователя важнее: платить в приложении нечего, и кнопка
      // «Оплатить» показываться не должна.
      expect(
        resolvePaymentKind(
          methodTitle: 'Безналичный расчёт',
          payService: 'webpay',
        ),
        PaymentMethodKind.noncash,
      );
      expect(
        resolvePaymentKind(
          methodTitle: 'Безналичный расчет',
          payService: 'erip',
        ),
        PaymentMethodKind.noncash,
      );
      // Выбранную карту серверные данные тоже не должны перебивать.
      expect(
        resolvePaymentKind(
          methodTitle: 'Банковской картой онлайн',
          payService: 'noncash',
        ),
        PaymentMethodKind.webpay,
      );
      // Если способ опознать не удалось, остаётся то, что сказал сервер.
      expect(
        resolvePaymentKind(methodTitle: '', payService: 'erip'),
        PaymentMethodKind.erip,
      );
      expect(resolvePaymentKind(), PaymentMethodKind.unknown);
    },
  );

  test('keeps the contract out of the document download list', () {
    // Сверка идёт по буквам: регистр и номер не важны.
    expect(isContractDocument('Договор'), isTrue);
    expect(isContractDocument('договор'), isTrue);
    expect(isContractDocument('Договор №123'), isTrue);
    expect(isContractDocument('ДОГОВОР 45'), isTrue);
    expect(isContractDocument('', title: 'Договор'), isTrue);
    // Другие документы остаются, в том числе те, где слово есть в середине.
    expect(isContractDocument('Счёт'), isFalse);
    expect(isContractDocument('Счёт к договору'), isFalse);
    expect(isContractDocument('Договор оказания услуг'), isFalse);
    expect(isContractDocument(null), isFalse);
  });

  test('document label comes from the server value, with a title fallback', () {
    expect(documentLabel('Счёт'), 'Счёт');
    expect(documentLabel(''), 'Документ');
    expect(documentLabel(null), 'Документ');
    expect(documentLabel('', title: 'Акт'), 'Акт');
    expect(documentLabel('Счёт', title: 'Акт'), 'Счёт');
  });

  test('detects a bank transfer as a non-cash method, not ERIP', () {
    expect(
      classifyPaymentMethod(title: 'Банковский перевод (безналичный расчет)'),
      PaymentMethodKind.noncash,
    );
    expect(
      classifyPaymentMethod(title: 'АИС "Расчёт" (ЕРИП)'),
      PaymentMethodKind.erip,
    );
    expect(
      classifyPaymentMethod(title: 'Банковской картой онлайн'),
      PaymentMethodKind.webpay,
    );
    expect(
      classifyPaymentMethod(title: 'Приложение "Оплати"'),
      PaymentMethodKind.oplati,
    );
    expect(classifyPaymentMethod(), PaymentMethodKind.unknown);
  });

  test('validates Belarusian UNP checksum', () {
    expect(isValidUnp('101000004'), isTrue);
    expect(isValidUnp('123456789'), isFalse);
  });

  test('accepts every certificate number format', () {
    expect(isValidCertNumber('7TK0021139'), isTrue);
    expect(isValidCertNumber('7TK00122138'), isTrue);
    expect(isValidCertNumber('АВ1234567'), isTrue);
    expect(isValidCertNumber('1234АВ123'), isTrue);
    expect(isValidCertNumber('7 TK 0021139'), isTrue);
    expect(isValidCertNumber('7TK-0021139'), isTrue);
    expect(isValidCertNumber('12345678'), isFalse);
    expect(isValidCertNumber('АВСДЕФ'), isFalse);
    expect(isValidCertNumber(''), isFalse);
  });

  test('normalizes scalar WebPay invoice fields to indexed names', () {
    final form = WebPayForm.fromJson({
      'action': 'https://payment.webpay.by',
      'wsb_invoice_item_name': 'Техосмотр',
      'wsb_invoice_item_price': '38.00',
      'wsb_invoice_item_quantity': '1',
    });

    expect(form.rawFields['wsb_invoice_item_name[0]'], 'Техосмотр');
    expect(form.rawFields['wsb_invoice_item_price[0]'], '38.00');
    expect(form.rawFields['wsb_invoice_item_quantity[0]'], '1');
  });

  test('parses read-only vehicle count metadata', () {
    final field = VehicleTypeField.fromJson({'name': 'COL_TS', 'min': 2});

    expect(field.min, 2);
  });

  test('removes duplicated station numbers from payment station labels', () {
    final station = PaymentStation.fromJson({
      'id': 210,
      'title': 'ДС№210-УП "БЕЛТЕХОСМОТР"ДС№210',
      'address': 'ДС№210',
    });

    expect(station.title, 'ДС№210-УП "БЕЛТЕХОСМОТР"');
    expect(station.address, isNull);
  });

  test('keeps a real station address as subtitle', () {
    final station = PaymentStation.fromJson({
      'id': 211,
      'title': 'ДС№211-УП "БЕЛТЕХОСМОТР"',
      'address': 'г. Минск, ул. Ленина, 5',
    });

    expect(station.title, 'ДС№211-УП "БЕЛТЕХОСМОТР"');
    expect(station.address, 'г. Минск, ул. Ленина, 5');
  });

  test('physical users only see the three permitted services', () {
    final admission = PaymentService.fromJson({
      'id': 58434,
      'title':
          'Получение разрешения на допуск ТС к участию в дорожном движении',
    });
    final inspection = PaymentService.fromJson({
      'id': 58439,
      'title': 'Проведение государственного технического осмотра',
    });
    final repeat = PaymentService.fromJson({
      'id': 58442,
      'title':
          'Отдельные виды контрольно-диагностических работ при повторном прохождении',
    });
    final ekmT = PaymentService.fromJson({
      'id': 58441,
      'title': 'Проверка технического состояния ТС (ЕКМТ)',
    });

    expect(PaymentFlowResolver.isVisibleFor(admission, isLegal: false), isTrue);
    expect(
      PaymentFlowResolver.isVisibleFor(inspection, isLegal: false),
      isTrue,
    );
    expect(PaymentFlowResolver.isVisibleFor(repeat, isLegal: false), isTrue);
    expect(PaymentFlowResolver.isVisibleFor(ekmT, isLegal: false), isFalse);
    expect(PaymentFlowResolver.isVisibleFor(ekmT, isLegal: true), isTrue);
    expect(PaymentFlowResolver.isVisibleFor(admission, isLegal: true), isTrue);
  });

  test('station services hide EKMT from physical users', () {
    final ekmT = StationService(
      id: 1,
      title: 'Технический контроль ЕКМТ',
      price: '100',
    );
    final inspection = StationService(
      id: 2,
      title: 'Государственный технический осмотр',
      price: '50',
    );
    final preSale = StationService(
      id: 3,
      title: 'Комплексная предпродажная диагностика',
      price: '80',
    );
    final services = [ekmT, inspection, preSale];

    final forPhysical = filterStationServices(services, isLegal: false);
    expect(forPhysical, isNot(contains(ekmT)));
    expect(forPhysical, containsAll([inspection, preSale]));

    final forLegal = filterStationServices(services, isLegal: true);
    expect(forLegal, containsAll([ekmT, inspection, preSale]));
  });

  test('legal admission permit asks for a station, payment and requisites', () {
    final service = PaymentService.fromJson({
      'id': 58434,
      'title':
          'Получение разрешения на допуск ТС к участию в дорожном движении',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    // Место оказания услуги не спрашивается: сразу способ оплаты, затем
    // реквизиты и экран документов.
    expect(spec.steps, [FlowStep.method, FlowStep.personal, FlowStep.order]);
    expect(spec.requiresStation, isFalse);
    expect(spec.hasCheckboxesForPayment, isTrue);
    expect(spec.hasVehicleFields, isFalse);
  });

  test('physical admission permit goes to personal data and payment', () {
    final service = PaymentService.fromJson({
      'id': 58434,
      'title':
          'Получение разрешения на допуск ТС к участию в дорожном движении',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: false);

    // Место оказания услуги не выбирается: услуга не привязана к станциям.
    expect(spec.steps, [FlowStep.personal, FlowStep.method, FlowStep.order]);
    expect(spec.requireCert, isTrue);
    expect(spec.requiresStation, isFalse);
    expect(spec.hasVehicleFields, isFalse);
    expect(spec.requirePersonalReg, isFalse);
  });

  test('physical technical inspection starts with a station', () {
    final service = PaymentService.fromJson({
      'id': 58439,
      'title': 'Проведение государственного технического осмотра',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: false);

    expect(spec.steps, [
      FlowStep.station,
      FlowStep.personal,
      FlowStep.vehicle,
      FlowStep.method,
      FlowStep.order,
    ]);
    expect(spec.requiresVehicleType, isTrue);
    expect(spec.requirePersonalReg, isTrue);
    // Дополнительные поля приходят с выбранным типом ТС, поэтому сценарий не
    // ограничивает их список.
    expect(spec.requiresVehicleCount, isFalse);
  });

  test('every vehicle type field is shown, whatever the type is', () {
    // У грузовых и прицепов сервер тоже присылает параметры (масса, колёса),
    // и раньше они скрывались: фильтр по названию типа гасил их, из-за чего
    // расчёт стоимости не проходил.
    final type = VehicleType.fromJson({
      'id': 3,
      'title': 'Грузовой автомобиль',
      'fields': [
        {
          'name': 'TRANS_MASSA',
          'title': 'massa',
          'isRequired': true,
          'values': ['1500', '3000'],
        },
      ],
    });

    expect(type.fields?.single.name, 'TRANS_MASSA');
    expect(type.fields?.single.isRequired, isTrue);
    expect(type.fields?.single.values?.length, 2);
  });

  test('legal EKMT flow asks axles and vehicle count with the requisites', () {
    final service = PaymentService.fromJson({
      'id': 58441,
      'title': 'Проверка технического состояния ТС для подтверждения ЕКМТ',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.steps, [
      FlowStep.station,
      FlowStep.method,
      FlowStep.personal,
      FlowStep.vehicle,
      FlowStep.order,
    ]);
    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.hasVehicleFields, isTrue);
  });

  test('legal dangerous goods permit requires a station', () {
    final service = PaymentService.fromJson({
      'id': 58438,
      'title':
          'Получение (продление срока действия) свидетельства о допуске '
          'транспортного средства к перевозке определенных опасных грузов',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.requiresStation, isTrue);
    expect(spec.steps.first, FlowStep.station);
    // Тип ТС не запрашивается, количество ТС — на шаге реквизитов.
    expect(spec.requiresVehicleType, isFalse);
    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.hasCheckboxesForPayment, isTrue);
    // Представитель и банковские данные запрашиваются, СТС и госномер — нет.
    expect(spec.legalRequisites, contains(LegalField.bankBic));
    expect(spec.legalRequisites, contains(LegalField.face));
    expect(spec.legalRequisites, contains(LegalField.mainDoc));
    expect(spec.legalRequisites, isNot(contains(LegalField.cert)));
    expect(spec.legalRequisites, isNot(contains(LegalField.regNumber)));
  });

  test('legal extra check of dangerous goods vehicle requires a station', () {
    final service = PaymentService.fromJson({
      'id': 58422,
      'title': 'Дополнительная проверка ТС для перевозки опасных грузов',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.requiresStation, isTrue);
    expect(spec.steps.first, FlowStep.station);
    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.hasCheckboxesForPayment, isTrue);
    // Банковские данные запрашиваются, свидетельство о регистрации — нет.
    expect(spec.legalRequisites, contains(LegalField.bankAccount));
    expect(spec.legalRequisites, isNot(contains(LegalField.cert)));
    expect(spec.legalRequisites, isNot(contains(LegalField.face)));
  });

  test('legal state technical inspection requires a station', () {
    final service = PaymentService.fromJson({
      'id': 58434,
      'title': 'Проведение государственного технического осмотра',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.requiresStation, isTrue);
    expect(spec.steps.first, FlowStep.station);
    expect(spec.requiresVehicleType, isTrue);
  });

  test('EKMT asks for vehicle type, then axles and vehicle count', () {
    final service = PaymentService.fromJson({
      'id': 58441,
      'title':
          'Проверка технического состояния транспортного средства для '
          'подтверждения соответствия техническим нормам ЕКМТ',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.requiresVehicleType, isTrue);
    expect(spec.requiresAxlesSelection, isTrue);
    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.axlesOptions, [2, 3]);
  });

  test('the calculation becomes the total only where the counter is asked', () {
    PaymentFlowSpec spec(int id, String title) => PaymentFlowResolver.resolve(
      PaymentService.fromJson({'id': id, 'title': title}),
      isLegal: true,
    );

    // Заказ по этим услугам сервер возвращает без суммы: ни в форме, ни в
    // тексте инструкции ЕРИП её нет. Расчёт при этом остаётся верным итогом,
    // потому что количество ТС уходит в него тем же числом, что и в заказ.
    for (final service in const [
      (58418, 'Получение международного сертификата технического осмотра'),
      (
        58433,
        'Проверка технического состояния транспортных средств '
            'на соответствие нормам ЕКМТ',
      ),
      (58438, 'Получение свидетельства о допуске к перевозке опасных грузов'),
    ]) {
      expect(
        spec(service.$1, service.$2).mayUseCalculationAsTotal,
        isTrue,
        reason: service.$2,
      );
    }

    // ГТО и разрешение на допуск счётчика не спрашивают, и там расчёт на 5 BYN
    // меньше итога: подставлять его вместо серверной суммы нельзя.
    for (final service in const [
      (58439, 'Проведение государственного технического осмотра'),
      (58434, 'Получение разрешения на допуск ТС к дорожному движению'),
      (58442, 'Отдельные виды контрольно-диагностических работ'),
    ]) {
      expect(
        spec(service.$1, service.$2).mayUseCalculationAsTotal,
        isFalse,
        reason: service.$2,
      );
    }
  });

  test('EKMT asks for axles while the vehicle type is not chosen', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58441,
        'title': 'Проверка технического состояния ТС для подтверждения ЕКМТ',
      }),
      isLegal: true,
    );

    // Пока тип не выбран, поле осей не показывается.
    expect(spec.requiresAxlesFor(null), isFalse);
  });

  test('international certificate asks only for vehicle count', () {
    final service = PaymentService.fromJson({
      'id': 58418,
      'title': 'Получение международного сертификата технического осмотра',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.requiresVehicleType, isFalse);
    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.requiresAxlesSelection, isFalse);
  });

  test('legal requisites carry vehicle data and the price', () {
    final service = PaymentService.fromJson({
      'id': 58439,
      'title': 'Проведение государственного технического осмотра',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);
    final steps = spec.steps;

    // Место → оплата → реквизиты → ТС со стоимостью → заказ.
    expect(steps, [
      FlowStep.station,
      FlowStep.method,
      FlowStep.personal,
      FlowStep.vehicle,
      FlowStep.order,
    ]);
    expect(spec.hasVehicleFields, isTrue);
  });

  test('legal technical inspection asks for a short set of requisites', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: true,
    );

    // Банковские реквизиты у техосмотра не спрашиваются.
    expect(spec.legalRequisites, [
      LegalField.unp,
      LegalField.codePodr,
      LegalField.nameOrg,
      LegalField.cert,
      LegalField.regNumber,
      LegalField.email,
    ]);
    expect(spec.legalRequisites, isNot(contains(LegalField.bankAccount)));
    expect(spec.legalRequisites, isNot(contains(LegalField.face)));
    expect(spec.requiresCertNumber, isTrue);
  });

  test('legal repeat diagnostic asks for a certificate number', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58442,
        'title':
            'Отдельные виды контрольно-диагностических работ при повторном '
            'прохождении (техосмотр)',
      }),
      isLegal: true,
    );

    // Без свидетельства о регистрации сервер отклоняет заказ на оплате.
    expect(spec.legalRequisites, contains(LegalField.cert));
    expect(spec.requireCertainTypes, isTrue);
  });

  test('each legal service asks only for its own requisites', () {
    PaymentFlowSpec spec(int id, String title) => PaymentFlowResolver.resolve(
      PaymentService.fromJson({'id': id, 'title': title}),
      isLegal: true,
    );

    // Свидетельство о допуске к перевозке опасных грузов: представитель и
    // банковские данные, без СТС и госномера.
    expect(
      spec(
        58438,
        'Получение свидетельства о допуске к перевозке опасных грузов',
      ).legalRequisites,
      [
        LegalField.unp,
        LegalField.codePodr,
        LegalField.nameOrg,
        LegalField.face,
        LegalField.mainDoc,
        LegalField.location,
        LegalField.bankAccount,
        LegalField.bankName,
        LegalField.bankBic,
        LegalField.email,
      ],
    );

    // Сертификат технического контроля и дополнительная проверка: банковские
    // данные, но без СТС.
    final cert = spec(58499, 'Получение сертификата технического контроля');
    expect(cert.legalRequisites, isNot(contains(LegalField.cert)));
    expect(cert.legalRequisites, contains(LegalField.bankAccount));
    final extra = spec(
      58422,
      'Дополнительная проверка ТС для перевозки грузов',
    );
    expect(extra.legalRequisites, isNot(contains(LegalField.cert)));
    expect(extra.legalRequisites, contains(LegalField.bankBic));

    // Международный сертификат: представитель есть, СТС и госномера нет.
    final international = spec(
      58418,
      'Получение международного сертификата технического осмотра',
    );
    expect(international.legalRequisites, contains(LegalField.face));
    expect(international.legalRequisites, contains(LegalField.mainDoc));
    expect(international.legalRequisites, isNot(contains(LegalField.cert)));
    expect(
      international.legalRequisites,
      isNot(contains(LegalField.regNumber)),
    );

    // Допуск к дорожному движению: полный набор.
    expect(
      spec(
        58434,
        'Получение разрешения на допуск ТС к дорожному движению',
      ).legalRequisites,
      fullLegalRequisites,
    );
  });

  test('axles are asked for a trailer only in the 0,75-3,5 t range', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: false,
    );

    // Оси нужны только у прицепа, и только когда выбрана масса >0,75 и <3,5.
    final trailer = VehicleType.fromJson({
      'id': 34,
      'title': 'Прицеп/полуприцеп',
    });
    expect(spec.requiresAxlesFor(trailer), isTrue);
    expect(spec.requiresAxlesForMass('> 0,75т и < 3,5т'), isTrue);
    // Остальные диапазоны прицепа осей не спрашивают.
    for (final mass in const [
      'Менее 0,75т',
      '> 0,75т и < 3,5т',
      '> 3,5т и < 10т',
      '> 10т',
    ]) {
      final wants = mass == '> 0,75т и < 3,5т';
      expect(spec.requiresAxlesForMass(mass), wants, reason: mass);
    }
    // У грузовика и комбинации с прицепом осей не спрашивают.
    for (final title in const [
      'Грузовой автомобиль',
      'Грузовой автомобиль+Прицеп (полуприцеп)',
      'Автобус',
      'Мопед',
      'Легковой автомобиль',
      'Мотоцикл',
    ]) {
      final type = VehicleType.fromJson({'id': 1, 'title': title});
      expect(spec.requiresAxlesFor(type), isFalse, reason: title);
    }
    // Пока не выбран тип или масса, оси не показываются.
    expect(spec.requiresAxlesFor(null), isFalse);
    expect(spec.requiresAxlesForMass(null), isFalse);
    expect(spec.requiresAxlesForMass(''), isFalse);
    expect(spec.axlesOptions, [1, 2]);
    // Показывается «1» и «2», а сервер ждёт элемент справочника: одна оса —
    // это 111, две — 49. С числом осей вместо идентификатора цена прицепа
    // считалась нулевой, и пришлось бы гадать, какое значение уходит в запрос.
    expect(spec.axlesApiId(1), 111);
    expect(spec.axlesApiId(2), 49);
    // Значения без идентификатора уходят как есть.
    expect(spec.axlesApiId(3), 3);
  });

  test('a legal inspection asks for trailer axles like individuals', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: true,
    );

    // У прицепа 0,75–3,5 т оси спрашиваются и у юрлиц: одна — 111, две — 49.
    expect(spec.requiresAxlesSelection, isTrue);
    expect(spec.axlesOptions, [1, 2]);
    expect(
      spec.requiresAxlesFor(VehicleType(id: 34, title: 'Прицеп/полуприцеп')),
      isTrue,
    );
    expect(
      spec.requiresAxlesFor(VehicleType(id: 29, title: 'Грузовой автомобиль')),
      isFalse,
    );
    expect(spec.axlesApiId(1), 111);
    expect(spec.axlesApiId(2), 49);
    // Серверное поле TRANS_OS скрыто: оси задаёт сценарий.
    expect(spec.showsVehicleField('TRANS_OS'), isFalse);
  });

  test('the service id, not the title, sets the requisites and the total', () {
    PaymentFlowSpec spec(int id) => PaymentFlowResolver.resolve(
      // Название намеренно не совпадает с услугой: набор полей и итог задаёт
      // номер услуги, а не текст.
      PaymentService.fromJson({'id': id, 'title': 'Услуга'}),
      isLegal: true,
    );

    for (final id in const [58418, 58433, 58438]) {
      expect(spec(id).legalRequisites, representativeRequisites, reason: '$id');
      expect(spec(id).mayUseCalculationAsTotal, isTrue, reason: '$id');
    }
  });

  test('server axles ids are passed through untouched', () {
    // У ЕКМТ поле TRANS_OS присылает сервер, поэтому приложение не переводит
    // его значения и отправляет как есть.
    final ekmT = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58441,
        'title':
            'Проверка технического состояния ТС для подтверждения соответствия '
            'техническим нормам ЕКМТ',
      }),
      isLegal: true,
    );
    final inspection = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: true,
    );

    expect(ekmT.axlesApiIds, isEmpty);
    expect(ekmT.axlesApiId(2), 2);
    expect(ekmT.axlesApiId(3), 3);
    // У техосмотра юрлица оси спрашиваются так же, как у физлиц: прицеп
    // 0,75–3,5 т, значения переводятся в идентификаторы справочника.
    expect(inspection.requiresAxlesSelection, isTrue);
    expect(inspection.axlesApiId(1), 111);
    expect(inspection.axlesApiId(2), 49);
  });

  test('the server axles field is shown only where axles are asked', () {
    final inspection = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: true,
    );
    final ekmT = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58441,
        'title':
            'Проверка технического состояния ТС для подтверждения соответствия '
            'техническим нормам ЕКМТ',
      }),
      isLegal: true,
    );

    // ГТО юрлица осей не спрашивает: серверное поле TRANS_OS скрывается и в
    // `payment` не уходит, а масса и параметры двигателя остаются.
    expect(inspection.showsVehicleField('TRANS_OS'), isFalse);
    expect(inspection.showsVehicleField('TRANS_MASSA'), isTrue);
    expect(inspection.showsVehicleField('TRANS_MOTOR'), isTrue);
    expect(inspection.showsVehicleField('TRANS_KOL'), isTrue);
    // ЕКМТ, наоборот: оси приходят от сервера и показываются.
    expect(ekmT.showsVehicleField('TRANS_OS'), isTrue);
  });

  test('axles are asked for every vehicle type of a legal EKMТ', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58433,
        'title':
            'Проверка технического состояния транспортных средств '
            'на соответствие нормам ЕКМТ',
      }),
      isLegal: true,
    );

    for (final title in const ['Грузовой автомобиль', 'Прицеп/полуприцеп']) {
      final type = VehicleType.fromJson({'id': 1, 'title': title});
      expect(spec.requiresAxlesFor(type), isTrue, reason: title);
    }
    // У грузовика ЕКМТ оси двух или трёх, у прицепа ГТО — одной или двух.
    expect(spec.axlesOptions, [2, 3]);
  });

  test('EKMT axles values follow the selected vehicle type', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58441,
        'title':
            'Проверка технического состояния ТС для подтверждения соответствия '
            'техническим нормам ЕКМТ',
      }),
      isLegal: true,
    );
    // Список, который сервер отдаёт на все типы сразу.
    final values = [
      DropdownValue.fromJson({'id': 49, 'title': '2'}),
      DropdownValue.fromJson({'id': 50, 'title': '3'}),
      DropdownValue.fromJson({'id': 99, 'title': '2+2'}),
      DropdownValue.fromJson({'id': 100, 'title': '2+3(4)'}),
      DropdownValue.fromJson({'id': 101, 'title': '3+2'}),
      DropdownValue.fromJson({'id': 102, 'title': '3+3(4)'}),
      DropdownValue.fromJson({'id': 111, 'title': '1'}),
      DropdownValue.fromJson({'id': 112, 'title': '4'}),
    ];

    // Одиночному ТС подходят только 2 и 3 оси.
    for (final title in const ['Грузовой автомобиль', 'Прицеп/полуприцеп']) {
      expect(spec.filterAxlesValues(title, values).map((value) => value.id), [
        49,
        50,
      ], reason: title);
      expect(spec.isCombinationVehicleType(title), isFalse, reason: title);
    }
    // Комбинации — только составные «X+Y».
    expect(
      spec
          .filterAxlesValues('Грузовой автомобиль+Прицеп (полуприцеп)', values)
          .map((value) => value.id),
      [99, 100, 101, 102],
    );
    expect(
      spec.isCombinationVehicleType('Грузовой автомобиль+Прицеп (полуприцеп)'),
      isTrue,
    );
  });

  test('station name and number are shown on one line without duplication', () {
    DiagnosticStation station(String title, String number) =>
        DiagnosticStation.fromJson({
          'id': 1,
          'title': title,
          'stationNumber': number,
        });

    // Номер из начала названия переносится в конец, без дубля.
    expect(
      station('ДС№210-УП "БЕЛТЕХОСМОТР"', 'ДС№210').displayTitle,
      'УП "БЕЛТЕХОСМОТР" ДС№210',
    );
    // Номер, дописанный через тире, тоже убирается из названия.
    expect(
      station('ДС№211 - «БЕЛТЕХОСМОТР»', 'ДС№211').displayTitle,
      '«БЕЛТЕХОСМОТР» ДС№211',
    );
    // Номер без пробела в названии, с пробелом в самом номере.
    expect(
      station('«БЕЛТЕХОСМОТР»', 'ДС №255').displayTitle,
      '«БЕЛТЕХОСМОТР» ДС №255',
    );
    // Название без номера остаётся как есть.
    expect(station('Гостехосмотр', '').displayTitle, 'Гостехосмотр');
    expect(
      DiagnosticStation.fromJson({'id': 2}).displayTitle,
      'Диагностическая станция',
    );
  });

  test('finds a paid order in history across number formats', () {
    // Номер может прийти с разделителями, в другом регистре или числом — при
    // строгом сравнении оплаченный заказ не находился и оставался
    // неподтверждённым.
    final item = PaymentHistoryItem.fromJson({
      'id': 4321,
      'order_id': '00-123',
      'status': 'paid',
    });

    expect(item.matchesOrder('00-123'), isTrue);
    expect(item.matchesOrder(' 00123 '), isTrue);
    expect(item.matchesOrder('00 123'), isTrue);
    expect(item.matchesOrder('4321'), isTrue);
    // Ведущие нули значимы: «00-123» и «123» — разные номера.
    expect(item.matchesOrder('123'), isFalse);
    expect(item.matchesOrder('999'), isFalse);
    expect(item.matchesOrder(''), isFalse);
    expect(item.isPaid, isTrue);
  });

  test('hides the act document for every service', () {
    // Сервер шлёт общий список шаблонов, и «Акт» попадал в услуги, где его нет.
    // Сравнение по буквам без цифр: регистр и номера не важны.
    for (final label in const ['Акт', 'акт', 'АКТ', 'Акт №12', 'акт 1']) {
      expect(isDocumentHidden(label), isTrue, reason: label);
    }
    // «Договор» скрывался и раньше.
    expect(isDocumentHidden('Договор'), isTrue);
    expect(isDocumentHidden('Договор №123'), isTrue);
    // Остальные документы остаются, в том числе где слово встречается
    // внутри названия.
    for (final label in const [
      'Счёт',
      'Счёт к договору',
      'Договор оказания услуг',
    ]) {
      expect(isDocumentHidden(label), isFalse, reason: label);
    }
    expect(isDocumentHidden(null), isFalse);
  });

  test('a technical control certificate asks for the vehicle count', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Получение сертификата технического контроля',
      }),
      isLegal: true,
    );

    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.requiresVehicleType, isFalse);
  });

  test('the road admission permit never asks for a station', () {
    const title =
        'Получение разрешения на допуск транспортного средства к участию '
        'в дорожном движении';

    for (final isLegal in const [false, true]) {
      // Место оказания услуги у этой услуги не выбирается: ни отдельного шага,
      // ни поля в шагах. Станция не нужна и запросу — цена у разрешения
      // фиксированная.
      final spec = PaymentFlowResolver.resolve(
        PaymentService.fromJson({'id': 58434, 'title': title}),
        isLegal: isLegal,
      );
      expect(spec.requiresStation, isFalse, reason: 'isLegal=$isLegal');
      expect(
        spec.steps.contains(FlowStep.station),
        isFalse,
        reason: 'isLegal=$isLegal steps=${spec.steps}',
      );
    }

    // У соседних услуг выбор станции остаётся: он нужен для расчёта цены.
    final inspection = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: false,
    );
    expect(inspection.steps.first, FlowStep.station);
  });

  test('only legal services offer a document to download', () {
    PaymentFlowSpec spec(int id, String title, {required bool isLegal}) =>
        PaymentFlowResolver.resolve(
          PaymentService.fromJson({'id': id, 'title': title}),
          isLegal: isLegal,
        );

    // Физлица платят картой, ЕРИП или «Оплати»: счёта у них нет, и скачивание
    // показывать негде.
    for (final service in const [
      (58439, 'Проведение государственного технического осмотра'),
      (58442, 'Отдельные виды контрольно-диагностических работ'),
      (58434, 'Получение разрешения на допуск ТС к дорожному движению'),
    ]) {
      expect(
        spec(service.$1, service.$2, isLegal: false).allowsDocumentDownload,
        isFalse,
        reason: service.$2,
      );
    }

    // Юрлица платят переводом и получают счёт.
    for (final service in const [
      (58438, 'Получение свидетельства о допуске к перевозке опасных грузов'),
      (58422, 'Дополнительная проверка ТС для перевозки опасных грузов'),
      (58434, 'Получение разрешения на допуск ТС к дорожному движению'),
      (58442, 'Отдельные виды контрольно-диагностических работ'),
    ]) {
      expect(
        spec(service.$1, service.$2, isLegal: true).allowsDocumentDownload,
        isTrue,
        reason: service.$2,
      );
    }
  });

  test('documents come from the order, not from the scenario', () {
    // Список документов задаёт сервер вместе с заказом: без идентификатора
    // шаблона ссылка не скачивается, поэтому предопределять их в сценарии
    // нельзя.
    final order = OrderInfo.fromJson({
      'orderId': '1647148',
      'documents': [
        {'id': 11, 'value': 'Счет', 'title': 'Счет-фактура'},
        {'id': 12, 'value': 'Акт', 'title': 'Акт оказанных услуг'},
      ],
    });

    expect(order.documents?.length, 2);
    expect(order.documents?.first.id, 11);
    expect(order.documents?.first.value, 'Счет');
  });

  test('a document without a template id is not offered for download', () {
    // Такой документ нельзя открыть: в ссылке останется пустой templateID.
    final order = OrderInfo.fromJson({
      'orderId': '1647148',
      'documents': [
        {'title': 'Счет'},
      ],
    });

    expect(order.documents?.single.id, isNull);
  });

  test('EKMT asks for axles for every vehicle type', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58441,
        'title': 'Проверка технического состояния ТС для подтверждения ЕКМТ',
      }),
      isLegal: true,
    );

    // Оси спрашиваются у грузового автомобиля, прицепа и их комбинации.
    for (final title in const [
      'Грузовой автомобиль',
      'Прицеп/полуприцеп',
      'Грузовой автомобиль + Прицеп (полуприцеп)',
    ]) {
      expect(
        spec.requiresAxlesFor(VehicleType(id: 1, title: title)),
        isTrue,
        reason: title,
      );
    }
    expect(spec.axlesOptions, [2, 3]);
  });

  test('legal admission permit requires a certificate number', () {
    final service = PaymentService.fromJson({
      'id': 58434,
      'title':
          'Получение разрешения на допуск транспортного средства к участию '
          'в дорожном движении',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    // СТС и госномер остаются в реквизитах.
    expect(spec.legalRequisites, contains(LegalField.cert));
    expect(spec.legalRequisites, contains(LegalField.regNumber));
    expect(spec.steps, contains(FlowStep.personal));
  });

  test('legal repeat diagnostic asks for certain work types', () {
    final service = PaymentService.fromJson({
      'id': 58442,
      'title':
          'Отдельные виды контрольно-диагностических работ при повторном '
          'прохождении (техосмотр)',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    expect(spec.requireCertainTypes, isTrue);
    // Виды работ выбираются на отдельном экране транспортного средства.
    expect(spec.steps, contains(FlowStep.vehicle));
  });

  test('legal road admission permit has no vehicle step', () {
    final service = PaymentService.fromJson({
      'id': 58434,
      'title':
          'Получение разрешения на допуск ТС к участию в дорожном движении',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);

    // Место оказания услуги и данные о ТС не спрашиваются, поэтому шага ТС нет,
    // и стоимость показывается на шаге способа оплаты.
    expect(spec.requiresStation, isFalse);
    expect(spec.hasVehicleFields, isFalse);
    expect(spec.steps, isNot(contains(FlowStep.vehicle)));
    expect(spec.steps.last, FlowStep.order);
    expect(spec.steps[spec.steps.length - 2], FlowStep.personal);
  });

  test('physical repeat diagnostic keeps a work types step', () {
    final service = PaymentService.fromJson({
      'id': 58442,
      'title':
          'Отдельные виды контрольно-диагностических работ при повторном '
          'прохождении (техосмотр)',
    });
    final spec = PaymentFlowResolver.resolve(service, isLegal: false);

    expect(spec.requireCertainTypes, isTrue);
    expect(spec.steps, contains(FlowStep.vehicle));
    // У физлица госномер в личных данных не запрашивается.
    expect(spec.requirePersonalReg, isFalse);
  });

  test('road admission permit is visible by title even with another id', () {
    final service = PaymentService.fromJson({
      'id': 58500,
      'title':
          'Получение разрешения на допуск транспортного средства к участию '
          'в дорожном движении',
    });

    expect(PaymentFlowResolver.isVisibleFor(service, isLegal: false), isTrue);
    final spec = PaymentFlowResolver.resolve(service, isLegal: false);
    expect(spec.requireCert, isTrue);
    // Услуга не привязана к станциям, поэтому первый шаг — личные данные.
    expect(spec.steps.first, FlowStep.personal);
  });

  test('dangerous goods permit is not confused with the road permit', () {
    final service = PaymentService.fromJson({
      'id': 58438,
      'title':
          'Получение (продление срока действия) свидетельства о допуске '
          'транспортного средства к перевозке определенных опасных грузов',
    });

    expect(PaymentFlowResolver.isAdmissionRoadPermit(service), isFalse);
    final spec = PaymentFlowResolver.resolve(service, isLegal: true);
    // Свидетельство о допуске — не то же самое, что разрешение на допуск к
    // дорожному движению: у него свой сценарий без свидетельства о регистрации.
    expect(spec.requiresCertNumber, isFalse);
    expect(spec.requiresStation, isTrue);
  });

  test(
    'technical control certificate is offered to individuals with a station',
    () {
      final service = PaymentService.fromJson({
        'id': 58499,
        'title': 'Получение сертификата технического контроля',
      });

      expect(PaymentFlowResolver.isVisibleFor(service, isLegal: false), isTrue);
      final spec = PaymentFlowResolver.resolve(service, isLegal: false);
      expect(spec.requiresStation, isTrue);
      expect(spec.steps.first, FlowStep.station);
    },
  );

  test('individual admission permit does not require certain work types', () {
    final permit = PaymentService.fromJson({
      'id': 58434,
      'title': 'Получение разрешения на допуск ТС',
    });

    expect(permit.isAdmissionPermit, isTrue);
    expect(permit.requiresStationOverride, isFalse);
    expect(permit.requiresVehicle, isFalse);
  });

  test('the repeat diagnostic is not treated as a road admission permit', () {
    final repeat = PaymentService.fromJson({
      'id': 58442,
      'title':
          'Отдельные виды контрольно-диагностических работ при повторном '
          'прохождении (теосмотр)',
    });

    expect(repeat.isAdmissionPermit, isFalse);
    final spec = PaymentFlowResolver.resolve(repeat, isLegal: false);
    expect(spec.requiresStation, isTrue);
    expect(spec.requireCertainTypes, isTrue);
    expect(spec.steps.first, FlowStep.station);
  });

  test('the price request type comes from the service id, not the title', () {
    // Тип, выведенный из названия, ломал расчёт: у разрешения в названии есть
    // слова «разрешение на допуск», но сервер знает его как `DEF`. С `KDR`
    // сервер требует станцию, которой у разрешения нет, и цена не считается.
    final permit = PaymentService.fromJson({
      'id': 58434,
      'title':
          'Получение разрешения на допуск транспортного средства к участию '
          'в дорожном движении',
    });
    expect(permit.type, 'DEF');

    // Отдельные виды КДР — наоборот, `KDR`, и станция им нужна.
    expect(
      PaymentService.fromJson({
        'id': 58442,
        'title':
            'Отдельные виды контрольно-диагностических работ при повторном '
            'прохождении (теосмотр)',
      }).type,
      'KDR',
    );

    // Техосмотр.
    expect(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }).type,
      'GTO',
    );

    // Тип, пришедший с сервера, важнее любого предположения.
    expect(
      PaymentService.fromJson({
        'id': 58434,
        'type': 'GTO',
        'title': 'Получение разрешения на допуск транспортного средства',
      }).type,
      'GTO',
    );
  });

  test('preserves station region ids for server-side filtering', () {
    final station = DiagnosticStation.fromJson({
      'id': 1,
      'title': 'Станция',
      'regionId': 24,
    });

    expect(station.regionId, '24');
  });

  test('legal and individual flows separate vehicle data and price', () {
    PaymentFlowSpec spec(int id, String title, {required bool isLegal}) =>
        PaymentFlowResolver.resolve(
          PaymentService.fromJson({'id': id, 'title': title}),
          isLegal: isLegal,
        );

    // Юрлица: сведения о ТС и итоговая стоимость — на одном шаге.
    expect(
      spec(
        58439,
        'Проведение государственного технического осмотра',
        isLegal: true,
      ).steps,
      [
        FlowStep.station,
        FlowStep.method,
        FlowStep.personal,
        FlowStep.vehicle,
        FlowStep.order,
      ],
    );
    // Физлица: итоговая сумма показывается вместе со способом оплаты.
    final individual = spec(
      58439,
      'Проведение государственного технического осмотра',
      isLegal: false,
    );
    expect(individual.steps, [
      FlowStep.station,
      FlowStep.personal,
      FlowStep.vehicle,
      FlowStep.method,
      FlowStep.order,
    ]);
  });

  test('vehicle types are requested when a service only counts vehicles', () {
    // Количество ТС приходит полем COL_TS в выдаче типов ТС, поэтому услуги,
    // которые не спрашивают тип, типы ТС всё равно запрашивают.
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58418,
        'title': 'Получение международного сертификата технического осмотра',
      }),
      isLegal: true,
    );

    expect(spec.requiresVehicleType, isFalse);
    expect(spec.requiresVehicleCount, isTrue);
    expect(spec.needsVehicleTypes, isTrue);
  });

  test('parses the server vehicle count from the COL_TS field', () {
    // COL_TS приходит с минимальным значением счётчика и без списка вариантов.
    final field = VehicleTypeField.fromJson({'name': 'COL_TS', 'min': 2});

    expect(field.name, 'COL_TS');
    expect(field.min, 2);
    expect(field.values, isNull);
  });

  test('vehicle type options come from the trans field values', () {
    // Выдача вида «список описаний полей»: варианты типа — это значения поля
    // trans, остальные поля — параметры выбранного типа.
    final trans = VehicleTypeField.fromJson({
      'name': 'trans',
      'values': [
        {'id': 1, 'title': 'Грузовой автомобиль'},
        {'id': 2, 'title': 'Прицеп/полуприцеп'},
      ],
    });
    final massa = VehicleTypeField.fromJson({
      'name': 'TRANS_MASSA',
      'values': ['1500', '3000'],
    });

    expect(trans.values?.length, 2);
    expect(trans.values?.first.title, 'Грузовой автомобиль');
    // Поле массы пригодно для выбора, поэтому подходит для обязательного ввода.
    expect(massa.values?.isNotEmpty, isTrue);
  });

  test('reads the price from the usual and the unusual response shapes', () {
    // Обычный ответ: сумма под ключом itogo.
    expect(
      PriceInfo.fromResponse({
        'data': {'itogo': '13.5'},
      }).price,
      '13.5',
    );
    // Сумма в корне ответа.
    expect(PriceInfo.fromResponse({'total': 78.7}).price, '78.7');
    // Вложенный объект.
    expect(
      PriceInfo.fromResponse({
        'data': {
          'result': {'price': '83.7'},
        },
      }).price,
      '83.7',
    );
    // Сумма без объекта-обёртки: просто число.
    expect(PriceInfo.fromResponse(13.5).price, '13.5');
    expect(PriceInfo.fromResponse('13.50').price, '13.50');
    // Не сумма: показывать нечего, номер заказа вместо цены не годится.
    expect(PriceInfo.fromResponse('order-1647148').price, isNull);
    expect(PriceInfo.fromResponse(null).price, isNull);
  });

  test('hides the truck with trailer combination at the inspection', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58439,
        'title': 'Проведение государственного технического осмотра',
      }),
      isLegal: false,
    );

    // Комбинация «груз + прицеп» на техосмотре не обслуживается.
    expect(
      spec.isVehicleTypeAllowed('Грузовой автомобиль + Прицеп (полуприцеп)'),
      isFalse,
    );
    // Одиночные типы остаются.
    for (final title in const [
      'Грузовой автомобиль',
      'Прицеп/полуприцеп > 0,75 т и < 3,5 т',
      'Легковой автомобиль',
      'Автобус',
      'Мопед',
      'Мотоцикл',
    ]) {
      expect(spec.isVehicleTypeAllowed(title), isTrue, reason: title);
    }
  });

  test('EKMТ keeps only the three goods vehicle types', () {
    final spec = PaymentFlowResolver.resolve(
      PaymentService.fromJson({
        'id': 58433,
        'title':
            'Проверка технического состояния транспортного средства для '
            'подтверждения соответствия техническим нормам ЕКМТ '
            '(подтверждение пригодности к эксплуатации)',
      }),
      isLegal: true,
    );

    for (final title in const [
      'Грузовой автомобиль',
      'Прицеп/полуприцеп',
      'Грузовой автомобиль+Прицеп (полуприцеп)',
    ]) {
      expect(spec.isVehicleTypeAllowed(title), isTrue, reason: title);
    }
    // Лёгкий транспорт по ЕКМТ не проверяется.
    for (final title in const [
      'Автобус',
      'Мопед',
      'Легковой автомобиль',
      'Мотоцикл',
    ]) {
      expect(spec.isVehicleTypeAllowed(title), isFalse, reason: title);
    }
    // Оси и количество ТС спрашиваются у всех трёх типов.
    for (final title in const [
      'Грузовой автомобиль',
      'Прицеп/полуприцеп',
      'Грузовой автомобиль+Прицеп (полуприцеп)',
    ]) {
      final type = VehicleType.fromJson({'id': 1, 'title': title});
      expect(spec.requiresAxlesFor(type), isTrue, reason: title);
    }
    expect(spec.axlesOptions, [2, 3]);
    expect(spec.requiresVehicleCount, isTrue);
  });

  test('keeps every wsb field the server returns, including cancel url', () {
    // Сервер считает подпись и сам отдаёт набор полей: приложение не должно
    // выбрасывать ни одно из них, иначе шлюз отклоняет платёж.
    final form = WebPayForm.fromJson({
      'action': 'https://payment.webpay.by',
      'wsb_storeid': 941711284,
      'wsb_order_num': 1647148,
      'wsb_currency_id': 'BYN',
      'wsb_version': '2',
      'wsb_seed': '17123456781234',
      'wsb_signature': 'abc123',
      'wsb_test': 0,
      'wsb_total': '55.00',
      'wsb_return_url': 'https://gto.by/pay/success.php',
      'wsb_notify_url': 'https://gto.by/pay/result.php',
      'wsb_cancel_return_url': 'https://gto.by/pay/cancel.php',
      'wsb_invoice_item_name[0]': 'Техосмотр',
      'wsb_invoice_item_price[0]': '55.00',
      'wsb_invoice_item_quantity[0]': 1,
    });

    for (final key in const [
      'wsb_storeid',
      'wsb_order_num',
      'wsb_currency_id',
      'wsb_version',
      'wsb_seed',
      'wsb_signature',
      'wsb_test',
      'wsb_total',
      'wsb_return_url',
      'wsb_notify_url',
      'wsb_cancel_return_url',
      'wsb_invoice_item_name[0]',
      'wsb_invoice_item_price[0]',
      'wsb_invoice_item_quantity[0]',
    ]) {
      expect(form.rawFields.containsKey(key), isTrue, reason: key);
    }
    // Подпись считается по точным значениям, поэтому их нельзя терять.
    expect(form.rawFields['wsb_total'], '55.00');
    expect(form.rawFields['wsb_storeid'], 941711284);
  });

  test('preserves WebPay field names and payment status', () {
    final form = WebPayForm.fromJson({
      'action': 'https://payment.webpay.by',
      'wsb_invoice_item_name[0]': 'Техосмотр',
      '*scart': '[{"name":"Техосмотр"}]',
      'wsb_order_num': '42',
    });
    final item = PaymentHistoryItem.fromJson({
      'orderNum': '42',
      'status': 'processing',
    });

    expect(form.rawFields['wsb_invoice_item_name[0]'], 'Техосмотр');
    expect(form.rawFields['*scart'], '[{"name":"Техосмотр"}]');
    expect(item.orderId, '42');
    expect(item.isPaid, isFalse);
    expect(item.isFailed, isFalse);
    expect(PaymentHistoryItem.fromJson({'orderNum': '42'}).isPaid, isFalse);
  });

  test('uses the final payment total instead of a base price', () {
    final price = PriceInfo.fromResponse({
      'data': {'price': '38.00', 'itogo': '38.00', 'total': '38.00'},
    });

    expect(price.price, '38.00');
  });

  test('extracts price from nested payment response', () {
    final price = PriceInfo.fromResponse({
      'data': {
        'data': {'price': '42.50'},
      },
    });

    expect(price.price, '42.50');
  });

  test('normalizes Belarusian phone numbers for registration', () {
    expect(PhoneUtils.normalize('+375 (29) 123-45-67'), '375291234567');
    expect(PhoneUtils.format('80291234567'), '+375 29 123-45-67');
    expect(PhoneUtils.isValid('375291234567'), isTrue);
    expect(PhoneUtils.isValid('+375 20 123-45-67'), isFalse);
  });

  test('normalizes registration history aliases', () {
    final record = RegistrationRecord.fromJson({
      'id': 42,
      'station': 'ДС №255',
      'service': 'Техосмотр',
      'date': '24.09.2026',
      'time': '10:30',
      'vechicleName': 'Audi A6',
      'regNumber': '1234 AB-5',
    });

    expect(record.elementId, 42);
    expect(record.stationName, 'ДС №255');
    expect(record.serviceName, 'Техосмотр');
    expect(record.dateTime, '24.09.2026 10:30');
    expect(record.vehicleName, 'Audi A6');
  });

  test('uses explicit history age for cancellation controls', () {
    final past = RegistrationRecord.fromJson({
      'id': 1,
      'isOld': 1,
      'status': 'completed',
    });
    final upcoming = RegistrationRecord.fromJson({
      'id': 2,
      'isOld': 0,
      'status': 'upcoming',
    });

    expect(past.isPast, isTrue);
    expect(past.canCancel, isFalse);
    expect(upcoming.isPast, isFalse);
    expect(upcoming.canCancel, isTrue);
  });

  test('reads a history file id, to build a link when href is missing', () {
    final item = PaymentHistoryItem.fromJson({
      'id': 1,
      'orderId': '12345',
      'files': [
        {'templateID': 7, 'title': 'Счёт'},
        {
          'href':
              'https://gto.by/api/report/get_report.php?ID=12345&templateID=8',
        },
      ],
    });

    expect(item.files, hasLength(2));
    // Идентификатор шаблона нужен, чтобы собрать ссылку самому: запрос
    // `get_report.php` без сессии отвечает 404, поэтому файл открывается
    // внешним браузером.
    expect(item.files!.first.id, 7);
    expect(item.files!.first.title, 'Счёт');
    expect(item.files!.first.href, isNull);
    expect(item.files!.last.href, contains('templateID=8'));
  });

  test('legal vehicle fields follow the selected type', () {
    // Сервер отдаёт параметры ТС одним плоским списком: масса приходит
    // несколькими записями с одинаковым именем и разным `parentValue`. Без
    // разбора этого признака масса попадала в каждый тип, дублировалась в форме
    // и отправлялась даже легковому автомобилю, у которого её нет.
    final types = PaymentApi.instance.parseVehicleTypes({
      'data': [
        {
          'name': 'TRANS',
          'values': [
            {'id': '28', 'title': 'Автобус'},
            {'id': '29', 'title': 'Грузовой автомобиль'},
            {'id': '31', 'title': 'Легковой автомобиль'},
            {'id': '34', 'title': 'Прицеп/полуприцеп'},
          ],
        },
        {
          'name': 'TRANS_MOTOR',
          'values': [
            {'id': '44', 'title': 'Бензин'},
          ],
        },
        {
          'name': 'TRANS_KOL',
          'values': [
            {'id': '47', 'title': '4x2'},
          ],
        },
        {
          'name': 'TRANS_MASSA',
          'parentField': 'TRANS',
          'parentValue': 28,
          'values': [
            {'id': '40', 'title': '< 5 т'},
          ],
        },
        {
          'name': 'TRANS_MASSA',
          'parentField': 'TRANS',
          'parentValue': 29,
          'values': [
            {'id': '37', 'title': '< 3,5 т'},
          ],
        },
        {
          'name': 'TRANS_MASSA',
          'parentField': 'TRANS',
          'parentValue': 34,
          'values': [
            {'id': '36', 'title': '> 0,75 т и < 3,5 т'},
          ],
        },
        {
          'name': 'TRANS_OS',
          'values': [
            {'id': '49', 'title': '2'},
          ],
        },
      ],
    });

    List<String> namesOf(int id) => types
        .firstWhere((type) => type.id == id)
        .fields!
        .map((field) => field.name)
        .toList();

    // Автобус: своя масса и оси, без двигателя и колёсной формулы.
    expect(namesOf(28), containsAll(['TRANS_MASSA', 'TRANS_OS']));
    expect(namesOf(28), isNot(contains('TRANS_MOTOR')));

    // Грузовой: масса грузового, а не автобуса, и ровно одна.
    final truckFields = types.firstWhere((type) => type.id == 29).fields!;
    expect(
      truckFields.where((field) => field.name == 'TRANS_MASSA'),
      hasLength(1),
    );
    expect(
      truckFields
          .firstWhere((field) => field.name == 'TRANS_MASSA')
          .values!
          .single
          .id,
      37,
    );

    // Легковой: двигатель и колёсная формула, но массы нет.
    expect(namesOf(31), containsAll(['TRANS_MOTOR', 'TRANS_KOL', 'TRANS_OS']));
    expect(namesOf(31), isNot(contains('TRANS_MASSA')));

    // Прицеп: своя масса.
    expect(
      types
          .firstWhere((type) => type.id == 34)
          .fields!
          .firstWhere((field) => field.name == 'TRANS_MASSA')
          .values!
          .single
          .id,
      36,
    );
  });

  test('a payMethod error is shown without the machine code', () {
    final error = ApiError.fromJson({
      'errors': [
        {
          'code': 'payMethod',
          'title': 'Не указан способ оплаты.',
          'details': '',
        },
      ],
    });

    expect(error.errors, ['Не указан способ оплаты.']);
  });

  test('order id is read from a document href', () {
    expect(
      orderIdFromDocumentHref('https://www.gto.by/doc_new/1.1909564.pdf'),
      1909564,
    );
    expect(
      orderIdFromDocumentHref('https://www.gto.by/doc_new/5.1909600.docx'),
      1909600,
    );
    expect(orderIdFromDocumentHref('https://gto.by/report.php?ID=1'), isNull);
    expect(orderIdFromDocumentHref(null), isNull);
  });

  test('document title drops the order suffix', () {
    expect(
      documentTitle('Акт оказанных услуг - 1.1909564.pdf'),
      'Акт оказанных услуг',
    );
    expect(documentTitle('Акт оказанных услуг'), 'Акт оказанных услуг');
  });

  test('a document title is matched to its template', () {
    final templates = [
      DocumentTemplate(id: 173685, title: 'Счет'),
      DocumentTemplate(id: 244313, title: 'Счет и Акт оказанных услуг'),
      DocumentTemplate(id: 420977, title: 'Акт оказанных услуг'),
      DocumentTemplate(id: 640484, title: 'Счет-договор '),
      DocumentTemplate(
        id: 641885,
        title: 'Годовой договор с пролонгацией (собственные средства)',
      ),
    ];

    // Точное совпадение.
    expect(
      matchDocumentTemplate(
        'Акт оказанных услуг - 1.1909564.pdf',
        templates,
      )?.id,
      420977,
    );
    // Шаблон, которым начинается название истории.
    expect(
      matchDocumentTemplate(
        'Счет-договор и АКТ оказанных услуг - 1.1909564.pdf',
        templates,
      )?.id,
      640484,
    );
    // Шаблон из списка выбирается и без хвоста.
    expect(
      matchDocumentTemplate(
        'Годовой договор с пролонгацией (собственные средства)',
        templates,
      )?.id,
      641885,
    );
    expect(matchDocumentTemplate('Нет такого', templates), isNull);
  });

  testWidgets('bottom nav inset accounts for the home indicator', (
    tester,
  ) async {
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
        child: Builder(
          builder: (context) {
            inset = bikeNavBottomInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(inset, kBikeNavHeight + kBikeNavBottomMargin + 34);
  });

  testWidgets(
    'bottom nav panel stays above the system inset instead of merging with it',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 48)),
            child: Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: BikeBottomNav(index: 0, onChanged: (_) {}),
            ),
          ),
        ),
      );

      final scaffoldRect = tester.getRect(find.byType(Scaffold));
      // Панель (фон) не должна заходить под системную навигацию: её нижний
      // край выше системного инсета, а не на уровне системных кнопок.
      final panel = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(BikeBottomNav),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);
      expect(panel, isNotEmpty);
      final panelRect = tester.getRect(
        find
            .descendant(
              of: find.byType(BikeBottomNav),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).boxShadow != null,
              ),
            )
            .first,
      );
      expect(
        scaffoldRect.bottom - panelRect.bottom,
        closeTo(kBikeNavBottomMargin + 48, 0.1),
      );
      expect(panelRect.height, closeTo(kBikeNavHeight, 0.1));
    },
  );

  testWidgets('shell body keeps the real system inset for the nav inset', (
    tester,
  ) async {
    late double inset;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 48)),
          child: Builder(
            builder: (context) => Scaffold(
              extendBody: true,
              bottomNavigationBar: BikeBottomNav(index: 0, onChanged: (_) {}),
              body: appBodyWithNavInset(
                context,
                Builder(
                  builder: (context) {
                    inset = bikeNavBottomInset(context);
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Scaffold с extendBody обнулял viewPadding.bottom внутри body
    // (64 + 12 + 0); восстановление возвращает настоящий системный инсет.
    expect(inset, kBikeNavHeight + kBikeNavBottomMargin + 48);
  });

  testWidgets('sign up screen scrolls on a small viewport without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: SignUpScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('button grows with a large text scale instead of clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: RNButton(
                title: 'Очень длинная надпись на кнопке',
                onPress: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(RNButton)).height,
      greaterThanOrEqualTo(50),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('password field toggles visibility with the eye button', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'secret123');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordInput(controller: controller, hintText: 'Пароль'),
        ),
      ),
    );

    TextField field() => tester.widget<TextField>(find.byType(TextField));

    expect(field().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(field().obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(field().obscureText, isTrue);
  });

  Future<void> pumpMenuHost(
    WidgetTester tester, {
    required GlobalKey anchorKey,
    required List<Vehicle> vehicles,
    required String Function(Vehicle) primaryOf,
    String Function(Vehicle)? secondaryOf,
    required ValueChanged<Vehicle?> onPicked,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                const SizedBox(height: 40),
                SizedBox(key: anchorKey, width: 240, height: 44),
                TextButton(
                  onPressed: () async {
                    onPicked(
                      await showVehicleMenu(
                        context,
                        anchorKey: anchorKey,
                        vehicles: vehicles,
                        primaryOf: primaryOf,
                        secondaryOf: secondaryOf,
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('vehicle menu lists every car and returns the chosen one', (
    tester,
  ) async {
    final anchorKey = GlobalKey();
    final vehicles = [
      Vehicle(id: 1, regNumber: '1234 AB-5', name: 'Audi A6'),
      Vehicle(id: 2, regNumber: '7777 XX-2', name: 'BMW X5'),
    ];
    Vehicle? picked;

    await pumpMenuHost(
      tester,
      anchorKey: anchorKey,
      vehicles: vehicles,
      primaryOf: (vehicle) => vehicle.regNumber ?? '',
      secondaryOf: (vehicle) => vehicle.name ?? '',
      onPicked: (value) => picked = value,
    );

    expect(find.text('1234 AB-5'), findsOneWidget);
    expect(find.text('BMW X5'), findsOneWidget);

    await tester.tap(find.text('7777 XX-2'));
    await tester.pumpAndSettle();

    expect(picked?.id, 2);
  });

  testWidgets('vehicle menu marks a missing value instead of an empty line', (
    tester,
  ) async {
    final anchorKey = GlobalKey();
    final vehicles = [
      Vehicle(id: 1, regNumber: '1234 AB-5', vehiclePassport: 'CB 1234'),
      // У второго автомобиля свидетельства нет: строка не должна быть пустой.
      Vehicle(id: 2, regNumber: '7777 XX-2'),
    ];

    await pumpMenuHost(
      tester,
      anchorKey: anchorKey,
      vehicles: vehicles,
      primaryOf: (vehicle) => vehicle.vehiclePassport ?? '',
      secondaryOf: (vehicle) => vehicle.regNumber ?? '',
      onPicked: (_) {},
    );

    expect(find.text('CB 1234'), findsOneWidget);
    expect(find.text('— нет —'), findsOneWidget);
  });

  testWidgets('vehicle menu offers manual entry as a separate choice', (
    tester,
  ) async {
    final anchorKey = GlobalKey();
    final vehicles = [
      Vehicle(id: 1, regNumber: '1234 AB-5'),
      Vehicle(id: 2, regNumber: '7777 XX-2'),
    ];
    Vehicle? picked;

    await pumpMenuHost(
      tester,
      anchorKey: anchorKey,
      vehicles: vehicles,
      primaryOf: (vehicle) => vehicle.regNumber ?? '',
      onPicked: (value) => picked = value,
    );

    await tester.tap(find.text('Ввести вручную'));
    await tester.pumpAndSettle();

    // Маркер отличается от любого автомобиля: вызывающая сторона по нему
    // понимает, что нужно открыть клавиатуру, а не подставлять данные ТС.
    expect(identical(picked, vehicleManualEntryMarker), isTrue);
    expect(picked?.id, isNot(1));
    expect(picked?.id, isNot(2));
  });
}
