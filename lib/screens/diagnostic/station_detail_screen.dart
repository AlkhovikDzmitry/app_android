import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../models/station.dart';
import '../../providers/auth_provider.dart';
import '../../services/station_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({super.key, required this.station});

  final DiagnosticStation station;

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  late Future<List<StationService>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = StationApi.instance.getStationServices(widget.station.id);
  }

  Future<void> _openRoute() async {
    final station = widget.station;
    final address = station.address?.trim() ?? '';
    Uri destination;
    if (station.lat != null && station.lon != null) {
      destination = Uri(
        scheme: 'yandexnavi',
        host: 'build_route_on_map',
        queryParameters: {
          'lat_to': station.lat.toString(),
          'lon_to': station.lon.toString(),
        },
      );
    } else if (address.isNotEmpty) {
      destination = Uri(
        scheme: 'yandexnavi',
        host: 'map_search',
        queryParameters: {'text': address},
      );
    } else {
      return;
    }

    var opened = false;
    try {
      opened = await launchUrl(
        destination,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (opened) return;

    final fallback = station.lat != null && station.lon != null
        ? Uri.https('yandex.ru', '/maps/', {
            'r': '~${station.lat},${station.lon}',
            if (address.isNotEmpty) 'text': address,
          })
        : Uri.https('yandex.ru', '/maps/', {'text': address});
    try {
      opened = await launchUrl(fallback, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть Яндекс Карты')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    final isAuth = context.watch<AuthProvider>().authStatus;
    final isLegal = context.watch<AuthProvider>().isLegal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Станция'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32 + bikeNavBottomInset(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineStrong,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_car_wash_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              // Название с номером. Номер отдельно не выводится:
                              // он уже есть в названии, иначе показывался бы
                              // дважды. Длинное название переносится на вторую
                              // строку, кегль не уменьшается.
                              s.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: s.address ?? '',
                      ),
                      if (s.phone != null && s.phone!.isNotEmpty)
                        _InfoRow(icon: Icons.phone_outlined, text: s.phone!),
                      if (s.workTime != null && s.workTime!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          text: s.workTime!,
                        ),
                    ],
                  ),
                ),
                if (s.categories != null && s.categories!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: s.categories!
                        .map(
                          (c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (s.address?.isNotEmpty == true ||
                    (s.lat != null && s.lon != null)) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openRoute,
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('Маршрут в Яндекс Картах'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Услуги',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<StationService>>(
                  future: _servicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Не удалось загрузить услуги',
                        style: TextStyle(color: AppColors.textSecondary),
                      );
                    }
                    final services = filterStationServices(
                      snapshot.data ?? [],
                      isLegal: isLegal,
                    );
                    if (services.isEmpty) {
                      return Text(
                        'Услуги не найдены',
                        style: TextStyle(color: AppColors.textSecondary),
                      );
                    }
                    return Column(
                      children: services.map((svc) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: s.isOnlineRecord
                                  ? () {
                                      if (!isAuth) {
                                        context.push('/sign-in');
                                        return;
                                      }
                                      context.push(
                                        '/booking-form',
                                        extra: {'station': s, 'service': svc},
                                      );
                                    }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            svc.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (svc.price != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '${svc.price} руб.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: isAuth && s.isOnlineRecord
                                          ? AppColors.textSecondary
                                          : AppColors.divider,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (s.isOnlineRecord)
                  RNButton(
                    title: isAuth ? 'Записаться' : 'Войти и записаться',
                    onPress: () {
                      if (!isAuth) {
                        context.push('/sign-in');
                        return;
                      }
                      context.push('/booking-form', extra: {'station': s});
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Онлайн-запись для этой станции временно недоступна',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
