import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/storage/app_storage.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'models/news.dart';
import 'models/payment.dart';
import 'models/station.dart';
import 'models/vehicle.dart';
import 'providers/auth_provider.dart';
import 'widgets/paper_background.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/rules_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_individual_screen.dart';
import 'screens/auth/sign_up_juristic_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/cabinet/appeals_screen.dart';
import 'screens/cabinet/cabinet_screen.dart';
import 'screens/cabinet/change_password_screen.dart';
import 'screens/cabinet/edit_profile_screen.dart';
import 'screens/cabinet/notifications_screen.dart';
import 'screens/cabinet/settings_screen.dart';
import 'screens/cabinet/vehicle_edit_screen.dart';
import 'screens/diagnostic/diagnostic_screen.dart';
import 'screens/diagnostic/filter_screen.dart';
import 'screens/diagnostic/station_detail_screen.dart';
import 'screens/diagnostic/station_record_screen.dart';
import 'screens/news/news_detail_screen.dart';
import 'screens/news/news_screen.dart';
import 'screens/payment/payment_history_screen.dart';
import 'screens/payment/document_view_screen.dart';
import 'screens/payment/payment_flow_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/registration/booking_form_screen.dart';
import 'screens/registration/registration_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/auth_required_view.dart';
import 'widgets/bike_bottom_nav.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  /// Через сколько после сворачивания приложения сбрасываются открытые вкладки.
  static const _backgroundTimeout = Duration(minutes: 5);

  late GoRouter _router = _createRouter();
  DateTime? _backgroundedAt;
  bool _resettingNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_backgroundedAt == null) {
        final now = DateTime.now();
        _backgroundedAt = now;
        unawaited(AppStorage.setBackgroundedAt(now));
      }
      return;
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_handleResumed());
    }
  }

  Future<void> _handleResumed() async {
    final backgroundedAt =
        _backgroundedAt ?? await AppStorage.getBackgroundedAt();
    _backgroundedAt = null;
    await AppStorage.clearBackgroundedAt();
    if (backgroundedAt == null) return;
    if (DateTime.now().difference(backgroundedAt) >= _backgroundTimeout) {
      await _resetTabs();
    }
  }

  /// Закрывает все открытые вкладки и возвращает приложение на главную.
  ///
  /// Пересоздание маршрутизатора сбрасывает не только текущий экран, но и все
  /// вкладки. Пользователь при этом остаётся авторизованным: провайдер сессии
  /// находится выше и не пересоздаётся.
  Future<void> _resetTabs() async {
    if (_resettingNavigation) return;
    _resettingNavigation = true;
    await AppStorage.clearBackgroundedAt();
    if (!mounted) {
      _resettingNavigation = false;
      return;
    }
    final oldRouter = _router;
    setState(() {
      _router = _createRouter();
    });
    _resettingNavigation = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => oldRouter.dispose());
  }

  GoRouter _createRouter() => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/sign-up-individual',
        builder: (context, state) => const SignUpIndividualScreen(),
      ),
      GoRoute(
        path: '/sign-up-juristic',
        builder: (context, state) => const SignUpJuristicScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/rules', builder: (context, state) => const RulesScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _SplashGate(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const NewsScreen(),
              ),
              GoRoute(
                path: '/news-detail',
                builder: (context, state) {
                  final post = state.extra;
                  return post is NewsPost
                      ? NewsDetailScreen(post: post)
                      : const NewsScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diagnostic',
                builder: (context, state) =>
                    DiagnosticScreen(showMap: state.extra != false),
              ),
              GoRoute(
                path: '/station-detail',
                builder: (context, state) {
                  final station = state.extra;
                  return station is DiagnosticStation
                      ? StationDetailScreen(station: station)
                      : const DiagnosticScreen();
                },
              ),
              GoRoute(
                path: '/filter',
                builder: (context, state) {
                  final args = state.extra;
                  if (args is! Map) return const DiagnosticScreen();
                  final rawFilters = args['filters'];
                  final rawSelected = args['selected'];
                  final filters = rawFilters is List
                      ? rawFilters.whereType<StationFilter>().toList()
                      : const <StationFilter>[];
                  final selected = rawSelected is Map
                      ? rawSelected.map(
                          (key, value) => MapEntry(
                            key.toString(),
                            value is Set
                                ? value.map((item) => item.toString()).toSet()
                                : <String>{},
                          ),
                        )
                      : const <String, Set<String>>{};
                  return FilterScreen(filters: filters, selected: selected);
                },
              ),
              GoRoute(
                path: '/station-record',
                builder: (context, state) {
                  final args = state.extra;
                  final station = args is Map ? args['station'] : null;
                  if (station is! DiagnosticStation) {
                    return const DiagnosticScreen();
                  }
                  final service = args is Map ? args['service'] : null;
                  return StationRecordScreen(
                    station: station,
                    service: service is StationService ? service : null,
                  );
                },
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/registration',
                builder: (context, state) {
                  final args = state.extra;
                  final showHistory =
                      args is Map && args['showHistory'] == true;
                  return AuthRequiredView(
                    child: RegistrationScreen(showHistory: showHistory),
                  );
                },
              ),
              GoRoute(
                path: '/booking-form',
                builder: (context, state) {
                  final args = state.extra is Map
                      ? Map<String, dynamic>.from(state.extra as Map)
                      : const <String, dynamic>{};
                  return AuthRequiredView(
                    child: BookingFormScreen(
                      initialStation: args['station'] as DiagnosticStation?,
                      initialService: args['service'] as StationService?,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payment',
                builder: (context, state) =>
                    const AuthRequiredView(child: PaymentScreen()),
              ),
              GoRoute(
                path: '/payment-flow',
                builder: (context, state) {
                  final service = state.extra;
                  return AuthRequiredView(
                    child: service is PaymentService
                        ? PaymentFlowScreen(service: service)
                        : const PaymentScreen(),
                  );
                },
              ),
              GoRoute(
                path: '/document-view',
                builder: (context, state) {
                  final url = state.extra;
                  return AuthRequiredView(
                    child: url is String && url.isNotEmpty
                        ? DocumentViewScreen(url: url)
                        : const PaymentScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cabinet',
                builder: (context, state) =>
                    const AuthRequiredView(child: CabinetScreen()),
              ),
              GoRoute(
                path: '/edit-profile',
                builder: (context, state) =>
                    const AuthRequiredView(child: EditProfileScreen()),
              ),
              GoRoute(
                path: '/payment-history',
                builder: (context, state) =>
                    const AuthRequiredView(child: PaymentHistoryScreen()),
              ),
              GoRoute(
                path: '/notifications',
                builder: (context, state) =>
                    const AuthRequiredView(child: NotificationsScreen()),
              ),
              GoRoute(
                path: '/change-password',
                builder: (context, state) =>
                    const AuthRequiredView(child: ChangePasswordScreen()),
              ),
              GoRoute(
                path: '/appeals',
                builder: (context, state) =>
                    const AuthRequiredView(child: AppealsScreen()),
              ),
              GoRoute(
                path: '/vehicle-edit',
                builder: (context, state) {
                  final vehicle = state.extra;
                  return AuthRequiredView(
                    child: vehicle is Vehicle
                        ? VehicleEditScreen(vehicle: vehicle)
                        : const VehicleEditScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'БЕЛТЕХОСМОТР',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.linear,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Следуем системной теме телефона. Статические геттеры AppColors,
        // которые используются по всему приложению, переключаем вручную —
        // внутри builder Theme.of уже возвращает применённую тему.
        final brightness = Theme.of(context).brightness;
        AppColors.isDark = brightness == Brightness.dark;
        // Ограничиваем системный масштаб шрифта: при 1.5–2.0× фиксированные
        // высоты кнопок и нижней навигации ломают вёрстку на узких экранах.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1,
              maxScaleFactor: 1.3,
            ),
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.systemBarsFor(brightness),
            child: PaperBackground(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _forceShow = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _forceShow = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading && !_forceShow) return const SplashScreen();
    return _MainShell(
      key: ValueKey(auth.sessionVersion),
      navigationShell: widget.navigationShell,
    );
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: appBodyWithNavInset(context, navigationShell),
      bottomNavigationBar: BikeBottomNav(
        index: navigationShell.currentIndex,
        onChanged: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
