import 'package:e2_explorer/src/design/layouts/desktop_app_layout.dart';
import 'package:e2_explorer/src/features/command_launcher/presentation/command_launcher_page.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/window_buttons.dart';
import 'package:e2_explorer/src/features/manager/presentation/config_startup_page.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation/left_nav_layout.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation_item.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/utils/asset_utils.dart';
import 'package:flutter/material.dart';

import '../../../node_dashboard/presentation/pages/node_dashboard.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key, required this.child});

  final Widget child;

  final E2Client client = E2Client();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesktopAppLayout(
        child: LeftNavLayout(
          pages: [
            NavigationItem(
              title: 'Node Dashboard',
              // icon: CarbonIcons.query_queue,
              svgIconPath: AssetUtils.getSidebarIconPath('node_dashboard'),
              pageWidget: const NodeDashBoard(),
              path: RouteNames.nodeDashboard,
              includeBottomDivider: true,
            ),
            NavigationItem(
              title: 'Config Startup',
              // icon: CarbonIcons.query_queue,
              svgIconPath: AssetUtils.getSidebarIconPath('sliders'),
              pageWidget: const ConfigStartupPage(),
              path: RouteNames.configStartUp,
            ),
            NavigationItem(
              title: 'Command Launcher',
              // icon: CarbonIcons.query_queue,
              svgIconPath: AssetUtils.getSidebarIconPath('command_launcher'),
              pageWidget: const CommandLauncherPage(),
              path: RouteNames.commandLauncher,
            ),

            /// old ones
            ///
            ///
            ///

            // const NavigationItem(
            //   title: 'Network status',
            //   icon: CarbonIcons.network_1,
            //   pageWidget: NetworkPage(),
            //   path: RouteNames.network,
            // ),
            // const NavigationItem(
            //   title: 'Manager',
            //   icon: CarbonIcons.network_1,
            //   pageWidget: SizedBox(),
            //   path: RouteNames.manager,
            //   children: [
            //     NavigationItem(
            //       title: 'Config Startup',
            //       icon: CarbonIcons.iot_connect,
            //       pageWidget: ConfigStartupPage(),
            //       path: RouteNames.config,
            //     ),
            //     NavigationItem(
            //       title: 'Command Launcher',
            //       icon: CarbonIcons.iot_connect,
            //       pageWidget: CommandLauncherPage(),
            //       path: RouteNames.commandLauncher,
            //     ),
            //   ],
            // ),
          ],
          child: child,
        ),
      ),
    );
  }
}
