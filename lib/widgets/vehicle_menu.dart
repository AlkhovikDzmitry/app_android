import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/vehicle.dart';

/// Маркер пункта «Ввести вручную»: меню возвращает его вместо автомобиля, когда
/// пользователь не выбирает машину из кабинета, а хочет напечатать значение.
///
/// Нужен потому, что тап по полю открывает меню: без этого пункта добраться до
/// клавиатуры было бы нельзя — каждый тап снова показывал бы список.
final Vehicle vehicleManualEntryMarker = Vehicle(id: -1);

/// Выпадающий список автомобилей из личного кабинета под полем [anchorKey].
///
/// Одно меню используется и для поля регистрационного знака, и для поля
/// свидетельства о регистрации: чем заполнять оба поля решает вызывающая
/// сторона, а здесь только подпись строки — `primaryOf` показывает значение
/// именно этого поля, `secondaryOf` — с чем оно связано.
///
/// Пустое значение показывается серым прочерком: автомобиль без свидетельства
/// остаётся в списке, иначе при одном таком авто меню вообще не появлялось бы.
Future<Vehicle?> showVehicleMenu(
  BuildContext context, {
  required GlobalKey anchorKey,
  required List<Vehicle> vehicles,
  required String Function(Vehicle vehicle) primaryOf,
  String Function(Vehicle vehicle)? secondaryOf,
  String manualEntryLabel = 'Ввести вручную',
}) async {
  final anchorContext = anchorKey.currentContext;
  if (anchorContext == null) return null;
  final box = anchorContext.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  final position = box.localToGlobal(Offset.zero);

  return showMenu<Vehicle>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy + box.size.height + 4,
      position.dx + box.size.width,
      position.dy + box.size.height + 4,
    ),
    color: AppColors.surface,
    elevation: 6,
    items: [
      ...vehicles.map(
        (vehicle) => PopupMenuItem<Vehicle>(
          value: vehicle,
          child: SizedBox(
            width: box.size.width - 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _orDash(primaryOf(vehicle)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryOf(vehicle).trim().isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                if ((secondaryOf?.call(vehicle) ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondaryOf!(vehicle).trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      PopupMenuItem<Vehicle>(
        value: vehicleManualEntryMarker,
        child: SizedBox(
          width: box.size.width - 32,
          child: Text(
            manualEntryLabel,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  );
}

String _orDash(String value) {
  final text = value.trim();
  return text.isEmpty ? '— нет —' : text;
}
