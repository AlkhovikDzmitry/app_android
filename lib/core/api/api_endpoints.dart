class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://www.gto.by/api/v2';
  static const String reportBaseUrl = 'https://gto.by/api/report';

  // Auth
  static const String login = '/users/login.php';
  static const String register = '/users/register.php';
  static const String logout = '/users/logout.php';
  static const String resetPassword = '/users/reset-password.php';
  static const String changePassword = '/users/change-password.php';

  // News
  static const String newsList = '/news/list.php';
  static const String newsItem = '/news/item.php';

  // Diagnostic stations
  static const String stationsList = '/diagnostic-stations/list.php';
  static const String stationsFilters = '/diagnostic-stations/filters.php';
  static const String stationServices = '/diagnostic-stations/services.php';
  static const String stationSlots = '/diagnostic-stations/slots.php';
  static const String stationCalendar = '/diagnostic-stations/calendar.php';
  static const String stationRecord = '/diagnostic-stations/record.php';
  static const String stationHistory = '/diagnostic-stations/history.php';
  static const String stationCancel = '/diagnostic-stations/cancel.php';

  // Payment
  static const String paymentServices = '/payment/services.php';
  static const String paymentHistory = '/payment/history.php';
  static const String paymentStations = '/payment/stations.php';
  static const String paymentMethodsIndividual = '/payment/payment-methods.php';
  static const String paymentMethodsJuristic =
      '/payment/legal-payment-methods.php';
  static const String paymentPrice = '/payment/price.php';
  static const String paymentPriceJuristic = '/payment/legal-price.php';
  static const String paymentVehicleTypes = '/payment/vehicle-types.php';
  static const String paymentVehicleTypesJuristic =
      '/payment/legal-vehicle-types.php';
  static const String paymentCertainTypesWork =
      '/payment/certain-types-work.php';
  static const String paymentOrderIndividual = '/payment/private-person.php';
  static const String paymentOrderJuristic = '/payment/legal-person.php';
  static const String paymentDocsTemplates = '/payment/docs-templates.php';

  // Users
  static const String userProfile = '/users/me.php';
  static const String userEditProfile = '/users/edit-profile.php';
  static const String userChangeNotification = '/users/change-notification.php';
  static const String userDelete = '/users/delete.php';
  static const String vehiclesList = '/users/vehicle/list.php';
  static const String vehicleAdd = '/users/vehicle/add.php';
  static const String vehicleEdit = '/users/vehicle/edit.php';
  static const String vehicleDelete = '/users/vehicle/delete.php';
  static const String vehicleRegNumberValidator =
      '/users/vehicle/reg_number_validator.php';
  static const String vehicleCertNumberValidator =
      '/users/vehicle/cert_number_validator.php';

  // Electronic appeals
  static const String appealsRequirements =
      '/electronic-appeals/application-requirements.php';
  static const String appealsWithdraw = '/electronic-appeals/withdraw.php';

  // Legal info
  static const String rules = '/legal-info/rules.php';

  // Report
  static const String report = '/get_report.php';
}
