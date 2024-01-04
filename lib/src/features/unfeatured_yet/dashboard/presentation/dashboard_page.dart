import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/manager/presentation/config_startup_page.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/payload_viewer.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/domain/home_navigation_item.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation/left_nav_layout.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation_item.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/side_nav/side_nav.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/network_page.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key, required this.child});

  final Widget child;

  final E2Client client = E2Client();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyles.dark800,
      drawer: SideNav(
        isExpanded: true,
        items: [
          NavigationItem(
            title: 'Network status',
            icon: CarbonIcons.network_1,
            pageWidget: Container(),
          ),
          // NavigationItem(
          //   title: 'Box viewer',
          //   icon: CarbonIcons.iot_connect,
          //   pageWidget: Container(),
          // ),
          NavigationItem(
            title: 'Message viewer',
            icon: CarbonIcons.query_queue,
            pageWidget: Container(),
          ),
        ]
            .map(
              (e) => HomeNavigationItem.simple(
                label: (context) => Text(e.title),
                icon: (context) => Icon(e.icon),
                matchingRoutePrefixes: [],
                onNavigate: () {},
                enableLowerDivider: true,
              ),
            )
            .toList(),
      ),
      body: const LeftNavLayout(
        pages: [
          NavigationItem(
            title: 'Network status',
            icon: CarbonIcons.network_1,
            pageWidget: NetworkPage(),
          ),
          NavigationItem(
              title: 'Manager',
              icon: CarbonIcons.network_1,
              pageWidget: NetworkPage(),
              children: [
                NavigationItem(
                  title: 'Config Startup',
                  icon: CarbonIcons.iot_connect,
                  pageWidget: SizedBox(),
                ),
                NavigationItem(
                  title: 'Command Launcher',
                  icon: CarbonIcons.iot_connect,
                  pageWidget: SizedBox(),
                ),
              ]),
          NavigationItem(
            title: 'Message viewer',
            icon: CarbonIcons.query_queue,
            pageWidget: PayloadViewer(boxName: ''),
          ),
        ],
        child: child,
      ),
    );
  }
}
