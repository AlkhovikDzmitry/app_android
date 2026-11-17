import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/location/location_settings.dart';
import '../core/theme/app_colors.dart';
import '../models/station.dart';
import 'bike_bottom_nav.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key, required this.stations, this.onStationTap});

  final List<DiagnosticStation> stations;
  final ValueChanged<DiagnosticStation>? onStationTap;

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView>
    with WidgetsBindingObserver {
  static const _belarusCenter = LatLng(53.7098, 27.9534);

  GoogleMapController? _controller;
  Position? _userPosition;
  bool _mapReady = false;
  bool _locationLoading = true;
  bool _locationBlocked = false;
  String? _locationMessage;

  List<DiagnosticStation> get _locatedStations => widget.stations
      .where((station) => _pointFor(station) != null)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocation();
  }

  @override
  void didUpdateWidget(covariant GoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stations != widget.stations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitStations();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Пользователь мог вернуться из настроек с включённой геолокацией.
    if (state == AppLifecycleState.resumed && _locationBlocked) {
      _loadLocation();
    }
  }

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

  void _fitStations() {
    final controller = _controller;
    if (!_mapReady || controller == null) return;
    final points = _locatedStations
        .map(_pointFor)
        .whereType<LatLng>()
        .toList(growable: false);
    if (points.isEmpty) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: _belarusCenter, zoom: 5.5),
        ),
      );
      return;
    }
    if (points.length == 1) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 13),
        ),
      );
      return;
    }
    final latitudes = points.map((point) => point.latitude);
    final longitudes = points.map((point) => point.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 150));
  }

  void _showUserLocation() {
    final controller = _controller;
    final position = _userPosition;
    if (controller == null || position == null) {
      _loadLocation();
      return;
    }
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _locatedStations
        .map(
          (station) => Marker(
            markerId: MarkerId('station-${station.id}'),
            position: _pointFor(station)!,
            infoWindow: InfoWindow(
              title: station.stationNumber ?? station.title,
              snippet: station.address,
            ),
            onTap: () => widget.onStationTap?.call(station),
          ),
        )
        .toSet();
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _belarusCenter,
            zoom: 5.5,
          ),
          mapType: MapType.normal,
          markers: markers,
          myLocationEnabled: _userPosition != null,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          padding: EdgeInsets.only(bottom: 72 + bikeNavBottomInset(context)),
          onMapCreated: (controller) {
            _controller = controller;
            _mapReady = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fitStations();
            });
          },
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
                  onPressed: _showUserLocation,
                  active: _userPosition != null,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 28 + bikeNavBottomInset(context),
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
