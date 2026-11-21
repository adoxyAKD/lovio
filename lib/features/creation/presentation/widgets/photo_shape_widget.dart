import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/page_document.dart';

class PhotoShapeWidget extends StatelessWidget {
  final String? imagePath;
  final PhotoShape shape;
  final double width;
  final double height;
  final double borderWidth;
  final Color borderColor;
  final String? caption;

  const PhotoShapeWidget({
    super.key,
    required this.imagePath,
    this.shape = PhotoShape.roundedRectangle,
    this.width = 160,
    this.height = 160,
    this.borderWidth = 3,
    this.borderColor = Colors.white,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildRawImage();

    switch (shape) {
      case PhotoShape.rectangle:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: imageWidget,
        );

      case PhotoShape.circle:
        return Container(
          width: width,
          height: width, // Circle uses width as diameter
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: imageWidget),
        );

      case PhotoShape.roundedRectangle:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: imageWidget,
          ),
        );

      case PhotoShape.heart:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const HeartClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth),
              child: ClipPath(
                clipper: const HeartClipper(),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.polaroidFrame:
        return Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: imageWidget,
                ),
              ),
              if (caption != null && caption!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  caption!,
                  style: const TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 14,
                    color: Color(0xFF554448),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );

      case PhotoShape.stampFrame:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const StampClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth + 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.ornateFrame:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFD4AF37), width: borderWidth + 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
          ),
        );

      case PhotoShape.arch:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(width / 2)),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(width / 2 - borderWidth)),
            child: imageWidget,
          ),
        );

      case PhotoShape.scallopedFrame:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor, width: borderWidth + 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: imageWidget,
          ),
        );

      case PhotoShape.diamond:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const DiamondClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth),
              child: ClipPath(
                clipper: const DiamondClipper(),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.star:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const StarClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth),
              child: ClipPath(
                clipper: const StarClipper(),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.cloud:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const CloudClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth),
              child: ClipPath(
                clipper: const CloudClipper(),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.oval:
        return Container(
          width: width,
          height: height * 0.85,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.elliptical(width, height * 0.85)),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: imageWidget),
        );

      case PhotoShape.hexagon:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const HexagonClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth),
              child: ClipPath(
                clipper: const HexagonClipper(),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.tornPaperFrame:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipPath(
            clipper: const TornPaperClipper(),
            child: imageWidget,
          ),
        );

      case PhotoShape.organicBlob:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const OrganicBlobClipper(),
            child: Container(
              color: borderColor,
              padding: EdgeInsets.all(borderWidth),
              child: ClipPath(
                clipper: const OrganicBlobClipper(),
                child: imageWidget,
              ),
            ),
          ),
        );

      case PhotoShape.vintageFrame:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF8C6D53), width: borderWidth + 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageWidget,
            ),
          ),
        );
    }
  }

  Widget _buildRawImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildFallback();
    }

    // 1. Base64 Data URI Support
    if (imagePath!.startsWith('data:image')) {
      try {
        final commaIdx = imagePath!.indexOf(',');
        final base64Data =
            commaIdx != -1 ? imagePath!.substring(commaIdx + 1) : imagePath!;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } catch (_) {
        return _buildFallback();
      }
    }

    // 2. Network Image Support
    if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
      return Image.network(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    // 3. Local File System Support
    try {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
    } catch (_) {}

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFFD1DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFFF4B8B),
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cherished Memory',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF882D4B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartClipper extends CustomClipper<Path> {
  const HeartClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h * 0.85);
    path.cubicTo(w * 0.1, h * 0.55, 0, h * 0.35, 0, h * 0.25);
    path.cubicTo(0, h * 0.05, w * 0.25, 0, w / 2, h * 0.25);
    path.cubicTo(w * 0.75, 0, w, h * 0.05, w, h * 0.25);
    path.cubicTo(w, h * 0.35, w * 0.9, h * 0.55, w / 2, h * 0.85);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class StampClipper extends CustomClipper<Path> {
  const StampClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 6.0;
    const diameter = radius * 2;

    path.moveTo(0, 0);

    // Top edge scallops
    final topCount = (size.width / (diameter * 1.5)).floor();
    final topSpacing = size.width / topCount;
    for (int i = 0; i < topCount; i++) {
      final startX = i * topSpacing;
      path.lineTo(startX + topSpacing / 2 - radius, 0);
      path.arcToPoint(
        Offset(startX + topSpacing / 2 + radius, 0),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    }
    path.lineTo(size.width, 0);

    // Right edge scallops
    final rightCount = (size.height / (diameter * 1.5)).floor();
    final rightSpacing = size.height / rightCount;
    for (int i = 0; i < rightCount; i++) {
      final startY = i * rightSpacing;
      path.lineTo(size.width, startY + rightSpacing / 2 - radius);
      path.arcToPoint(
        Offset(size.width, startY + rightSpacing / 2 + radius),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    }
    path.lineTo(size.width, size.height);

    // Bottom edge scallops
    for (int i = topCount - 1; i >= 0; i--) {
      final startX = i * topSpacing;
      path.lineTo(startX + topSpacing / 2 + radius, size.height);
      path.arcToPoint(
        Offset(startX + topSpacing / 2 - radius, size.height),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    }
    path.lineTo(0, size.height);

    // Left edge scallops
    for (int i = rightCount - 1; i >= 0; i--) {
      final startY = i * rightSpacing;
      path.lineTo(0, startY + rightSpacing / 2 + radius);
      path.arcToPoint(
        Offset(0, startY + rightSpacing / 2 - radius),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    }
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DiamondClipper extends CustomClipper<Path> {
  const DiamondClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class StarClipper extends CustomClipper<Path> {
  const StarClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = math.min(cx, cy);
    final innerR = outerR * 0.48;
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CloudClipper extends CustomClipper<Path> {
  const CloudClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.28),
    ));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  const HexagonClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class OrganicBlobClipper extends CustomClipper<Path> {
  const OrganicBlobClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.85, h * 0.05, w, h * 0.35, w * 0.92, h * 0.7);
    path.cubicTo(w * 0.85, h * 0.95, w * 0.55, h, w * 0.3, h * 0.95);
    path.cubicTo(w * 0.05, h * 0.9, 0, h * 0.65, 0.05 * w, h * 0.35);
    path.cubicTo(0.1 * w, 0.08 * h, w * 0.25, 0, w * 0.5, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TornPaperClipper extends CustomClipper<Path> {
  const TornPaperClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, 0);
    path.lineTo(w, 0);
    const segs = 10;
    for (int i = 0; i < segs; i++) {
      final y1 = (i + 0.5) * (h / segs);
      final y2 = (i + 1.0) * (h / segs);
      final dx = (i.isEven ? 3.5 : -2.5);
      path.lineTo(w + dx, y1);
      path.lineTo(w, y2);
    }
    for (int i = 0; i < segs; i++) {
      final x1 = w - (i + 0.5) * (w / segs);
      final x2 = w - (i + 1.0) * (w / segs);
      final dy = (i.isEven ? 3.5 : -2.5);
      path.lineTo(x1, h + dy);
      path.lineTo(x2, h);
    }
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

