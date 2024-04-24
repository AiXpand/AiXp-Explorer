import 'package:e2_explorer/src/features/command_launcher/presentation/command_launcher_page.dart';
import 'package:e2_explorer/src/features/config_startup/presentation/config_startup.dart';
import 'package:e2_explorer/src/features/manager/presentation/config_startup_page.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/payload_viewer.dart';
import 'package:e2_explorer/src/features/profile/presentation/profile.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/dashboard_page.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/network_page.dart';
import 'package:e2_explorer/src/features/wallet/presentation/create_wallet_ready.dart';
import 'package:e2_explorer/src/features/wallet/presentation/splash_screen.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_create.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_import.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_page.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/unfeatured_yet/connection/presentation/connection_page.dart';
import '../features/wallet/presentation/copy_code.dart';

part 'route_names.dart';

final GlobalKey<NavigatorState> homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');

class AppRoutes {
  const AppRoutes._();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteLocations.splashPage,
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(
        path: RouteLocations.splashPage,
        name: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: RouteLocations.walletPage,
        name: RouteNames.walletPage,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletPage();
        },
      ),
      GoRoute(
        path: RouteLocations.walletPassword,
        name: RouteNames.walletPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletPasswordScreen();
        },
      ),
      GoRoute(
        path: RouteLocations.walletImport,
        name: RouteNames.walletImport,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletImport();
        },
      ),
      GoRoute(
        path: RouteLocations.walletCreate,
        name: RouteNames.walletCreate,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletCreate();
        },
      ),
      GoRoute(
        path: RouteLocations.createWalletReady,
        name: RouteNames.createWalletReady,
        builder: (BuildContext context, GoRouterState state) {
          return const CreateWalletReady();
        },
      ),
      GoRoute(
        path: RouteLocations.walletCreateCopyCode,
        name: RouteNames.createCopyCode,
        builder: (context, state) {
          return const CopyCodeScreen();
        },
      ),
      GoRoute(
        /// This route acts as the index
        path: RouteLocations.connection,
        name: RouteNames.connection,
        builder: (BuildContext context, GoRouterState state) {
          return const ConnectionPage();
        },
      ),
      ShellRoute(
        navigatorKey: homeNavigatorKey,
        builder: (context, state, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            path: RouteLocations.network,
            name: RouteNames.network,
            builder: (context, state) => const NetworkPage(),
          ),
          GoRoute(
            path: RouteLocations.configStartUp,
            name: RouteNames.configStartUp,
            builder: (context, state) => const ConfigStartUp(),
          ),
          GoRoute(
            path: RouteLocations.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: RouteLocations.nodeDashboard,
            name: RouteNames.nodeDashboard,
            builder: (BuildContext context, GoRouterState state) {
              return const NetworkPage();
              // return const NodeDashBoard();
            },
          ),
          GoRoute(
            path: RouteLocations.commandLauncher,
            name: RouteNames.commandLauncher,
            builder: (context, state) => const CommandLauncherPage(),
          ),
          GoRoute(
            path: RouteLocations.payloadViewer,
            name: RouteNames.payloadViewer,
            builder: (context, state) {
              return const PayloadViewer(boxName: '');
            },
          ),
        ],
      ),
    ],
  );
}
