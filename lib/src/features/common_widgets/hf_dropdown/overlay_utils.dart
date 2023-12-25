// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';

class OverlayEvent extends ChangeNotifier {
  void notify() {
    super.notifyListeners();
  }
}

class OverlayController {
  OverlayController(this.name);
  Completer<dynamic> resultCompleter = Completer<dynamic>();
  final String name;
  final ValueNotifier<bool> _isVisible = ValueNotifier<bool>(false);
  final GlobalKey targetKey = GlobalKey();
  final LayerLink layerLink = LayerLink();
  late final String tapRegionGroupID = name + UniqueKey().toString();
  OverlayEvent onRebuild = OverlayEvent();
  OverlayEvent onTapOutside = OverlayEvent();

  void addListener(VoidCallback listener) => _isVisible.addListener(listener);
  void removeListener(VoidCallback listener) =>
      _isVisible.removeListener(listener);

  void closeWithResult(dynamic result) {
    _isVisible.value = false;
    if (!resultCompleter.isCompleted) {
      resultCompleter.complete(result);
    }
    resultCompleter = Completer<dynamic>();
  }

  void rebuild() {
    onRebuild.notify();
  }

  void show() {
    _isVisible.value = true;
  }

  bool get isVisible => _isVisible.value;
  bool get canOpen =>
      _isVisible.value == false && resultCompleter.isCompleted == false;
  Future<dynamic> waitForResult() => resultCompleter.future;

  Future<dynamic> showOverlay({
    required BuildContext context,
    required Widget Function(BuildContext context, Widget content) shellBuilder,
    required Widget Function(BuildContext context, OverlayController controller)
        contentBuilder,
    OverlayOnTapOutside? onTapOutside,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    bool isModal = false,
    double? width,
    double? maxHeight = double.infinity,
    double? maxWidth = double.infinity,
    LayerLink? layerLink,
    Object? tapRegionGroupID,
    Offset? contentOffset,
    OnOverlayShow? onShow,
    Color modalBackgroundColor = Colors.transparent,
  }) async {
    final dynamic result = await showLinkedOverlay(
      context: context,
      controller: this,
      layerLink: layerLink ?? this.layerLink,
      tapRegionGroupId: tapRegionGroupID ?? this.tapRegionGroupID,
      isModal: isModal,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      contentOffset: contentOffset,
      width: width,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      shellBuilder: shellBuilder,
      contentBuilder: contentBuilder,
      onTapOutside: onTapOutside,
      targetKey: targetKey,
      onShow: onShow,
      modalBackgroundColor: modalBackgroundColor,
    );
    return result;
  }
}

Future<dynamic> showOverlay({
  required BuildContext context,
  required Widget Function(BuildContext, OverlayController overlay) builder,
  OverlayController? controller,
}) async {
  final OverlayState overlayState = Overlay.of(context);
  final OverlayController overlayController =
      controller ?? OverlayController('Unnamed show overlay controller');

  final OverlayEntry overlayEntry = OverlayEntry(
    builder: (BuildContext context) => builder(context, overlayController),
  );

  void adjustOverlay() {
    if (overlayController.isVisible) {
      overlayState.insert(overlayEntry);
    } else {
      overlayEntry.remove();
    }
  }

  overlayController
    ..addListener(adjustOverlay)
    ..show();
  final dynamic result = await overlayController.waitForResult();
  overlayController.removeListener(adjustOverlay);
  return result;
}

class OverlayOnScreenInfo {
  Alignment targetAnchor;
  Alignment followerAnchor;
  Offset offset;
  double? width;
  final RenderBox targetRenderBox;
  final MediaQueryData mediaQuery;
  final Rect targetScreenRect;
  final Alignment targetScreenRegion;
  OverlayOnScreenInfo({
    required this.targetAnchor,
    required this.followerAnchor,
    required this.targetRenderBox,
    required this.mediaQuery,
    required this.targetScreenRect,
    required this.offset,
    required this.targetScreenRegion,
    required this.width,
  });
}

typedef OnOverlayShow = void Function(OverlayOnScreenInfo info);

