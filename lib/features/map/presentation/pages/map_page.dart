import 'dart:math';
import 'package:education/features/game/presentation/pages/video_player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/pages/welcome_page.dart';
import '../../domain/entities/level_entity.dart';
import '../cubit/map_cubit.dart';
import '../../../../core/widgets/btn_3d.dart';
import '../../../profile/domain/entities/user_entity.dart';

// Custom Painter to draw river, road, bridge, log tunnel, signpost, and details
class MapPathPainter extends CustomPainter {
  final List<Offset> points;
  final double boundedWidth;
  final double centerX;
  MapPathPainter(this.points, this.boundedWidth, this.centerX);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // 1. Draw Winding River
    final pRiverBridge = points.length > 12
        ? points[12]
        : Offset(centerX, 500); // Level 13

    final riverPath = Path();
    final pRiverStart = Offset(-100, pRiverBridge.dy - 800);
    final pRiverMid1 = Offset(centerX - 120, pRiverBridge.dy - 400);
    final pRiverMid2 = Offset(centerX + 120, pRiverBridge.dy + 400);
    final pRiverEnd = Offset(boundedWidth + 100, pRiverBridge.dy + 800);

    riverPath.moveTo(pRiverStart.dx, pRiverStart.dy);
    riverPath.cubicTo(
      pRiverStart.dx,
      pRiverStart.dy + 200,
      pRiverMid1.dx,
      pRiverMid1.dy - 200,
      pRiverMid1.dx,
      pRiverMid1.dy,
    );
    riverPath.cubicTo(
      pRiverMid1.dx,
      pRiverMid1.dy + 200,
      pRiverBridge.dx - 60,
      pRiverBridge.dy - 150,
      pRiverBridge.dx,
      pRiverBridge.dy,
    );
    riverPath.cubicTo(
      pRiverBridge.dx + 60,
      pRiverBridge.dy + 150,
      pRiverMid2.dx,
      pRiverMid2.dy - 200,
      pRiverMid2.dx,
      pRiverMid2.dy,
    );
    riverPath.cubicTo(
      pRiverMid2.dx,
      pRiverMid2.dy + 200,
      pRiverEnd.dx,
      pRiverEnd.dy - 200,
      pRiverEnd.dx,
      pRiverEnd.dy,
    );

    final riverBorderPaint = Paint()
      ..color = const Color(0xff29B6F6).withOpacity(0.5)
      ..strokeWidth = 75
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final riverInnerPaint = Paint()
      ..color = const Color(0xff4FC3F7)
      ..strokeWidth = 60
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(riverPath, riverBorderPaint);
    canvas.drawPath(riverPath, riverInnerPaint);

    // Draw river water ripples
    final ripplePaint = Paint()
      ..color = const Color(0xff81D4FA)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawRipple(Offset center, double width) {
      final path = Path();
      path.moveTo(center.dx - width / 2, center.dy);
      path.quadraticBezierTo(
        center.dx,
        center.dy + 6,
        center.dx + width / 2,
        center.dy,
      );
      canvas.drawPath(path, ripplePaint);
    }

    drawRipple(Offset(pRiverMid1.dx, pRiverMid1.dy - 80), 30);
    drawRipple(Offset(pRiverMid1.dx + 15, pRiverMid1.dy + 60), 40);
    drawRipple(Offset(pRiverBridge.dx - 40, pRiverBridge.dy - 160), 35);
    drawRipple(Offset(pRiverBridge.dx + 35, pRiverBridge.dy + 140), 45);
    drawRipple(Offset(pRiverMid2.dx - 20, pRiverMid2.dy - 70), 30);
    drawRipple(Offset(pRiverMid2.dx + 15, pRiverMid2.dy + 90), 35);

    // 2. Draw Scenic Ground Details (Bushes, Rocks, Trees, Flowers) BEFORE the road
    void safeDraw(
      void Function(Canvas, Offset) drawFn,
      int index,
      double dxOffset,
      double dyOffset,
    ) {
      if (index < points.length) {
        drawFn(canvas, Offset(centerX + dxOffset, points[index].dy + dyOffset));
      }
    }

