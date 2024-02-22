import 'package:e2_explorer/src/features/command_launcher/presentation/command_launcher_page.dart';
import 'package:e2_explorer/src/features/coms/coms.dart';
import 'package:e2_explorer/src/features/manager/presentation/config_startup_page.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/payload_viewer.dart';
import 'package:e2_explorer/src/features/profile/presentation/profile.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/dashboard_page.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/network_page.dart';
import 'package:e2_explorer/src/features/wallet/presentation/copy_code.dart';
import 'package:e2_explorer/src/features/wallet/presentation/create_wallet_ready.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_create.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_import.dart';
import 'package:e2_explorer/src/features/wallet/presentation/wallet_page.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/unfeatured_yet/connection/presentation/connection_page.dart';

part 'route_names.dart';

final GlobalKey<NavigatorState> homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');

class AppRoutes {
  const AppRoutes._();

  static final GoRouter routes = GoRouter(
    initialLocation: RouteLocations.connection,
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(
        path: RouteLocations.walletImport,
        name: RouteNames.walletImport,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletImport();
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
            path: RouteLocations.config,
            name: RouteNames.config,
            builder: (context, state) => const ConfigStartupPage(),
          ),
           GoRoute(
            path: RouteLocations.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),

          GoRoute(
            path: RouteLocations.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: RouteLocations.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: RouteLocations.comms,
            name: RouteNames.comms,
            builder: (BuildContext context, GoRouterState state) {
              return const Comms();
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