OverlayOnScreenInfo getOverlayOnScreenInfo(
  GlobalKey targetKey,
  BuildContext context,
  Alignment? targetAnchor,
  Alignment? followerAnchor,
  Offset? offset,
  double? width,
  LayerLink layerLink,
) {
  final RenderObject? renderObject =
      targetKey.currentContext!.findRenderObject();
  final RenderBox targetRenderBox = renderObject! as RenderBox;
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final Offset globalTargetPosition =
      targetRenderBox.localToGlobal(Offset.zero);
  final Offset globalTargetCenterPosition = targetRenderBox.localToGlobal(
    Offset(
      targetRenderBox.size.width / 2,
      targetRenderBox.size.height / 2,
    ),
  );
  final Alignment targetScreenRegion = Alignment(
    (globalTargetCenterPosition.dx * 2 / mediaQuery.size.width - 1)
        .roundToDouble(),
    (globalTargetCenterPosition.dy * 2 / mediaQuery.size.height - 1)
        .roundToDouble(),
  );
  final Rect targetScreenRect = Rect.fromLTWH(
    globalTargetPosition.dx,
    globalTargetPosition.dy,
    targetRenderBox.size.width,
    targetRenderBox.size.height,
  );

  final Alignment targetAnchorDefault = targetScreenRegion.x <= 0
      ? targetScreenRegion.y <= 0
          ? Alignment.bottomLeft
          : Alignment.topLeft
      : targetScreenRegion.y <= 0
          ? Alignment.bottomRight
          : Alignment.topRight;

  final Alignment followerAnchorDefault = targetScreenRegion.x <= 0
      ? targetScreenRegion.y <= 0
          ? Alignment.topLeft
          : Alignment.bottomLeft
      : targetScreenRegion.y <= 0
          ? Alignment.topRight
          : Alignment.bottomRight;

  final Alignment computedTargetAnchor = targetAnchor ?? targetAnchorDefault;
  final Alignment computedFollowerAnchor =
      followerAnchor ?? followerAnchorDefault;
  final Offset defaultOffset = Offset(
    computedTargetAnchor.x.sign == -computedFollowerAnchor.x.sign
        ? 8 * -computedFollowerAnchor.x.sign
        : 0,
    computedTargetAnchor.y.sign == -computedFollowerAnchor.y.sign
        ? 8 * -computedFollowerAnchor.y.sign
        : 0,
  );

  return OverlayOnScreenInfo(
    targetScreenRect: targetScreenRect,
    targetAnchor: computedTargetAnchor,
    followerAnchor: computedFollowerAnchor,
    targetRenderBox: targetRenderBox,
    mediaQuery: mediaQuery,
    offset: offset ?? defaultOffset,
    targetScreenRegion: targetScreenRegion,
    width: width ?? layerLink.leaderSize?.width,
  );
}

Future<dynamic> showLinkedOverlay({
  required BuildContext context,
  required LayerLink layerLink,
  Alignment? targetAnchor,
  Alignment? followerAnchor,
  OverlayController? controller,
  Object? tapRegionGroupId,
  Offset? contentOffset,
  double? width,
  double? maxHeight = double.infinity,
  double? maxWidth = double.infinity,
  required Widget Function(BuildContext context, Widget content) shellBuilder,
  required Widget Function(BuildContext context, OverlayController controller)
      contentBuilder,
  bool isModal = false,
  OverlayOnTapOutside? onTapOutside,
  required GlobalKey targetKey,
  OnOverlayShow? onShow,
  Color modalBackgroundColor = Colors.transparent,
}) async {
  final OverlayOnScreenInfo onScreenInfo = getOverlayOnScreenInfo(
    targetKey,
    context,
    targetAnchor,
    followerAnchor,
    contentOffset,
    width,
    layerLink,
  );

  if (onShow != null) {
    onShow(onScreenInfo);
  }

  final dynamic result = await showOverlay(
    context: context,
    controller: controller,
    builder: (BuildContext context, OverlayController controller) {
      return Stack(
        children: <Widget>[
          if (isModal)
            Positioned.fill(child: Container(color: modalBackgroundColor)),
          Positioned(
            width: onScreenInfo.width,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              targetAnchor: onScreenInfo.targetAnchor,
              followerAnchor: onScreenInfo.followerAnchor,
              offset: onScreenInfo.offset,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight ?? double.infinity,
                  maxWidth: maxWidth ?? double.infinity,
                ),
                child: AnimatedBuilder(
                  animation: controller.onRebuild,
                  builder: (BuildContext context, Widget? child) =>
                      shellBuilder(
                    context,
                    TapRegion(
                      groupId: tapRegionGroupId,
                      onTapOutside: (PointerDownEvent event) {
                        bool shouldClose = true;
                        controller.onTapOutside.notify();
                        if (onTapOutside != null) {
                          shouldClose = onTapOutside.call(controller);
                        }
                        if (shouldClose) {
                          controller.closeWithResult(null);
                        }
                      },
                      child: contentBuilder(context, controller),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  return result;
}

class OverlayTarget extends StatelessWidget {
  const OverlayTarget({
    super.key,
    required this.child,
    required this.layerLink,
    required this.groupID,
    required this.targetKey,
  });

  final Widget child;
  final GlobalKey targetKey;
  final LayerLink layerLink;
  final Object? groupID;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: targetKey,
      link: layerLink,
      child: TapRegion(
        groupId: groupID,
        child: child,
      ),
    );
  }
}

typedef OverlayOnTapOutside = bool Function(OverlayController overlay);
