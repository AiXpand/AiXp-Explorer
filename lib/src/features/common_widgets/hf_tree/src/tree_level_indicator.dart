part of hf_tree;

class _TreeVerticalLinesPainter extends CustomPainter {
  _TreeVerticalLinesPainter({
    required this.node,
    required this.levelSize,
    required this.lineOrigin,
    required this.lineWidth,
  }) : lineOriginOffset = levelSize - (levelSize * lineOrigin);

  final TreeNode<Object> node;
  final double lineOrigin;
  final double lineWidth;
  final double levelSize;
  final double lineOriginOffset;

  double offsetForLevel(int level) => (level * levelSize) - lineOriginOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(123, 158, 158, 158)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
    final Path path = Path();

    for (int level = 1; level <= node.level; level++) {
      final double x = offsetForLevel(level) - 1;
      path
        ..moveTo(x, size.height)
        ..lineTo(x, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TreeVerticalLinesPainter oldDelegate) =>
      oldDelegate.node.level != node.level;
}

class TreeItemPadded extends StatelessWidget {
  const TreeItemPadded({
    super.key,
    required this.node,
    required this.levelSize,
    required this.contentBuilder,
  });
  final TreeNode<Object> node;
  final double levelSize;
  final Widget Function() contentBuilder;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TreeVerticalLinesPainter(
          node: node,
          levelSize: levelSize,
          lineOrigin: 1,
          lineWidth: 1,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: node.level * levelSize),
          child: contentBuilder(),
        ),
      ),
    );
  }
}
