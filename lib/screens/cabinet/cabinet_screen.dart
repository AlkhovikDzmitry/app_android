import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/vehicle.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/animated_press.dart';
import '../../widgets/app_card.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/empty_data.dart';

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = UserService.instance.getVehicles();
  }

  void _reload() {
    setState(() => _vehiclesFuture = UserService.instance.getVehicles());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + bikeNavBottomInset(context),
        ),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? 'Пользователь',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (profile?.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile!.email!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.edit_outlined,
                  title: auth.isLegal
                      ? 'Реквизиты организации'
                      : 'Редактировать профиль',
                  onTap: () => context.push('/edit-profile'),
                ),
                const Divider(height: 1, indent: 60),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'История заказов',
                  onTap: () => context.push('/payment-history'),
                ),
                const Divider(height: 1, indent: 60),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Уведомления',
                  onTap: () => context.push('/notifications'),
                ),
                const Divider(height: 1, indent: 60),
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Сменить пароль',
                  onTap: () => context.push('/change-password'),
                ),
                const Divider(height: 1, indent: 60),
                _MenuItem(
                  icon: Icons.markunread_mailbox_outlined,
                  title: 'Электронные обращения',
                  onTap: () => context.push('/appeals'),
                ),
                const Divider(height: 1, indent: 60),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Выйти',
                  color: AppColors.error,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Мои автомобили',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton.filled(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  await context.push('/vehicle-edit');
                  _reload();
                },
                tooltip: 'Добавить автомобиль',
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Vehicle>>(
            future: _vehiclesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'Не удалось загрузить автомобили',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }
              final vehicles = snapshot.data ?? [];
              if (vehicles.isEmpty) {
                return const EmptyData(text: 'Добавьте свой автомобиль');
              }
              return Column(
                children: vehicles.map((v) {
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    onTap: () async {
                      await context.push('/vehicle-edit', extra: v);
                      _reload();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.name ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (v.regNumber != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  v.regNumber!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              if (v.permitExpired != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Срок действия разрешения: '
                                  '${v.permitExpired}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                          onPressed: () => _deleteVehicle(v),
                          tooltip: 'Удалить',
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(Vehicle v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить автомобиль?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UserService.instance.deleteVehicle(v.id);
      _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось удалить автомобиль')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await auth.logout();
      if (context.mounted) {
        context.go('/');
      }
    }
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.primary;
    return AnimatedPress(
      onTap: onTap,
      scale: 0.98,
      child: ListTile(
        leading: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: 1),
          duration: const Duration(milliseconds: 200),
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: itemColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: itemColor, size: 20),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        trailing: AnimatedSlide(
          offset: const Offset(0.06, 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
