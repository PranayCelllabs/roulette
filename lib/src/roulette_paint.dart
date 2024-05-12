/// Copyright 2021 do9core
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';
import 'package:roulette/utils/transform_entry.dart';
import 'package:roulette/utils/text.dart';

import 'dart:math';
import 'dart:ui' as ui;

/// Animated roulette core by [AnimatedWidget]
class RoulettePaint extends AnimatedWidget {
  const RoulettePaint({
    Key? key,
    required Animation<double> animation,
    required this.style,
    required this.group,
    required this.selected,
    required this.imageInfos,
    required this.shouldIncludeTextOrIcon,
  }) : super(key: key, listenable: animation);

  final RouletteStyle style;
  final RouletteGroup group;
  final int selected;
  final bool shouldIncludeTextOrIcon;
  final Map<int, ImageInfo> imageInfos;

  Animation<double> get _rotation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _RoulettePainter(
          rotate: _rotation.value,
          style: style,
          group: group,
          imageInfos: imageInfos,
          selectedIndex: selected,
          shouldIncludeTextOrIcon: shouldIncludeTextOrIcon,
        ),
      ),
    );
  }
}

class _RoulettePainter extends CustomPainter {
  _RoulettePainter({
    required this.style,
    required this.rotate,
    required this.group,
    required this.imageInfos,
    required this.selectedIndex,
    required this.shouldIncludeTextOrIcon,
  });

  final RouletteGroup group;
  final Map<int, ImageInfo> imageInfos;
  final double rotate;
  final int selectedIndex;
  final bool shouldIncludeTextOrIcon;
  final RouletteStyle style;

  final Paint _paint = Paint();

  @override
  bool shouldRepaint(covariant _RoulettePainter oldDelegate) {
    return oldDelegate.rotate != rotate ||
        oldDelegate.group != group ||
        oldDelegate.style != style ||
        !mapEquals(oldDelegate.imageInfos, imageInfos);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final double finetuneValue;

    if (group.totalWeights == 2) {
      finetuneValue = 1.55;
    } else if (group.totalWeights == 3) {
      finetuneValue = 1.0;
    } else if (group.totalWeights == 4) {
      finetuneValue = 0.8;
    } else if (group.totalWeights == 5) {
      finetuneValue = 0.65;
    } else if (group.totalWeights == 6) {
      finetuneValue = 0.54;
    } else if (group.totalWeights == 7) {
      finetuneValue = 0.46;
    } else if (group.totalWeights == 8) {
      finetuneValue = 0.39;
    } else if (group.totalWeights == 9) {
      finetuneValue = 0.35;
    } else if (group.totalWeights == 10) {
      finetuneValue = 0.34;
    } else if (group.totalWeights == 11) {
      finetuneValue = 0.28;
    } else if (group.totalWeights == 12) {
      finetuneValue = 0.25;
    } else {
      finetuneValue = 0;
    }

    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();
    canvas.rotate(pi / 2 + rotate - finetuneValue);

    // Draws the backgrounds of the sections.
    _drawBackground(canvas, radius, rect);

    // Draws the content of the sections. not necessary for current requirement
    if (shouldIncludeTextOrIcon) {
      _drawSections(canvas, radius);
    }

    canvas.restore();

    _drawCenterSticker(canvas, radius);
  }

  /// Draws the background of the sections.
  ///
  /// If an image is set, also draws a background image.
  void _drawBackground(Canvas canvas, double radius, Rect rect) {
    _paint.strokeWidth = 0;
    _paint.style = ui.PaintingStyle.fill;

    double drewSweep = 0;

    for (var i = 0; i < group.divide; i++) {
      final RouletteUnit unit = group.units[i];
      final double sweep = 2 * pi * unit.weight / group.totalWeights;

      canvas.save();
      canvas.rotate(drewSweep);

      // Draws the section background color.
      _paint.color = unit.color;
      _paint.strokeWidth = 0;
      _paint.style = ui.PaintingStyle.fill;
      canvas.drawArc(rect, 0.0 * i, sweep, true, _paint);

      final resolvedImage = imageInfos[i]?.image;
      if (unit.image != null && resolvedImage != null) {
        // Draws the section background image
        _drawBackgroundImage(
            canvas, radius, rect, unit, sweep, resolvedImage, i);
      }

      // Draws the section border
      _paint.color =
          i == selectedIndex ? style.selectedDividerColor : style.dividerColor;
      _paint.strokeWidth = style.dividerThickness + 2.4;
      _paint.style = ui.PaintingStyle.stroke;
      canvas.drawArc(rect, 0.0 * i, sweep, true, _paint);

      canvas.restore();
      drewSweep += sweep;
    }
  }

