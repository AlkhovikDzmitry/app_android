import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/vehicle.dart';
import 'rn_input.dart';
import 'vehicle_menu.dart';

/// Поле регистрационного знака: обычный ввод, а если у пользователя несколько
/// автомобилей — по тапу открывается меню с их списком, выбор подставляет
/// номер и марку/модель.
class VehicleRegField extends StatefulWidget {
  const VehicleRegField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.vehicles,
    required this.showError,
    required this.onChanged,
    required this.onVehicleSelected,
    required this.onNextField,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Vehicle> vehicles;
  final bool showError;
  final ValueChanged<String> onChanged;
  final ValueChanged<Vehicle> onVehicleSelected;
  final VoidCallback onNextField;

  @override
  State<VehicleRegField> createState() => _VehicleRegFieldState();
}

class _VehicleRegFieldState extends State<VehicleRegField> {
  final GlobalKey _anchorKey = GlobalKey();

  bool get _hasMenu => widget.vehicles.length > 1;

  Future<void> _openMenu() async {
    widget.focusNode.unfocus();
    final selected = await showVehicleMenu(
      context,
      anchorKey: _anchorKey,
      vehicles: widget.vehicles,
      primaryOf: (vehicle) => vehicle.regNumber ?? '',
      secondaryOf: (vehicle) => vehicle.name ?? '',
    );
    if (!mounted || selected == null) return;
    // «Ввести вручную»: возвращаем фокус в поле, чтобы открыть клавиатуру.
    if (identical(selected, vehicleManualEntryMarker)) {
      widget.focusNode.requestFocus();
      return;
    }
    widget.onVehicleSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _anchorKey,
      child: RNInput(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: 'Например, 1234 AB-5',
        showError: widget.showError,
        onChanged: widget.onChanged,
        prefixIcon: Icons.directions_car_filled_rounded,
        suffixIcon: _hasMenu
            ? IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                color: AppColors.primary,
                onPressed: _openMenu,
              )
            : null,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => widget.onNextField(),
        onTap: _hasMenu ? _openMenu : null,
      ),
    );
  }
}
