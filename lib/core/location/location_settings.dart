import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Открывает системные настройки геолокации устройства (переключатель
/// «Местоположение»), чтобы пользователь мог включить геолокацию.
Future<void> openDeviceLocationSettings() async {
  try {
    await Geolocator.openLocationSettings();
  } catch (_) {
    // На части устройств страница настроек недоступна — молча игнорируем.
  }
}

/// Открывает настройки приложения, где можно выдать разрешение на
/// местоположение (когда доступ запрещён навсегда).
Future<void> openAppPermissionSettings() async {
  try {
    await Geolocator.openAppSettings();
  } catch (_) {}
}

/// Показывает диалог с объяснением и кнопкой перехода в настройки.
///
/// [serviceDisabled] == true, когда выключена геолокация устройства;
/// иначе считается, что доступ к местоположению запрещён приложению.
Future<void> showLocationSettingsDialog(
  BuildContext context, {
  required bool serviceDisabled,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final title = serviceDisabled
          ? 'Геолокация отключена'
          : 'Нет доступа к геолокации';
      final message = serviceDisabled
          ? 'Чтобы показать ваше местоположение на карте, включите '
                'геолокацию в настройках устройства.'
          : 'Разрешите доступ к местоположению в настройках приложения, '
                'чтобы показать вас на карте.';
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Позже'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (serviceDisabled) {
                openDeviceLocationSettings();
              } else {
                openAppPermissionSettings();
              }
            },
            child: const Text('Открыть настройки'),
          ),
        ],
      );
    },
  );
}