    void safeDrawTree(
      void Function(Canvas, Offset, {double scale}) drawFn,
      int index,
      double dxOffset,
      double dyOffset, {
      double scale = 1.0,
    }) {
      if (index < points.length) {
        drawFn(
          canvas,
          Offset(centerX + dxOffset, points[index].dy + dyOffset),
          scale: scale,
        );
      }
    }

    // Level 0 region
    safeDraw(_drawBush, 0, -90, -40);
    safeDrawTree(_drawTree, 0, 110, -10, scale: 1.2);
    safeDraw(_drawFlower, 0, -60, -20);
    safeDraw(_drawFlower, 0, -50, -10);

    // Level 1 region
    safeDrawTree(_drawPineTree, 1, -120, 20, scale: 0.9);
    safeDraw(_drawBush, 1, 90, 20);
    safeDraw(_drawRock, 1, -100, 40);
    safeDraw(_drawFlower, 1, 110, 40);

    // Level 2 region
    safeDrawTree(_drawTree, 2, -130, -10, scale: 1.1);
    safeDrawTree(_drawPineTree, 2, 120, 0, scale: 1.2);
    safeDraw(_drawFlower, 2, 80, 20);

    // Level 3 region
    safeDraw(_drawBush, 3, 110, -30);
    safeDraw(_drawRock, 3, 130, -10);
    safeDrawTree(_drawTree, 3, -110, 10, scale: 0.8);

    // Level 4 region
    safeDrawTree(_drawPineTree, 4, 130, 10, scale: 1.0);
    safeDraw(_drawRock, 4, -100, 10);
    safeDraw(_drawBush, 4, -130, 20);

    // Level 5 region
    safeDrawTree(_drawTree, 5, -120, -20, scale: 1.3);
    safeDraw(_drawFlower, 5, -90, 10);
    safeDrawTree(_drawPineTree, 5, 110, 30, scale: 1.1);

    // Level 6 region
    safeDraw(_drawRock, 6, 90, 0);
    safeDraw(_drawBush, 6, 120, 10);
    safeDrawTree(_drawTree, 6, 140, -20, scale: 0.9);

    // Level 7 region
    safeDraw(_drawBush, 7, -110, -20);
    safeDrawTree(_drawPineTree, 7, -140, -10, scale: 1.2);
    safeDraw(_drawFlower, 7, -80, -5);

    // Level 8 region
    safeDraw(_drawRock, 8, -80, 35);
    safeDrawTree(_drawTree, 8, 110, 0, scale: 1.1);
    safeDraw(_drawBush, 8, 130, 20);

    // Level 9 region
    safeDraw(_drawBush, 9, 60, -30);
    safeDrawTree(_drawPineTree, 9, -120, -20, scale: 1.3);
    safeDrawTree(_drawTree, 9, -150, 10, scale: 0.8);

    // Level 10 region
    safeDraw(_drawRock, 10, 60, -20);
    safeDraw(_drawFlower, 10, 75, 0);
    safeDrawTree(_drawTree, 10, -140, 20, scale: 1.2);

    // Level 11 region
    safeDraw(_drawBush, 11, -90, 20);
    safeDrawTree(_drawPineTree, 11, 200, -10, scale: 0.9);
    safeDraw(_drawFlower, 11, -60, 40);

    // Level 12 region
    safeDrawTree(_drawTree, 12, -130, -20, scale: 1.1);
    safeDraw(_drawRock, 12, -100, 0);
    safeDrawTree(_drawPineTree, 12, 210, 10, scale: 1.2);

    // Level 13 region
    safeDraw(_drawBush, 13, 110, 0);
    safeDrawTree(_drawTree, 13, 140, -20, scale: 0.9);
    safeDraw(_drawFlower, 13, 80, 10);

