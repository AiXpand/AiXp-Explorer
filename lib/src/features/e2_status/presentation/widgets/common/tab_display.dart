import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';

class TabDisplay extends StatefulWidget {
  const TabDisplay({
    super.key,
    required this.children,
    required this.tabNames,
    this.resetIndexOnChange = false,
  });

  final List<Widget> children;
  final List<String> tabNames;
  final bool resetIndexOnChange;

  @override
  State<TabDisplay> createState() => _TabDisplayState();
}

class _TabDisplayState extends State<TabDisplay> with TickerProviderStateMixin {
  late TabController _tabController;
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.children.length, vsync: this);
    _tabIndex = _tabController.index;
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void didUpdateWidget(TabDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print('changed depen  tab disp');
    // if (oldWidget.children != widget.children) {
    //   _tabController.dispose();
    //   _tabController = TabController(length: widget.children.length, vsync: this);
    //   _tabController.addListener(() {
    //     if (_tabIndex != _tabController.index) {
    //       setState(() {
    //         _tabIndex = _tabController.index;
    //       });
    //     }
    //   });
    //   if (widget.resetIndexOnChange) {
    //     _tabIndex = _tabController.index;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 3 / 3,
                child: TabBar(
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryColor,
                  ),
                  indicator: ShapeDecoration(
                    shape: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 4.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                    gradient: AppColors.tabBarIndicatorGradient,
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabAlignment: TabAlignment.start,
                  indicatorPadding: const EdgeInsets.only(top: 35),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.only(right: 24),
                  isScrollable: true,
                  dividerHeight: 0,
                  indicatorWeight: 4,
                  indicatorColor: const Color(0xff0073E6),
                  controller: _tabController,
                  tabs: widget.tabNames
                      .map(
                        (name) => Tab(
                          text: name,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