  /// Draws the image to the background of the current section.
  void _drawBackgroundImage(Canvas canvas, double radius, Rect rect,
      RouletteUnit unit, double sweep, ui.Image image, int index) {
    // Draws the section background image

    // Path for this section.
    Path path = Path();
    path.addArc(rect, 0, sweep);
    path.lineTo(0, 0);

    // Rectangle in which the section is.
    var rect2 = path.getBounds();

    // Transforms into a square (biggest)
    if (rect2.height > rect2.width) {
      rect2 = Rect.fromLTWH(rect2.left, rect2.top, rect2.height, rect2.height);
    } else {
      rect2 = Rect.fromLTWH(rect2.left, rect2.top, rect2.width, rect2.width);
    }

    // Calculates size of image in the square.
    double scaleX = (rect2.width / image.width);
    double scaleY = (rect2.height / image.height);

    // Transformation matrix to scale and rotate image in the section.
    Matrix4 matrix = composeMatrixFromOffsets(
      translate: Offset(style.dividerThickness / 2 - 1,
          rect2.top + rect2.height * 4 + style.dividerThickness / 2 + 1),
      scale: index == selectedIndex
          ? (max(scaleX, scaleY)) + 0.004
          : (max(scaleX, scaleY)) - 0.002,
      rotation: sweep / 2 + pi / 2,
      anchor: Offset.zero,
    );

    // Draws the section with the image.
    canvas.drawPath(
      path,
      Paint()
        ..shader = ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          matrix.storage,
          filterQuality: FilterQuality.medium,
        )
        ..style = PaintingStyle.fill
        ..strokeWidth = 0,
    );
  }

  /// Draws every section of the roulette with its text or icon.
  ///
  /// The text or the icon is transformed into a drawable paragraphe.
  void _drawSections(Canvas canvas, double radius) {
    double drewSweep = 0.0; // Drew sweep angle

    for (var i = 0; i < group.divide; i++) {
      // Draws each section with unit
      final unit = group.units[i];
      final sweep = 2 * pi * unit.weight / group.totalWeights;

      canvas.save();
      canvas.rotate(drewSweep + pi / 2 + sweep / 2);

      // The section might have an icon instead of a text.
      final IconData? icon = unit.icon;

      // If there is an icon, it is converted into a string text.
      // Otherwise, the given text is rerieved.
      final String? text =
          icon == null ? unit.text : String.fromCharCode(icon.codePoint);

      // No string text to draw.
      if (text == null) {
        canvas.restore();
        continue;
      }

      final unitTextStyle = unit.textStyle ?? style.textStyle;

      // Gets the text style of the text or the icon.
      final textStyle = icon == null
          ? unitTextStyle
          : unitTextStyle.copyWith(fontFamily: icon.fontFamily);

      // Calculates chord of circle.
      final chord = 2 * (radius * style.textLayoutBias) * sin(sweep / 2);

      // Creates a builder for the paragraph that will be drawn on the canvas.
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.center,
      ))
        ..pushStyle(textStyle.asUiTextStyle())
        ..addText(text);

      // Creates the paragraph.
      final paragraph = pb.build();
      paragraph.layout(ui.ParagraphConstraints(width: chord));

      // Draws the paragraph.
      canvas.drawParagraph(
        paragraph,
        Offset(-chord / 2, -radius * style.textLayoutBias),
      );

      canvas.restore();
      drewSweep += sweep;
    }
  }

  /// Draws a circle in the center of the roulette of the given size in the
  /// roulette's style.
  void _drawCenterSticker(Canvas canvas, double radius) {
    _paint.color = style.centerStickerColor;
    _paint.strokeWidth = 0;
    _paint.style = ui.PaintingStyle.fill;

    canvas.drawCircle(
      Offset.zero,
      radius * style.centerStickSizePercent,
      _paint,
    );
  }
}
