import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/location/location_settings.dart';
import '../core/theme/app_colors.dart';
import '../models/station.dart';
import 'bike_bottom_nav.dart';
import 'google_map_view.dart';

class YandexMapView extends StatefulWidget {
  const YandexMapView({super.key, this.stations = const [], this.onStationTap});

  final List<DiagnosticStation> stations;
  final ValueChanged<DiagnosticStation>? onStationTap;

  @override
  State<YandexMapView> createState() => _YandexMapViewState();
}

class _YandexMapViewState extends State<YandexMapView>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  Position? _userPosition;
  bool _mapReady = false;
  bool _locationLoading = true;
  bool _locationBlocked = false;
  String? _locationMessage;
  String? _lastStationKey;

  static const _belarusCenter = LatLng(53.7098, 27.9534);
  static const _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  bool get _useGoogleMaps {
    if (kIsWeb) return false;
    // Единый источник ключа для Android и iOS: --dart-define=GOOGLE_MAPS_API_KEY.
    // Без него показываем OSM-карту: она не требует ключа и работает всегда.
    return _googleMapsApiKey.trim().isNotEmpty;
  }

  List<DiagnosticStation> get _locatedStations => widget.stations
      .where((station) => _pointFor(station) != null)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastStationKey = _stationKey;
    if (!_useGoogleMaps) _loadLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Пользователь мог вернуться из настроек с включённой геолокацией.
    if (state == AppLifecycleState.resumed && _locationBlocked) {
      _loadLocation();
    }
  }

  @override
  void didUpdateWidget(covariant YandexMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final key = _stationKey;
    if (key != _lastStationKey) {
      _lastStationKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitStations();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  String get _stationKey => widget.stations
      .where((station) => _pointFor(station) != null)
      .map((station) => station.id.toString())
      .join(',');

  LatLng? _pointFor(DiagnosticStation station) {
    final lat = station.lat;
    final lon = station.lon;
    if (lat == null || lon == null) return null;
    if (!lat.isFinite || !lon.isFinite) return null;
    if (lat == 0 && lon == 0) return null;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return LatLng(lat, lon);
  }

  Future<void> _loadLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        setState(() {
          _locationLoading = false;
          _locationBlocked = true;
          _locationMessage = 'Геолокация отключена';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showLocationSettingsDialog(context, serviceDisabled: true);
          }
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationLoading = false;
          _locationBlocked = true;
          _locationMessage = 'Доступ к местоположению не выдан';
        });
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationLoading = false;
          _locationBlocked = true;
          _locationMessage = 'Доступ к местоположению запрещён';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showLocationSettingsDialog(context, serviceDisabled: false);
          }
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _locationLoading = false;
        _locationBlocked = false;
        _locationMessage = null;
      });
      if (_mapReady) _centerOnUser();
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationMessage = 'Не удалось определить местоположение';
        });
      }
    }
  }

  void _retryLocation() {
    setState(() => _locationLoading = true);
    _loadLocation();
  }

  void _centerOnUser() {
    final position = _userPosition;
    if (position == null || !_mapReady) return;
    _mapController.move(LatLng(position.latitude, position.longitude), 15);
  }

  void _fitStations() {
    if (!_mapReady) return;
    final points = _locatedStations
        .map(_pointFor)
        .whereType<LatLng>()
        .toList(growable: false);
    if (points.isEmpty) {
      _mapController.move(_belarusCenter, 5.5);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(34, 80, 34, 206),
        maxZoom: 13,
        minZoom: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_useGoogleMaps) {
      return GoogleMapView(
        stations: widget.stations,
        onStationTap: widget.onStationTap,
      );
    }
    final stationMarkers = _locatedStations
        .map((station) {
          final point = _pointFor(station)!;
          return Marker(
            key: ValueKey('station-${station.id}'),
            point: point,
            width: 42,
            height: 42,
            child: Semantics(
              button: true,
              label: station.title ?? 'Диагностическая станция',
              child: GestureDetector(
                onTap: () => widget.onStationTap?.call(station),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_car_wash_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        })
        .toList(growable: false);

    final userMarker = _userPosition == null
        ? null
        : Marker(
            point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
            width: 28,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _belarusCenter,
            initialZoom: 5.5,
            minZoom: 4,
            maxZoom: 18,
            backgroundColor: const Color(0xFFE8E6DF),
            onMapReady: () {
              _mapReady = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _fitStations();
              });
            },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'by.gto.beltech',
              tileProvider: NetworkTileProvider(
                attemptDecodeOfHttpErrorResponses: false,
                headers: <String, String>{
                  'User-Agent': 'BeltechOSM/1.0 (+https://www.gto.by)',
                  'Accept-Language': 'ru-RU,ru;q=0.9',
                },
              ),
              maxNativeZoom: 19,
              errorTileCallback: (tile, error, stackTrace) {
                debugPrint(
                  'Map tile ${tile.coordinates.z}/'
                  '${tile.coordinates.x}/${tile.coordinates.y}: $error',
                );
              },
            ),
            MarkerLayer(markers: stationMarkers),
            if (userMarker != null) MarkerLayer(markers: [userMarker]),
            // Подписи с карты убраны: SimpleAttributionWidget печатает подряд
            // «flutter_map | © …» прямо в коде библиотеки, и обе надписи
            // закрывали угол карты. Своей подписи нет.
          ],
        ),
        Positioned(
          top: 14,
          right: 14,
          child: SafeArea(
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.fit_screen_rounded,
                  tooltip: 'Показать все станции',
                  onPressed: _fitStations,
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Моё местоположение',
                  onPressed: _userPosition == null
                      ? _loadLocation
                      : _centerOnUser,
                  active: _userPosition != null,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 12 + bikeNavBottomInset(context),
          child: _MapStatusCard(
            stationCount: _locatedStations.length,
            locationLoading: _locationLoading,
            locationMessage: _locationMessage,
            userAvailable: _userPosition != null,
            onTap: (_userPosition != null || _locationLoading)
                ? null
                : _retryLocation,
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      shadowColor: Colors.black26,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: active ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MapStatusCard extends StatelessWidget {
  const _MapStatusCard({
    required this.stationCount,
    required this.locationLoading,
    required this.locationMessage,
    required this.userAvailable,
    this.onTap,
  });

  final int stationCount;
  final bool locationLoading;
  final String? locationMessage;
  final bool userAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.map_rounded,
                size: 19,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$stationCount станций на карте',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationLoading
                        ? 'Определяем ваше местоположение…'
                        : userAvailable
                        ? 'Вы находитесь здесь'
                        : locationMessage ?? 'Местоположение недоступно',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}