    // Level 14 region
    safeDraw(_drawBush, 14, -180, -40);
    safeDrawTree(_drawPineTree, 14, -210, -10, scale: 1.1);
    safeDraw(_drawRock, 14, 120, 20);

    // Level 15 region
    safeDrawTree(_drawTree, 15, 110, -20, scale: 1.3);
    safeDrawTree(_drawPineTree, 15, -190, 10, scale: 1.0);
    safeDraw(_drawFlower, 15, 80, 0);

    // 3. Draw Winding Road (Border + Inner Road)
    final roadBorderPaint = Paint()
      ..color = const Color(0xffD7C49E)
      ..strokeWidth = 72
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadInnerPaint = Paint()
      ..color = const Color(0xffF6EAD2)
      ..strokeWidth = 62
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadPath = Path();
    roadPath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cpY = p0.dy - (p0.dy - p1.dy) * 0.5;
      roadPath.cubicTo(p0.dx, cpY, p1.dx, cpY, p1.dx, p1.dy);
    }

    canvas.drawPath(roadPath, roadBorderPaint);
    canvas.drawPath(roadPath, roadInnerPaint);

    // 4. Draw Wooden Bridge at Level 13 (index 12)
    if (points.length > 12) {
      _drawBridge(canvas, points[12]);
    }

    // 5. Draw Wooden Log Tunnel between Level 5 and Level 6 (indices 4 and 5)
    if (points.length > 5) {
      final tunnelCenter = Offset(
        (points[4].dx + points[5].dx) / 2,
        (points[4].dy + points[5].dy) / 2,
      );
      _drawTunnel(canvas, tunnelCenter);
    }

    // 6. Draw Wooden Signpost next to levels 2 and 3
    if (points.length > 2) {
      final signPostCenter = Offset(points[2].dx - 55, points[2].dy + 40);
      _drawSignPost(canvas, signPostCenter);
    }
  }

  void _drawBridge(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.25); // align with road segment curve

    // Bridge shadow over the river
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(6, 12), width: 95, height: 75),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.black.withOpacity(0.35),
    );

    final woodPaint = Paint()..color = const Color(0xffA0522D);
    final woodLightPaint = Paint()..color = const Color(0xffCD853F);
    final linesPaint = Paint()
      ..color = const Color(0xff5C2E16)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final railPaint = Paint()
      ..color = const Color(0xff5C2E16)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final postPaint = Paint()
      ..color = const Color(0xff8B4513)
      ..style = PaintingStyle.fill;
    final postHighlightPaint = Paint()
      ..color = const Color(0xffCD853F)
      ..style = PaintingStyle.fill;

    // Deck base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 88, height: 68),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xff5C2E16), // Dark edge
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 84, height: 64),
        const Radius.circular(4),
      ),
      woodPaint,
    );

    // Plank divisions (horizontal lines)
    for (double dy = -26; dy <= 26; dy += 13) {
      canvas.drawLine(Offset(-40, dy), Offset(40, dy), linesPaint);
      canvas.drawLine(
        Offset(-40, dy + 2),
        Offset(40, dy + 2),
        Paint()
          ..color = woodLightPaint.color.withOpacity(0.5)
          ..strokeWidth = 1.5,
      );
    }

    // Rails (Vertical on left and right)
    canvas.drawLine(const Offset(-42, -36), const Offset(-42, 36), railPaint);
    canvas.drawLine(const Offset(42, -36), const Offset(42, 36), railPaint);

    // Rail highlights
    canvas.drawLine(
      const Offset(-43, -36),
      const Offset(-43, 36),
      Paint()
        ..color = woodLightPaint.color.withOpacity(0.5)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(41, -36),
      const Offset(41, 36),
      Paint()
        ..color = woodLightPaint.color.withOpacity(0.5)
        ..strokeWidth = 2,
    );

    // Posts
    void drawPost(Offset pos) {
      canvas.drawCircle(pos, 5.5, postPaint);
      canvas.drawCircle(
        Offset(pos.dx - 1.5, pos.dy - 1.5),
        2.5,
        postHighlightPaint,
      );
    }

    drawPost(const Offset(-42, -34));
    drawPost(const Offset(-42, 0));
    drawPost(const Offset(-42, 34));
    drawPost(const Offset(42, -34));
    drawPost(const Offset(42, 0));
    drawPost(const Offset(42, 34));

    canvas.restore();
  }

  void _drawTunnel(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.3); // align with road segment curve

    final logPaint = Paint()..color = const Color(0xff8B5A2B);
    final logDetailPaint = Paint()
      ..color = const Color(0xff5C3A21)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final innerLogPaint = Paint()..color = const Color(0xff3D2512);

    // Outer log shape
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 75, height: 95),
        const Radius.circular(8),
      ),
      logPaint,
    );

    // Inner arch
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 55, height: 75),
      innerLogPaint,
    );

    // Ridges
    canvas.drawLine(
      const Offset(-30, -40),
      const Offset(-30, 40),
      logDetailPaint,
    );
    canvas.drawLine(
      const Offset(30, -40),
      const Offset(30, 40),
      logDetailPaint,
    );
    canvas.drawLine(
      const Offset(-10, -45),
      const Offset(-10, 45),
      logDetailPaint,
    );
    canvas.drawLine(
      const Offset(10, -45),
      const Offset(10, 45),
      logDetailPaint,
    );

    // Ends
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -47.5), width: 75, height: 15),
      Paint()..color = const Color(0xffD2B48C),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -47.5), width: 55, height: 8),
      innerLogPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 47.5), width: 75, height: 15),
      Paint()..color = const Color(0xffD2B48C),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 47.5), width: 55, height: 8),
      innerLogPaint,
    );

    canvas.restore();
  }

  void _drawSignPost(Canvas canvas, Offset center) {
    final postWoodPaint = Paint()..color = const Color(0xffCD853F);
    final postBorderPaint = Paint()
      ..color = const Color(0xff8B4513)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Vertical post
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 4, center.dy, 8, 45),
      postWoodPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 4, center.dy, 8, 45),
      postBorderPaint,
    );

    // Signboard
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 45, height: 22),
        const Radius.circular(3),
      ),
      postWoodPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 45, height: 22),
        const Radius.circular(3),
      ),
      postBorderPaint,
    );

    // Directional arrow
    final arrowPaint = Paint()
      ..color = const Color(0xff8B4513)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), arrowPaint);
    canvas.drawLine(const Offset(12, 0), const Offset(6, -5), arrowPaint);
    canvas.drawLine(const Offset(12, 0), const Offset(6, 5), arrowPaint);
    canvas.restore();
  }

  void _drawBush(Canvas canvas, Offset position) {
    final bushPaint = Paint()..color = const Color(0xff4ECE6C);
    final bushDarkPaint = Paint()..color = const Color(0xff2EAD4F);
    final borderPaint = Paint()
      ..color = const Color(0xff1E7D3F)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    canvas.drawCircle(const Offset(-8, 4), 14, bushDarkPaint);
    canvas.drawCircle(const Offset(8, 4), 14, bushDarkPaint);
    canvas.drawCircle(const Offset(0, -6), 16, bushPaint);

    canvas.drawCircle(const Offset(-8, 4), 14, borderPaint);
    canvas.drawCircle(const Offset(8, 4), 14, borderPaint);
    canvas.drawCircle(const Offset(0, -6), 16, borderPaint);

    canvas.restore();
  }

  void _drawRock(Canvas canvas, Offset position) {
    final rockPaint = Paint()..color = const Color(0xffB0B0B0);
    final rockDarkPaint = Paint()..color = const Color(0xff808080);
    final rockLinePaint = Paint()
      ..color = const Color(0xff606060)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final path = Path()
      ..moveTo(-12, 5)
      ..lineTo(-8, -10)
      ..lineTo(8, -12)
      ..lineTo(14, -2)
      ..lineTo(10, 8)
      ..lineTo(-6, 9)
      ..close();

    canvas.drawPath(path, rockPaint);

    final shadowPath = Path()
      ..moveTo(8, -12)
      ..lineTo(14, -2)
      ..lineTo(10, 8)
      ..lineTo(2, 2)
      ..close();
    canvas.drawPath(shadowPath, rockDarkPaint);

    canvas.drawPath(path, rockLinePaint);
    canvas.restore();
  }

  void _drawTree(Canvas canvas, Offset position, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);

    // Trunk
    final trunkPaint = Paint()..color = const Color(0xff8B5A2B);
    final trunkBorderPaint = Paint()
      ..color = const Color(0xff5C3A21)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final trunkRect = Rect.fromCenter(
      center: const Offset(0, 15),
      width: 12,
      height: 30,
    );
    canvas.drawRect(trunkRect, trunkPaint);
    canvas.drawRect(trunkRect, trunkBorderPaint);

    // Leaves (Fluffy)
    final leafPaint = Paint()..color = const Color(0xff2E8B57);
    final leafLightPaint = Paint()..color = const Color(0xff3CB371);
    final leafBorderPaint = Paint()
      ..color = const Color(0xff006400)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    void drawLeafCircle(Offset offset, double radius) {
      canvas.drawCircle(offset, radius, leafPaint);
      canvas.drawCircle(
        Offset(offset.dx - 2, offset.dy - 2),
        radius * 0.8,
        leafLightPaint,
      );
      canvas.drawCircle(offset, radius, leafBorderPaint);
    }

    drawLeafCircle(const Offset(-15, -5), 20);
    drawLeafCircle(const Offset(15, -5), 20);
    drawLeafCircle(const Offset(0, -20), 25);
    drawLeafCircle(const Offset(0, 5), 18);

    canvas.restore();
  }

  void _drawPineTree(Canvas canvas, Offset position, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);

    // Trunk
    final trunkPaint = Paint()..color = const Color(0xff6B4226);
    final trunkRect = Rect.fromCenter(
      center: const Offset(0, 20),
      width: 10,
      height: 20,
    );
    canvas.drawRect(trunkRect, trunkPaint);

    // Leaves (Triangles)
    final pinePaint = Paint()..color = const Color(0xff0B6623);
    final pineLightPaint = Paint()..color = const Color(0xff228B22);

    void drawPineTriangle(double yOffset, double width) {
      final path = Path()
        ..moveTo(0, yOffset - 25)
        ..lineTo(-width / 2, yOffset + 10)
        ..lineTo(width / 2, yOffset + 10)
        ..close();
      canvas.drawPath(path, pinePaint);

      final lightPath = Path()
        ..moveTo(0, yOffset - 25)
        ..lineTo(-width / 2 + 5, yOffset + 10)
        ..lineTo(0, yOffset + 10)
        ..close();
      canvas.drawPath(lightPath, pineLightPaint);
    }

    drawPineTriangle(5, 50);
    drawPineTriangle(-10, 40);
    drawPineTriangle(-25, 30);

    canvas.restore();
  }

  void _drawFlower(Canvas canvas, Offset position) {
    canvas.save();
    canvas.translate(position.dx, position.dy);

    final stemPaint = Paint()
      ..color = const Color(0xff2EAD4F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), const Offset(0, 10), stemPaint);

    final petalPaint = Paint()..color = const Color(0xffFF69B4);
    final centerPaint = Paint()..color = const Color(0xffFFD700);

    for (int i = 0; i < 5; i++) {
      final double angle = i * (2 * pi / 5);
      canvas.drawCircle(Offset(cos(angle) * 4, sin(angle) * 4), 3, petalPaint);
    }
    canvas.drawCircle(const Offset(0, 0), 2.5, centerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for Map Pin Marker
class PinPainter extends CustomPainter {
  final Color color;
  PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;

    // Shadow
    final shadowPath = Path();
    shadowPath.moveTo(size.width * 0.5, size.height);
    shadowPath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width * 0.8,
      size.height * 0.3,
    );
    shadowPath.arcToPoint(
      Offset(size.width * 0.2, size.height * 0.3),
      radius: Radius.circular(size.width * 0.5),
    );
    shadowPath.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.5,
      size.width * 0.5,
      size.height,
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Main teardrop pin
    final path = Path();
    path.moveTo(size.width * 0.5, size.height - 4);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.45,
      size.width * 0.8,
      size.height * 0.25,
    );
    path.arcToPoint(
      Offset(size.width * 0.2, size.height * 0.25),
      radius: Radius.circular(size.width * 0.45),
    );
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.45,
      size.width * 0.5,
      size.height - 4,
    );

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().loadLevels();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Scroll to the bottom of the map (Level 1) upon loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // High-fidelity 3D Wooden Pedestal Level Node
  Widget _buildLevelNode({
    required LevelEntity level,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required int stars,
    required VoidCallback onTap,
    required Animation<double> pulseAnimation,
  }) {
    Gradient capGradient;
    Color shadowColor;
    Color ringBorderColor;

    if (isLocked) {
      capGradient = const LinearGradient(
        colors: [Color(0xffD6DBDF), Color(0xffAEB6BF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      shadowColor = const Color(0xff85929E);
      ringBorderColor = Colors.white;
    } else if (isCurrent) {
      capGradient = const LinearGradient(
        colors: [Color(0xff2ECC71), Color(0xff27AE60)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      shadowColor = const Color(0xff1E8449);
      ringBorderColor = const Color(0xffA3E4D7);
    } else {
      capGradient = const LinearGradient(
        colors: [Color(0xff5DADE2), Color(0xff2980B9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      shadowColor = const Color(0xff1B4F72);
      ringBorderColor = const Color(0xffAED6F1);
    }

    final Animation<double> scaleAnim = isCurrent
        ? Tween<double>(begin: 0.95, end: 1.08).animate(
            CurvedAnimation(parent: pulseAnimation, curve: Curves.easeInOut),
          )
        : const AlwaysStoppedAnimation(1.0);

    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: scaleAnim,
        child: SizedBox(
          width: 80,
          height: 90,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. Wooden pedestal shadow and base (circular)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff5C3A21),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffCD853F),
                    border: Border.all(
                      color: const Color(0xff8B4513),
                      width: 3,
                    ),
                  ),
                ),
              ),

              // 2. Colored button cap (circular)
              Positioned(
                bottom: 12,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: shadowColor,
                  ),
                ),
              ),
              Positioned(
                bottom: 17,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: capGradient,
                    border: Border.all(color: ringBorderColor, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: isLocked
                      ? const Text('🔒', style: TextStyle(fontSize: 18))
                      : Text(
                          '${level.id}',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3-Star Arc Above Level Nodes
  Widget _buildArcStars(int stars, bool isLocked) {
    if (isLocked) return const SizedBox(height: 32);

    Widget buildStar(int index, {required bool isLarge}) {
      final bool isEarned = index <= stars;
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, val, child) {
          return Transform.scale(
            scale: val * (isLarge ? 1.35 : 1.0),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.star,
              color: isEarned
                  ? const Color(0xffE65100)
                  : const Color(0xff78909C),
              size: isLarge ? 26 : 20,
            ),
            Icon(
              Icons.star,
              color: isEarned
                  ? const Color(0xffFFCA28)
                  : const Color(0xffB0BEC5),
              size: isLarge ? 20 : 15,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 32,
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 6, bottom: 2, child: buildStar(1, isLarge: false)),
          Positioned(top: 0, child: buildStar(2, isLarge: true)),
          Positioned(right: 6, bottom: 2, child: buildStar(3, isLarge: false)),
        ],
      ),
    );
  }

  // Tiny Wooden Signboard for Level Title
  Widget _buildLevelTitle(String title, bool isLocked) {
    if (isLocked) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xff8D5524),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xff5C3A21), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Fredoka',
        ),
      ),
    );
  }

  void _showLevelOptions(BuildContext context, LevelEntity level) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${level.emoji} ${level.title}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Btn3D(
                      color: AppColors.primary,
                      shadowColor: AppColors.primaryShadow,
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(level: level),
                          ),
                        );
                      },
                      child: const Text(
                        'شاهد الفيديو',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Btn3D(
                      color: const Color(0xffFF9800),
                      shadowColor: const Color(0xffE65100),
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              level: level,
                              startAssessmentImmediately: true,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'التقويم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Helper to build list of level node widgets directly for the parent Stack
  List<Widget> _buildLevelElements(
    List<LevelEntity> levels,
    List<Offset> points,
    dynamic user,
    BuildContext context,
  ) {
    final List<Widget> widgets = [];
    for (int index = 0; index < levels.length; index++) {
      final level = levels[index];
      final point = points[index];

      final bool isCompleted = user.completedLevels.containsKey(level.id);
      final bool isCurrent = level.id == user.currentLevel;
      final bool isLocked = false; // All levels unlocked

      final completedLevel = user.completedLevels[level.id];
      final int stars = completedLevel?.stars ?? 0;

      // 1. Add level node Column
      widgets.add(
        Positioned(
          left: point.dx - 40,
          top: point.dy - 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildArcStars(stars, isLocked),
              const SizedBox(height: 2),
              _buildLevelNode(
                level: level,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLocked: isLocked,
                stars: stars,
                onTap: () => _showLevelOptions(context, level),
                pulseAnimation: _pulseController,
              ),
              _buildLevelTitle(level.title, isLocked),
            ],
          ),
        ),
      );

      // 2. Add active marker
      if (isCurrent) {
        widgets.add(
          Positioned(
            left: point.dx - 16,
            top: point.dy - 128,
            child: _buildActiveMarker(_pulseController),
          ),
        );
      }
    }
    return widgets;
  }

  // Animated Floating Active Pin
  Widget _buildActiveMarker(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double bobOffset = controller.value * -12.0;
        return Transform.translate(offset: Offset(0, bobOffset), child: child);
      },
      child: SizedBox(
        width: 32,
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(32, 42),
              painter: PinPainter(color: const Color(0xff2ECC71)),
            ),
            Positioned(
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top bar chips for currency display
  Widget _buildTopBarChip({
    required String emoji,
    required int value,
    required VoidCallback onAdd,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xff1A237E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xff3949AB), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Fredoka',
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xff42A5F5), Color(0xff1976D2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double boundedWidth = screenWidth > 430 ? 430 : screenWidth;

    final double centerX = boundedWidth * 0.5;
    final double amplitude = boundedWidth * 0.26;
    const double spacingY = 175.0;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Stack(
                  children: [
                    // 1. Nature-like background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppColors.mapBgGradient,
                      ),
                    ),

                    // 2. Scrollable elements
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        UserEntity? user;
                        if (profileState is ProfileAuthenticated) {
                          user = profileState.user;
                        } else if (profileState is ProfileMilestoneUnlocked) {
                          user = profileState.user;
                        }

                        if (user == null) {
                          return const Center(
                            child: Text(
                              "يرجى تسجيل الدخول",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return BlocBuilder<MapCubit, MapState>(
                          builder: (context, mapState) {
                            if (mapState is! MapLoaded) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final levels = mapState.levels;

                            // startY is computed dynamically from the number of levels
                            // so the canvas height always matches the actual content.
                            final double startY =
                                80.0 + levels.length * spacingY;

                            // Winding offset factors — a fixed serpentine pattern that
                            // repeats / truncates based on the actual number of levels.
                            const List<double> baseXOffsets = [
                              -0.6, // slot 1 (Left)
                              -0.1, // slot 2 (Center-Left)
                              0.4, // slot 3 (Center-Right)
                              0.7, // slot 4 (Right)
                              0.2, // slot 5 (Center)
                              -0.4, // slot 6 (Left-Center)
                              -0.8, // slot 7 (Left)
                              -0.4, // slot 8 (Left-Center)
                              0.2, // slot 9 (Center-Right)
                              0.6, // slot 10 (Right)
                              0.1, // slot 11 (Center-Left)
                              -0.5, // slot 12 (Left)
                              0.0, // slot 13 (Center - Bridge)
                              0.5, // slot 14 (Center-Right)
                              0.0, // slot 15 (Center)
                              -0.6, // slot 16 (Left)
                            ];
                            // Build xOffsets dynamically: use pattern for each level index
                            final List<double> xOffsets = List.generate(
                              levels.length,
                              (i) => baseXOffsets[i % baseXOffsets.length],
                            );

                            // Calculate points for the path
                            final List<Offset> points = [];
                            for (int i = 0; i < levels.length; i++) {
                              final double y = startY - (i * spacingY);
                              final double factor = i < xOffsets.length
                                  ? xOffsets[i]
                                  : sin(i * 1.2);
                              final double x = centerX + factor * amplitude;
                              points.add(Offset(x, y));
                            }

                            return SingleChildScrollView(
                              controller: _scrollController,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: startY + 320,
                                    width: boundedWidth,
                                  ),

                                  // Background clouds
                                  ...List.generate(5, (idx) {
                                    final double cloudY =
                                        startY - (idx * 380) - 200;
                                    final double cloudX = idx % 2 == 0
                                        ? boundedWidth - 100
                                        : 40;
                                    return Positioned(
                                      top: cloudY,
                                      left: cloudX,
                                      child: const Text(
                                        '☁️',
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    );
                                  }),

                                  // Custom painter: River, Road, Bridge, Tunnel, Signpost, bushes, rocks
                                  CustomPaint(
                                    size: Size(boundedWidth, startY + 100),
                                    painter: MapPathPainter(
                                      points,
                                      boundedWidth,
                                      centerX,
                                    ),
                                  ),

                                  // Render level nodes & stars & active floating marker
                                  ..._buildLevelElements(
                                    levels,
                                    points,
                                    user,
                                    context,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 3. Fixed Header Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 8,
                  16,
                  12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    UserEntity? user;
                    if (state is ProfileAuthenticated) {
                      user = state.user;
                    } else if (state is ProfileMilestoneUnlocked) {
                      user = state.user;
                    }

                    if (user == null) {
                      return const SizedBox();
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Settings Button (Orange/Wood themed)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomePage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xffFFB74D), Color(0xffE65100)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        // Currencies Row (Custom dark blue chips)
                        Row(
                          children: [
                            _buildTopBarChip(
                              emoji: '🪙',
                              value: user.gold,
                              onAdd: () {
                                context.read<ProfileCubit>().addGold(50);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'حصلت على 50 قطعة ذهبية إضافية! 🪙',
                                    ),
                                    backgroundColor: Color(0xffFF9800),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildTopBarChip(
                              emoji: '💎',
                              value: user.gems,
                              onAdd: () {
                                context.read<ProfileCubit>().addGems(5);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'حصلت على 5 جواهر إضافية! 💎',
                                    ),
                                    backgroundColor: Color(0xff9C27B0),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // Profile Avatar Link
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.avatar,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 5. Wooden Bottom Navigation Bar (Floating, Premium, 2-Item Design)
            Positioned(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              left: 20,
              right: 20,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff8D5524), Color(0xff704214)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xff5C3A21), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Right Tab (in RTL: Leftmost visually but item 1 in list): Profile (ملفي الشخصي)
                    Expanded(
                      child: Btn3D(
                        color: const Color(0xffFF9800),
                        shadowColor: const Color(0xffE65100),
                        height: 50,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'ملفي الشخصي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Left Tab (in RTL: Rightmost visually but item 2 in list): Map (الخريطة) - Active
                    Expanded(
                      child: Btn3D(
                        color: const Color(0xff4CAF50),
                        shadowColor: const Color(0xff2E7D32),
                        height: 50,
                        onPressed: () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.map_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'الخريطة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
