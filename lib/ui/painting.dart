// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


// @dart = 2.12
part of dart.ui;

// Some methods in this file assert that their arguments are not null. These
// asserts are just to improve the error messages; they should only cover
// arguments that are either dereferenced _in Dart_, before being passed to the
// engine, or that the engine explicitly null-checks itself (after attempting to
// convert the argument to a native type). It should not be possible for a null
// or invalid value to be used by the engine even in release mode, since that
// would cause a crash. It is, however, acceptable for error messages to be much
// less useful or correct in release mode than in debug mode.
//
// Painting APIs will also warn about arguments representing NaN coordinates,
// which can not be rendered by Skia.

// Update this list when changing the list of supported codecs.
/// {@template dart.ui.imageFormats}
/// JPEG, PNG, GIF, Animated GIF, WebP, Animated WebP, BMP, and WBMP. Additional
/// formats may be supported by the underlying platform. Flutter will
/// attempt to call platform API to decode unrecognized formats, and if the
/// platform API supports decoding the image Flutter will be able to render it.
/// {@endtemplate}

bool _rectIsValid(Rect rect) {
  assert(rect != null, 'Rect argument was null.');
  assert(!rect.hasNaN, 'Rect argument contained a NaN value.');
  return true;
}

bool _rrectIsValid(RRect rrect) {
  assert(rrect != null, 'RRect argument was null.');
  assert(!rrect.hasNaN, 'RRect argument contained a NaN value.');
  return true;
}

bool _offsetIsValid(Offset offset) {
  assert(offset != null, 'Offset argument was null.');
  assert(!offset.dx.isNaN && !offset.dy.isNaN, 'Offset argument contained a NaN value.');
  return true;
}

bool _matrix4IsValid(Float64List matrix4) {
  assert(matrix4 != null, 'Matrix4 argument was null.');
  assert(matrix4.length == 16, 'Matrix4 must have 16 entries.');
  assert(matrix4.every((double value) => value.isFinite), 'Matrix4 entries must be finite.');
  return true;
}

bool _radiusIsValid(Radius radius) {
  assert(radius != null, 'Radius argument was null.');
  assert(!radius.x.isNaN && !radius.y.isNaN, 'Radius argument contained a NaN value.');
  return true;
}

Color _scaleAlpha(Color a, double factor) {
  return a.withAlpha((a.alpha * factor).round().clamp(0, 255));
}

/// An immutable 32 bit color value in ARGB format.
///
/// Consider the light teal of the Flutter logo. It is fully opaque, with a red
/// channel value of 0x42 (66), a green channel value of 0xA5 (165), and a blue
/// channel value of 0xF5 (245). In the common "hash syntax" for color values,
/// it would be described as `#42A5F5`.
///
/// Here are some ways it could be constructed:
///
/// ```dart
/// Color c = const Color(0xFF42A5F5);
/// Color c = const Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
/// Color c = const Color.fromARGB(255, 66, 165, 245);
/// Color c = const Color.fromRGBO(66, 165, 245, 1.0);
/// ```
///
/// If you are having a problem with `Color` wherein it seems your color is just
/// not painting, check to make sure you are specifying the full 8 hexadecimal
/// digits. If you only specify six, then the leading two digits are assumed to
/// be zero, which means fully-transparent:
///
/// ```dart
/// Color c1 = const Color(0xFFFFFF); // fully transparent white (invisible)
/// Color c2 = const Color(0xFFFFFFFF); // fully opaque white (visible)
/// ```
///
/// See also:
///
///  * [Colors](https://api.flutter.dev/flutter/material/Colors-class.html), which
///    defines the colors found in the Material Design specification.
class Color {
  /// Construct a color from the lower 32 bits of an [int].
  ///
  /// The bits are interpreted as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  ///
  /// In other words, if AA is the alpha value in hex, RR the red value in hex,
  /// GG the green value in hex, and BB the blue value in hex, a color can be
  /// expressed as `const Color(0xAARRGGBB)`.
  ///
  /// For example, to get a fully opaque orange, you would use `const
  /// Color(0xFFFF9000)` (`FF` for the alpha, `FF` for the red, `90` for the
  /// green, and `00` for the blue).
  @pragma('vm:entry-point')
  const Color(int value) : value = value & 0xFFFFFFFF;

  /// Construct a color from the lower 8 bits of four integers.
  ///
  /// * `a` is the alpha value, with 0 being transparent and 255 being fully
  ///   opaque.
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [green], from 0 to 255.
  /// * `b` is [blue], from 0 to 255.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromRGBO], which takes the alpha value as a floating point
  /// value.
  const Color.fromARGB(int a, int r, int g, int b) :
    value = (((a & 0xff) << 24) |
             ((r & 0xff) << 16) |
             ((g & 0xff) << 8)  |
             ((b & 0xff) << 0)) & 0xFFFFFFFF;

  /// Create a color from red, green, blue, and opacity, similar to `rgba()` in CSS.
  ///
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [green], from 0 to 255.
  /// * `b` is [blue], from 0 to 255.
  /// * `opacity` is alpha channel of this color as a double, with 0.0 being
  ///   transparent and 1.0 being fully opaque.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromARGB], which takes the opacity as an integer value.
  const Color.fromRGBO(int r, int g, int b, double opacity) :
    value = ((((opacity * 0xff ~/ 1) & 0xff) << 24) |
              ((r                    & 0xff) << 16) |
              ((g                    & 0xff) << 8)  |
              ((b                    & 0xff) << 0)) & 0xFFFFFFFF;

  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  final int value;

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  int get alpha => (0xff000000 & value) >> 24;

  /// The alpha channel of this color as a double.
  ///
  /// A value of 0.0 means this color is fully transparent. A value of 1.0 means
  /// this color is fully opaque.
  double get opacity => alpha / 0xFF;

  /// The red channel of this color in an 8 bit value.
  int get red => (0x00ff0000 & value) >> 16;

  /// The green channel of this color in an 8 bit value.
  int get green => (0x0000ff00 & value) >> 8;

  /// The blue channel of this color in an 8 bit value.
  int get blue => (0x000000ff & value) >> 0;

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with `a` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withAlpha(int a) {
    return Color.fromARGB(a, red, green, blue);
  }

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with the given `opacity` (which ranges from 0.0 to 1.0).
  ///
  /// Out of range values will have unexpected effects.
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }

  /// Returns a new color that matches this color with the red channel replaced
  /// with `r` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withRed(int r) {
    return Color.fromARGB(alpha, r, green, blue);
  }

  /// Returns a new color that matches this color with the green channel
  /// replaced with `g` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withGreen(int g) {
    return Color.fromARGB(alpha, red, g, blue);
  }

  /// Returns a new color that matches this color with the blue channel replaced
  /// with `b` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withBlue(int b) {
    return Color.fromARGB(alpha, red, green, b);
  }

  // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928)
      return component / 12.92;
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  /// Returns a brightness value between 0 for darkest and 1 for lightest.
  ///
  /// Represents the relative luminance of the color. This value is computationally
  /// expensive to calculate.
  ///
  /// See <https://en.wikipedia.org/wiki/Relative_luminance>.
  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
    final double R = _linearizeColorComponent(red / 0xFF);
    final double G = _linearizeColorComponent(green / 0xFF);
    final double B = _linearizeColorComponent(blue / 0xFF);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  /// Linearly interpolate between two colors.
  ///
  /// This is intended to be fast but as a result may be ugly. Consider
  /// [HSVColor] or writing custom logic for interpolating colors.
  ///
  /// If either color is null, this function linearly interpolates from a
  /// transparent instance of the other color. This is usually preferable to
  /// interpolating from [material.Colors.transparent] (`const
  /// Color(0x00000000)`), which is specifically transparent _black_.
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]). Each channel
  /// will be clamped to the range 0 to 255.
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static Color? lerp(Color? a, Color? b, double t) {
    assert(t != null);
    if (b == null) {
      if (a == null) {
        return null;
      } else {
        return _scaleAlpha(a, 1.0 - t);
      }
    } else {
      if (a == null) {
        return _scaleAlpha(b, t);
      } else {
        return Color.fromARGB(
          _clampInt(_lerpInt(a.alpha, b.alpha, t).toInt(), 0, 255),
          _clampInt(_lerpInt(a.red, b.red, t).toInt(), 0, 255),
          _clampInt(_lerpInt(a.green, b.green, t).toInt(), 0, 255),
          _clampInt(_lerpInt(a.blue, b.blue, t).toInt(), 0, 255),
        );
      }
    }
  }

  /// Combine the foreground color as a transparent color over top
  /// of a background color, and return the resulting combined color.
  ///
  /// This uses standard alpha blending ("SRC over DST") rules to produce a
  /// blended color from two colors. This can be used as a performance
  /// enhancement when trying to avoid needless alpha blending compositing
  /// operations for two things that are solid colors with the same shape, but
  /// overlay each other: instead, just paint one with the combined color.
  static Color alphaBlend(Color foreground, Color background) {
    final int alpha = foreground.alpha;
    if (alpha == 0x00) { // Foreground completely transparent.
      return background;
    }
    final int invAlpha = 0xff - alpha;
    int backAlpha = background.alpha;
    if (backAlpha == 0xff) { // Opaque background case
      return Color.fromARGB(
        0xff,
        (alpha * foreground.red + invAlpha * background.red) ~/ 0xff,
        (alpha * foreground.green + invAlpha * background.green) ~/ 0xff,
        (alpha * foreground.blue + invAlpha * background.blue) ~/ 0xff,
      );
    } else { // General case
      backAlpha = (backAlpha * invAlpha) ~/ 0xff;
      final int outAlpha = alpha + backAlpha;
      assert(outAlpha != 0x00);
      return Color.fromARGB(
        outAlpha,
        (foreground.red * alpha + background.red * backAlpha) ~/ outAlpha,
        (foreground.green * alpha + background.green * backAlpha) ~/ outAlpha,
        (foreground.blue * alpha + background.blue * backAlpha) ~/ outAlpha,
      );
    }
  }

  /// Returns an alpha value representative of the provided [opacity] value.
  ///
  /// The [opacity] value may not be null.
  static int getAlphaFromOpacity(double opacity) {
    assert(opacity != null);
    return (opacity.clamp(0.0, 1.0) * 255).round();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is Color
        && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';
}

/// Algorithms to use when painting on the canvas.
///
/// When drawing a shape or image onto a canvas, different algorithms can be
/// used to blend the pixels. The different values of [BlendMode] specify
/// different such algorithms.
///
/// Each algorithm has two inputs, the _source_, which is the image being drawn,
/// and the _destination_, which is the image into which the source image is
/// being composited. The destination is often thought of as the _background_.
/// The source and destination both have four color channels, the red, green,
/// blue, and alpha channels. These are typically represented as numbers in the
/// range 0.0 to 1.0. The output of the algorithm also has these same four
/// channels, with values computed from the source and destination.
///
/// The documentation of each value below describes how the algorithm works. In
/// each case, an image shows the output of blending a source image with a
/// destination image. In the images below, the destination is represented by an
/// image with horizontal lines and an opaque landscape photograph, and the
/// source is represented by an image with vertical lines (the same lines but
/// rotated) and a bird clip-art image. The [src] mode shows only the source
/// image, and the [dst] mode shows only the destination image. In the
/// documentation below, the transparency is illustrated by a checkerboard
/// pattern. The [clear] mode drops both the source and destination, resulting
/// in an output that is entirely transparent (illustrated by a solid
/// checkerboard pattern).
///
/// The horizontal and vertical bars in these images show the red, green, and
/// blue channels with varying opacity levels, then all three color channels
/// together with those same varying opacity levels, then all three color
/// channels set to zero with those varying opacity levels, then two bars showing
/// a red/green/blue repeating gradient, the first with full opacity and the
/// second with partial opacity, and finally a bar with the three color channels
/// set to zero but the opacity varying in a repeating gradient.
///
/// ## Application to the [Canvas] API
///
/// When using [Canvas.saveLayer] and [Canvas.restore], the blend mode of the
/// [Paint] given to the [Canvas.saveLayer] will be applied when
/// [Canvas.restore] is called. Each call to [Canvas.saveLayer] introduces a new
/// layer onto which shapes and images are painted; when [Canvas.restore] is
/// called, that layer is then composited onto the parent layer, with the source
/// being the most-recently-drawn shapes and images, and the destination being
/// the parent layer. (For the first [Canvas.saveLayer] call, the parent layer
/// is the canvas itself.)
///
/// See also:
///
///  * [Paint.blendMode], which uses [BlendMode] to define the compositing
///    strategy.
enum BlendMode {
  // This list comes from Skia's SkXfermode.h and the values (order) should be
  // kept in sync.
  // See: https://skia.org/docs/user/api/skpaint_overview/#SkXfermode

  /// Drop both the source and destination images, leaving nothing.
  ///
  /// This corresponds to the "clear" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_clear.png)
  clear,

  /// Drop the destination image, only paint the source image.
  ///
  /// Conceptually, the destination is first cleared, then the source image is
  /// painted.
  ///
  /// This corresponds to the "Copy" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_src.png)
  src,

  /// Drop the source image, only paint the destination image.
  ///
  /// Conceptually, the source image is discarded, leaving the destination
  /// untouched.
  ///
  /// This corresponds to the "Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dst.png)
  dst,

  /// Composite the source image over the destination image.
  ///
  /// This is the default value. It represents the most intuitive case, where
  /// shapes are painted on top of what is below, with transparent areas showing
  /// the destination layer.
  ///
  /// This corresponds to the "Source over Destination" Porter-Duff operator,
  /// also known as the Painter's Algorithm.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcOver.png)
  srcOver,

  /// Composite the source image under the destination image.
  ///
  /// This is the opposite of [srcOver].
  ///
  /// This corresponds to the "Destination over Source" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstOver.png)
  ///
  /// This is useful when the source image should have been painted before the
  /// destination image, but could not be.
  dstOver,

  /// Show the source image, but only where the two images overlap. The
  /// destination image is not rendered, it is treated merely as a mask. The
  /// color channels of the destination are ignored, only the opacity has an
  /// effect.
  ///
  /// To show the destination image instead, consider [dstIn].
  ///
  /// To reverse the semantic of the mask (only showing the source where the
  /// destination is absent, rather than where it is present), consider
  /// [srcOut].
  ///
  /// This corresponds to the "Source in Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcIn.png)
  srcIn,

  /// Show the destination image, but only where the two images overlap. The
  /// source image is not rendered, it is treated merely as a mask. The color
  /// channels of the source are ignored, only the opacity has an effect.
  ///
  /// To show the source image instead, consider [srcIn].
  ///
  /// To reverse the semantic of the mask (only showing the source where the
  /// destination is present, rather than where it is absent), consider [dstOut].
  ///
  /// This corresponds to the "Destination in Source" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstIn.png)
  dstIn,

  /// Show the source image, but only where the two images do not overlap. The
  /// destination image is not rendered, it is treated merely as a mask. The color
  /// channels of the destination are ignored, only the opacity has an effect.
  ///
  /// To show the destination image instead, consider [dstOut].
  ///
  /// To reverse the semantic of the mask (only showing the source where the
  /// destination is present, rather than where it is absent), consider [srcIn].
  ///
  /// This corresponds to the "Source out Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcOut.png)
  srcOut,

  /// Show the destination image, but only where the two images do not overlap. The
  /// source image is not rendered, it is treated merely as a mask. The color
  /// channels of the source are ignored, only the opacity has an effect.
  ///
  /// To show the source image instead, consider [srcOut].
  ///
  /// To reverse the semantic of the mask (only showing the destination where the
  /// source is present, rather than where it is absent), consider [dstIn].
  ///
  /// This corresponds to the "Destination out Source" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstOut.png)
  dstOut,

  /// Composite the source image over the destination image, but only where it
  /// overlaps the destination.
  ///
  /// This corresponds to the "Source atop Destination" Porter-Duff operator.
  ///
  /// This is essentially the [srcOver] operator, but with the output's opacity
  /// channel being set to that of the destination image instead of being a
  /// combination of both image's opacity channels.
  ///
  /// For a variant with the destination on top instead of the source, see
  /// [dstATop].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcATop.png)
  srcATop,

  /// Composite the destination image over the source image, but only where it
  /// overlaps the source.
  ///
  /// This corresponds to the "Destination atop Source" Porter-Duff operator.
  ///
  /// This is essentially the [dstOver] operator, but with the output's opacity
  /// channel being set to that of the source image instead of being a
  /// combination of both image's opacity channels.
  ///
  /// For a variant with the source on top instead of the destination, see
  /// [srcATop].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstATop.png)
  dstATop,

  /// Apply a bitwise `xor` operator to the source and destination images. This
  /// leaves transparency where they would overlap.
  ///
  /// This corresponds to the "Source xor Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_xor.png)
  xor,

  /// Sum the components of the source and destination images.
  ///
  /// Transparency in a pixel of one of the images reduces the contribution of
  /// that image to the corresponding output pixel, as if the color of that
  /// pixel in that image was darker.
  ///
  /// This corresponds to the "Source plus Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_plus.png)
  plus,

  /// Multiply the color components of the source and destination images.
  ///
  /// This can only result in the same or darker colors (multiplying by white,
  /// 1.0, results in no change; multiplying by black, 0.0, results in black).
  ///
  /// When compositing two opaque images, this has similar effect to overlapping
  /// two transparencies on a projector.
  ///
  /// For a variant that also multiplies the alpha channel, consider [multiply].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_modulate.png)
  ///
  /// See also:
  ///
  ///  * [screen], which does a similar computation but inverted.
  ///  * [overlay], which combines [modulate] and [screen] to favor the
  ///    destination image.
  ///  * [hardLight], which combines [modulate] and [screen] to favor the
  ///    source image.
  modulate,

  // Following blend modes are defined in the CSS Compositing standard.

  /// Multiply the inverse of the components of the source and destination
  /// images, and inverse the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// This is essentially the same as [modulate] blend mode, but with the values
  /// of the colors inverted before the multiplication and the result being
  /// inverted back before rendering.
  ///
  /// This can only result in the same or lighter colors (multiplying by black,
  /// 1.0, results in no change; multiplying by white, 0.0, results in white).
  /// Similarly, in the alpha channel, it can only result in more opaque colors.
  ///
  /// This has similar effect to two projectors displaying their images on the
  /// same screen simultaneously.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_screen.png)
  ///
  /// See also:
  ///
  ///  * [modulate], which does a similar computation but without inverting the
  ///    values.
  ///  * [overlay], which combines [modulate] and [screen] to favor the
  ///    destination image.
  ///  * [hardLight], which combines [modulate] and [screen] to favor the
  ///    source image.
  screen,  // The last coeff mode.

  /// Multiply the components of the source and destination images after
  /// adjusting them to favor the destination.
  ///
  /// Specifically, if the destination value is smaller, this multiplies it with
  /// the source value, whereas is the source value is smaller, it multiplies
  /// the inverse of the source value with the inverse of the destination value,
  /// then inverts the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_overlay.png)
  ///
  /// See also:
  ///
  ///  * [modulate], which always multiplies the values.
  ///  * [screen], which always multiplies the inverses of the values.
  ///  * [hardLight], which is similar to [overlay] but favors the source image
  ///    instead of the destination image.
  overlay,

  /// Composite the source and destination image by choosing the lowest value
  /// from each color channel.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_darken.png)
  darken,

  /// Composite the source and destination image by choosing the highest value
  /// from each color channel.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_lighten.png)
  lighten,

  /// Divide the destination by the inverse of the source.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_colorDodge.png)
  colorDodge,

  /// Divide the inverse of the destination by the source, and inverse the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_colorBurn.png)
  colorBurn,

  /// Multiply the components of the source and destination images after
  /// adjusting them to favor the source.
  ///
  /// Specifically, if the source value is smaller, this multiplies it with the
  /// destination value, whereas is the destination value is smaller, it
  /// multiplies the inverse of the destination value with the inverse of the
  /// source value, then inverts the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_hardLight.png)
  ///
  /// See also:
  ///
  ///  * [modulate], which always multiplies the values.
  ///  * [screen], which always multiplies the inverses of the values.
  ///  * [overlay], which is similar to [hardLight] but favors the destination
  ///    image instead of the source image.
  hardLight,

  /// Use [colorDodge] for source values below 0.5 and [colorBurn] for source
  /// values above 0.5.
  ///
  /// This results in a similar but softer effect than [overlay].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_softLight.png)
  ///
  /// See also:
  ///
  ///  * [color], which is a more subtle tinting effect.
  softLight,

  /// Subtract the smaller value from the bigger value for each channel.
  ///
  /// Compositing black has no effect; compositing white inverts the colors of
  /// the other image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// The effect is similar to [exclusion] but harsher.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_difference.png)
  difference,

  /// Subtract double the product of the two images from the sum of the two
  /// images.
  ///
  /// Compositing black has no effect; compositing white inverts the colors of
  /// the other image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// The effect is similar to [difference] but softer.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_exclusion.png)
  exclusion,

  /// Multiply the components of the source and destination images, including
  /// the alpha channel.
  ///
  /// This can only result in the same or darker colors (multiplying by white,
  /// 1.0, results in no change; multiplying by black, 0.0, results in black).
  ///
  /// Since the alpha channel is also multiplied, a fully-transparent pixel
  /// (opacity 0.0) in one image results in a fully transparent pixel in the
  /// output. This is similar to [dstIn], but with the colors combined.
  ///
  /// For a variant that multiplies the colors but does not multiply the alpha
  /// channel, consider [modulate].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_multiply.png)
  multiply,  // The last separable mode.

  /// Take the hue of the source image, and the saturation and luminosity of the
  /// destination image.
  ///
  /// The effect is to tint the destination image with the source image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their hue from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_hue.png)
  ///
  /// See also:
  ///
  ///  * [color], which is a similar but stronger effect as it also applies the
  ///    saturation of the source image.
  ///  * [HSVColor], which allows colors to be expressed using Hue rather than
  ///    the red/green/blue channels of [Color].
  hue,

  /// Take the saturation of the source image, and the hue and luminosity of the
  /// destination image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their saturation from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_hue.png)
  ///
  /// See also:
  ///
  ///  * [color], which also applies the hue of the source image.
  ///  * [luminosity], which applies the luminosity of the source image to the
  ///    destination.
  saturation,

  /// Take the hue and saturation of the source image, and the luminosity of the
  /// destination image.
  ///
  /// The effect is to tint the destination image with the source image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their hue and saturation from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_color.png)
  ///
  /// See also:
  ///
  ///  * [hue], which is a similar but weaker effect.
  ///  * [softLight], which is a similar tinting effect but also tints white.
  ///  * [saturation], which only applies the saturation of the source image.
  color,

  /// Take the luminosity of the source image, and the hue and saturation of the
  /// destination image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their luminosity from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_luminosity.png)
  ///
  /// See also:
  ///
  ///  * [saturation], which applies the saturation of the source image to the
  ///    destination.
  ///  * [ImageFilter.blur], which can be used with [BackdropFilter] for a
  ///    related effect.
  luminosity,
}

/// Quality levels for image sampling in [ImageFilter] and [Shader] objects that sample
/// images and for [Canvas] operations that render images.
///
/// When scaling up typically the quality is lowest at [none], higher at [low] and [medium],
/// and for very large scale factors (over 10x) the highest at [high].
///
/// When scaling down, [medium] provides the best quality especially when scaling an
/// image to less than half its size or for animating the scale factor between such
/// reductions. Otherwise, [low] and [high] provide similar effects for reductions of
/// between 50% and 100% but the image may lose detail and have dropouts below 50%.
///
/// To get high quality when scaling images up and down, or when the scale is
/// unknown, [medium] is typically a good balanced choice.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/filter_quality.png)
///
/// When building for the web using the `--web-renderer=html` option, filter
/// quality has no effect. All images are rendered using the respective
/// browser's default setting.
///
/// See also:
///
///  * [Paint.filterQuality], which is used to pass [FilterQuality] to the
///    engine while using drawImage calls on a [Canvas].
///  * [ImageShader].
///  * [ImageFilter.matrix].
///  * [Canvas.drawImage].
///  * [Canvas.drawImageRect].
///  * [Canvas.drawImageNine].
///  * [Canvas.drawAtlas].
enum FilterQuality {
  // This list and the values (order) should be kept in sync with the equivalent list
  // in lib/ui/painting/image_filter.cc

  /// The fastest filtering method, albeit also the lowest quality.
  ///
  /// This value results in a "Nearest Neighbor" algorithm which just
  /// repeats or eliminates pixels as an image is scaled up or down.
  none,

  /// Better quality than [none], faster than [medium].
  ///
  /// This value results in a "Bilinear" algorithm which smoothly
  /// interpolates between pixels in an image.
  low,

  /// The best all around filtering method that is only worse than [high]
  /// at extremely large scale factors.
  ///
  /// This value improves upon the "Bilinear" algorithm specified by [low]
  /// by utilizing a Mipmap that pre-computes high quality lower resolutions
  /// of the image at half (and quarter and eighth, etc.) sizes and then
  /// blends between those to prevent loss of detail at small scale sizes.
  ///
  /// {@template dart.ui.filterQuality.seeAlso}
  /// See also:
  ///
  ///  * [FilterQuality] class-level documentation that goes into detail about
  ///    relative qualities of the constant values.
  /// {@endtemplate}
  medium,

  /// Best possible quality when scaling up images by scale factors larger than
  /// 5-10x.
  ///
  /// When images are scaled down, this can be worse than [medium] for scales
  /// smaller than 0.5x, or when animating the scale factor.
  ///
  /// This option is also the slowest.
  ///
  /// This value results in a standard "Bicubic" algorithm which uses a 3rd order
  /// equation to smooth the abrupt transitions between pixels while preserving
  /// some of the sense of an edge and avoiding sharp peaks in the result.
  ///
  /// {@macro dart.ui.filterQuality.seeAlso}
  high,
}

/// Styles to use for line endings.
///
/// See also:
///
///  * [Paint.strokeCap] for how this value is used.
///  * [StrokeJoin] for the different kinds of line segment joins.
// These enum values must be kept in sync with SkPaint::Cap.
enum StrokeCap {
  /// Begin and end contours with a flat edge and no extension.
  ///
  /// ![A butt cap ends line segments with a square end that stops at the end of
  /// the line segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/butt_cap.png)
  ///
  /// Compare to the [square] cap, which has the same shape, but extends past
  /// the end of the line by half a stroke width.
  butt,

  /// Begin and end contours with a semi-circle extension.
  ///
  /// ![A round cap adds a rounded end to the line segment that protrudes
  /// by one half of the thickness of the line (which is the radius of the cap)
  /// past the end of the segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  round,

  /// Begin and end contours with a half square extension. This is
  /// similar to extending each contour by half the stroke width (as
  /// given by [Paint.strokeWidth]).
  ///
  /// ![A square cap has a square end that effectively extends the line length
  /// by half of the stroke width.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/square_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  ///
  /// Compare to the [butt] cap, which has the same shape, but doesn't extend
  /// past the end of the line.
  square,
}

/// Styles to use for line segment joins.
///
/// This only affects line joins for polygons drawn by [Canvas.drawPath] and
/// rectangles, not points drawn as lines with [Canvas.drawPoints].
///
/// See also:
///
/// * [Paint.strokeJoin] and [Paint.strokeMiterLimit] for how this value is
///   used.
/// * [StrokeCap] for the different kinds of line endings.
// These enum values must be kept in sync with SkPaint::Join.
enum StrokeJoin {
  /// Joins between line segments form sharp corners.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/miter_4_join.mp4}
  ///
  /// The center of the line segment is colored in the diagram above to
  /// highlight the join, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///   * [Paint.strokeJoin], used to set the line segment join style to this
  ///     value.
  ///   * [Paint.strokeMiterLimit], used to define when a miter is drawn instead
  ///     of a bevel when the join is set to this value.
  miter,

  /// Joins between line segments are semi-circular.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_join.mp4}
  ///
  /// The center of the line segment is colored in the diagram above to
  /// highlight the join, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///   * [Paint.strokeJoin], used to set the line segment join style to this
  ///     value.
  round,

  /// Joins between line segments connect the corners of the butt ends of the
  /// line segments to give a beveled appearance.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/bevel_join.mp4}
  ///
  /// The center of the line segment is colored in the diagram above to
  /// highlight the join, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///   * [Paint.strokeJoin], used to set the line segment join style to this
  ///     value.
  bevel,
}

/// Strategies for painting shapes and paths on a canvas.
///
/// See [Paint.style].
// These enum values must be kept in sync with SkPaint::Style.
enum PaintingStyle {
  // This list comes from Skia's SkPaint.h and the values (order) should be kept
  // in sync.

  /// Apply the [Paint] to the inside of the shape. For example, when
  /// applied to the [Canvas.drawCircle] call, this results in a disc
  /// of the given size being painted.
  fill,

  /// Apply the [Paint] to the edge of the shape. For example, when
  /// applied to the [Canvas.drawCircle] call, this results is a hoop
  /// of the given size being painted. The line drawn on the edge will
  /// be the width given by the [Paint.strokeWidth] property.
  stroke,
}


/// Different ways to clip a widget's content.
enum Clip {
  /// No clip at all.
  ///
  /// This is the default option for most widgets: if the content does not
  /// overflow the widget boundary, don't pay any performance cost for clipping.
  ///
  /// If the content does overflow, please explicitly specify the following
  /// [Clip] options:
  ///  * [hardEdge], which is the fastest clipping, but with lower fidelity.
  ///  * [antiAlias], which is a little slower than [hardEdge], but with smoothed edges.
  ///  * [antiAliasWithSaveLayer], which is much slower than [antiAlias], and should
  ///    rarely be used.
  none,

  /// Clip, but do not apply anti-aliasing.
  ///
  /// This mode enables clipping, but curves and non-axis-aligned straight lines will be
  /// jagged as no effort is made to anti-alias.
  ///
  /// Faster than other clipping modes, but slower than [none].
  ///
  /// This is a reasonable choice when clipping is needed, if the container is an axis-
  /// aligned rectangle or an axis-aligned rounded rectangle with very small corner radii.
  ///
  /// See also:
  ///
  ///  * [antiAlias], which is more reasonable when clipping is needed and the shape is not
  ///    an axis-aligned rectangle.
  hardEdge,

  /// Clip with anti-aliasing.
  ///
  /// This mode has anti-aliased clipping edges to achieve a smoother look.
  ///
  /// It' s much faster than [antiAliasWithSaveLayer], but slower than [hardEdge].
  ///
  /// This will be the common case when dealing with circles and arcs.
  ///
  /// Different from [hardEdge] and [antiAliasWithSaveLayer], this clipping may have
  /// bleeding edge artifacts.
  /// (See https://fiddle.skia.org/c/21cb4c2b2515996b537f36e7819288ae for an example.)
  ///
  /// See also:
  ///
  ///  * [hardEdge], which is a little faster, but with lower fidelity.
  ///  * [antiAliasWithSaveLayer], which is much slower, but can avoid the
  ///    bleeding edges if there's no other way.
  ///  * [Paint.isAntiAlias], which is the anti-aliasing switch for general draw operations.
  antiAlias,

  /// Clip with anti-aliasing and saveLayer immediately following the clip.
  ///
  /// This mode not only clips with anti-aliasing, but also allocates an offscreen
  /// buffer. All subsequent paints are carried out on that buffer before finally
  /// being clipped and composited back.
  ///
  /// This is very slow. It has no bleeding edge artifacts (that [antiAlias] has)
  /// but it changes the semantics as an offscreen buffer is now introduced.
  /// (See https://github.com/flutter/flutter/issues/18057#issuecomment-394197336
  /// for a difference between paint without saveLayer and paint with saveLayer.)
  ///
  /// This will be only rarely needed. One case where you might need this is if
  /// you have an image overlaid on a very different background color. In these
  /// cases, consider whether you can avoid overlaying multiple colors in one
  /// spot (e.g. by having the background color only present where the image is
  /// absent). If you can, [antiAlias] would be fine and much faster.
  ///
  /// See also:
  ///
  ///  * [antiAlias], which is much faster, and has similar clipping results.
  antiAliasWithSaveLayer,
}

/// A description of the style to use when drawing on a [Canvas].
///
/// Most APIs on [Canvas] take a [Paint] object to describe the style
/// to use for that operation.
class Paint {
  // Paint objects are encoded in two buffers:
  //
  // * _data is binary data in four-byte fields, each of which is either a
  //   uint32_t or a float. The default value for each field is encoded as
  //   zero to make initialization trivial. Most values already have a default
  //   value of zero, but some, such as color, have a non-zero default value.
  //   To encode or decode these values, XOR the value with the default value.
  //
  // * _objects is a list of unencodable objects, typically wrappers for native
  //   objects. The objects are simply stored in the list without any additional
  //   encoding.
  //
  // The binary format must match the deserialization code in paint.cc.

  final ByteData _data = ByteData(_kDataByteCount);

  static const int _kIsAntiAliasIndex = 0;
  static const int _kColorIndex = 1;
  static const int _kBlendModeIndex = 2;
  static const int _kStyleIndex = 3;
  static const int _kStrokeWidthIndex = 4;
  static const int _kStrokeCapIndex = 5;
  static const int _kStrokeJoinIndex = 6;
  static const int _kStrokeMiterLimitIndex = 7;
  static const int _kFilterQualityIndex = 8;
  static const int _kMaskFilterIndex = 9;
  static const int _kMaskFilterBlurStyleIndex = 10;
  static const int _kMaskFilterSigmaIndex = 11;
  static const int _kInvertColorIndex = 12;
  static const int _kDitherIndex = 13;

  static const int _kIsAntiAliasOffset = _kIsAntiAliasIndex << 2;
  static const int _kColorOffset = _kColorIndex << 2;
  static const int _kBlendModeOffset = _kBlendModeIndex << 2;
  static const int _kStyleOffset = _kStyleIndex << 2;
  static const int _kStrokeWidthOffset = _kStrokeWidthIndex << 2;
  static const int _kStrokeCapOffset = _kStrokeCapIndex << 2;
  static const int _kStrokeJoinOffset = _kStrokeJoinIndex << 2;
  static const int _kStrokeMiterLimitOffset = _kStrokeMiterLimitIndex << 2;
  static const int _kFilterQualityOffset = _kFilterQualityIndex << 2;
  static const int _kMaskFilterOffset = _kMaskFilterIndex << 2;
  static const int _kMaskFilterBlurStyleOffset = _kMaskFilterBlurStyleIndex << 2;
  static const int _kMaskFilterSigmaOffset = _kMaskFilterSigmaIndex << 2;
  static const int _kInvertColorOffset = _kInvertColorIndex << 2;
  static const int _kDitherOffset = _kDitherIndex << 2;
  // If you add more fields, remember to update _kDataByteCount.
  static const int _kDataByteCount = 56;

  // Binary format must match the deserialization code in paint.cc.
  List<Object?>? _objects;

  List<Object?> _ensureObjectsInitialized() {
    return _objects ??= List<Object?>.filled(_kObjectCount, null, growable: false);
  }

  static const int _kShaderIndex = 0;
  static const int _kColorFilterIndex = 1;
  static const int _kImageFilterIndex = 2;
  static const int _kObjectCount = 3; // Must be one larger than the largest index.

  /// Constructs an empty [Paint] object with all fields initialized to
  /// their defaults.
  Paint() {
    if (enableDithering) {
      _dither = true;
    }
  }

  /// Whether to apply anti-aliasing to lines and images drawn on the
  /// canvas.
  ///
  /// Defaults to true.
  bool get isAntiAlias {
    return _data.getInt32(_kIsAntiAliasOffset, _kFakeHostEndian) == 0;
  }
  set isAntiAlias(bool value) {
    // We encode true as zero and false as one because the default value, which
    // we always encode as zero, is true.
    final int encoded = value ? 0 : 1;
    _data.setInt32(_kIsAntiAliasOffset, encoded, _kFakeHostEndian);
  }

  // Must be kept in sync with the default in paint.cc.
  static const int _kColorDefault = 0xFF000000;

  /// The color to use when stroking or filling a shape.
  ///
  /// Defaults to opaque black.
  ///
  /// See also:
  ///
  ///  * [style], which controls whether to stroke or fill (or both).
  ///  * [colorFilter], which overrides [color].
  ///  * [shader], which overrides [color] with more elaborate effects.
  ///
  /// This color is not used when compositing. To colorize a layer, use
  /// [colorFilter].
  Color get color {
    final int encoded = _data.getInt32(_kColorOffset, _kFakeHostEndian);
    return Color(encoded ^ _kColorDefault);
  }
  set color(Color value) {
    assert(value != null);
    final int encoded = value.value ^ _kColorDefault;
    _data.setInt32(_kColorOffset, encoded, _kFakeHostEndian);
  }

  // Must be kept in sync with the default in paint.cc.
  static final int _kBlendModeDefault = BlendMode.srcOver.index;

  /// A blend mode to apply when a shape is drawn or a layer is composited.
  ///
  /// The source colors are from the shape being drawn (e.g. from
  /// [Canvas.drawPath]) or layer being composited (the graphics that were drawn
  /// between the [Canvas.saveLayer] and [Canvas.restore] calls), after applying
  /// the [colorFilter], if any.
  ///
  /// The destination colors are from the background onto which the shape or
  /// layer is being composited.
  ///
  /// Defaults to [BlendMode.srcOver].
  ///
  /// See also:
  ///
  ///  * [Canvas.saveLayer], which uses its [Paint]'s [blendMode] to composite
  ///    the layer when [Canvas.restore] is called.
  ///  * [BlendMode], which discusses the user of [Canvas.saveLayer] with
  ///    [blendMode].
  BlendMode get blendMode {
    final int encoded = _data.getInt32(_kBlendModeOffset, _kFakeHostEndian);
    return BlendMode.values[encoded ^ _kBlendModeDefault];
  }
  set blendMode(BlendMode value) {
    assert(value != null);
    final int encoded = value.index ^ _kBlendModeDefault;
    _data.setInt32(_kBlendModeOffset, encoded, _kFakeHostEndian);
  }

  /// Whether to paint inside shapes, the edges of shapes, or both.
  ///
  /// Defaults to [PaintingStyle.fill].
  PaintingStyle get style {
    return PaintingStyle.values[_data.getInt32(_kStyleOffset, _kFakeHostEndian)];
  }
  set style(PaintingStyle value) {
    assert(value != null);
    final int encoded = value.index;
    _data.setInt32(_kStyleOffset, encoded, _kFakeHostEndian);
  }

  /// How wide to make edges drawn when [style] is set to
  /// [PaintingStyle.stroke]. The width is given in logical pixels measured in
  /// the direction orthogonal to the direction of the path.
  ///
  /// Defaults to 0.0, which correspond to a hairline width.
  double get strokeWidth {
    return _data.getFloat32(_kStrokeWidthOffset, _kFakeHostEndian);
  }
  set strokeWidth(double value) {
    assert(value != null);
    final double encoded = value;
    _data.setFloat32(_kStrokeWidthOffset, encoded, _kFakeHostEndian);
  }

  /// The kind of finish to place on the end of lines drawn when
  /// [style] is set to [PaintingStyle.stroke].
  ///
  /// Defaults to [StrokeCap.butt], i.e. no caps.
  StrokeCap get strokeCap {
    return StrokeCap.values[_data.getInt32(_kStrokeCapOffset, _kFakeHostEndian)];
  }
  set strokeCap(StrokeCap value) {
    assert(value != null);
    final int encoded = value.index;
    _data.setInt32(_kStrokeCapOffset, encoded, _kFakeHostEndian);
  }

  /// The kind of finish to place on the joins between segments.
  ///
  /// This applies to paths drawn when [style] is set to [PaintingStyle.stroke],
  /// It does not apply to points drawn as lines with [Canvas.drawPoints].
  ///
  /// Defaults to [StrokeJoin.miter], i.e. sharp corners.
  ///
  /// Some examples of joins:
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/miter_4_join.mp4}
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_join.mp4}
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/bevel_join.mp4}
  ///
  /// The centers of the line segments are colored in the diagrams above to
  /// highlight the joins, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///  * [strokeMiterLimit] to control when miters are replaced by bevels when
  ///    this is set to [StrokeJoin.miter].
  ///  * [strokeCap] to control what is drawn at the ends of the stroke.
  ///  * [StrokeJoin] for the definitive list of stroke joins.
  StrokeJoin get strokeJoin {
    return StrokeJoin.values[_data.getInt32(_kStrokeJoinOffset, _kFakeHostEndian)];
  }
  set strokeJoin(StrokeJoin value) {
    assert(value != null);
    final int encoded = value.index;
    _data.setInt32(_kStrokeJoinOffset, encoded, _kFakeHostEndian);
  }

  // Must be kept in sync with the default in paint.cc.
  static const double _kStrokeMiterLimitDefault = 4.0;

  /// The limit for miters to be drawn on segments when the join is set to
  /// [StrokeJoin.miter] and the [style] is set to [PaintingStyle.stroke]. If
  /// this limit is exceeded, then a [StrokeJoin.bevel] join will be drawn
  /// instead. This may cause some 'popping' of the corners of a path if the
  /// angle between line segments is animated, as seen in the diagrams below.
  ///
  /// This limit is expressed as a limit on the length of the miter.
  ///
  /// Defaults to 4.0.  Using zero as a limit will cause a [StrokeJoin.bevel]
  /// join to be used all the time.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/miter_0_join.mp4}
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/miter_4_join.mp4}
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/miter_6_join.mp4}
  ///
  /// The centers of the line segments are colored in the diagrams above to
  /// highlight the joins, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///  * [strokeJoin] to control the kind of finish to place on the joins
  ///    between segments.
  ///  * [strokeCap] to control what is drawn at the ends of the stroke.
  double get strokeMiterLimit {
    return _data.getFloat32(_kStrokeMiterLimitOffset, _kFakeHostEndian);
  }
  set strokeMiterLimit(double value) {
    assert(value != null);
    final double encoded = value - _kStrokeMiterLimitDefault;
    _data.setFloat32(_kStrokeMiterLimitOffset, encoded, _kFakeHostEndian);
  }

  /// A mask filter (for example, a blur) to apply to a shape after it has been
  /// drawn but before it has been composited into the image.
  ///
  /// See [MaskFilter] for details.
  MaskFilter? get maskFilter {
    switch (_data.getInt32(_kMaskFilterOffset, _kFakeHostEndian)) {
      case MaskFilter._TypeNone:
        return null;
      case MaskFilter._TypeBlur:
        return MaskFilter.blur(
          BlurStyle.values[_data.getInt32(_kMaskFilterBlurStyleOffset, _kFakeHostEndian)],
          _data.getFloat32(_kMaskFilterSigmaOffset, _kFakeHostEndian),
        );
    }
    return null;
  }
  set maskFilter(MaskFilter? value) {
    if (value == null) {
      _data.setInt32(_kMaskFilterOffset, MaskFilter._TypeNone, _kFakeHostEndian);
      _data.setInt32(_kMaskFilterBlurStyleOffset, 0, _kFakeHostEndian);
      _data.setFloat32(_kMaskFilterSigmaOffset, 0.0, _kFakeHostEndian);
    } else {
      // For now we only support one kind of MaskFilter, so we don't need to
      // check what the type is if it's not null.
      _data.setInt32(_kMaskFilterOffset, MaskFilter._TypeBlur, _kFakeHostEndian);
      _data.setInt32(_kMaskFilterBlurStyleOffset, value._style.index, _kFakeHostEndian);
      _data.setFloat32(_kMaskFilterSigmaOffset, value._sigma, _kFakeHostEndian);
    }
  }

  /// Controls the performance vs quality trade-off to use when sampling bitmaps,
  /// as with an [ImageShader], or when drawing images, as with [Canvas.drawImage],
  /// [Canvas.drawImageRect], [Canvas.drawImageNine] or [Canvas.drawAtlas].
  ///
  /// Defaults to [FilterQuality.none].
  // TODO(ianh): verify that the image drawing methods actually respect this
  FilterQuality get filterQuality {
    return FilterQuality.values[_data.getInt32(_kFilterQualityOffset, _kFakeHostEndian)];
  }
  set filterQuality(FilterQuality value) {
    assert(value != null);
    final int encoded = value.index;
    _data.setInt32(_kFilterQualityOffset, encoded, _kFakeHostEndian);
  }

  /// The shader to use when stroking or filling a shape.
  ///
  /// When this is null, the [color] is used instead.
  ///
  /// See also:
  ///
  ///  * [Gradient], a shader that paints a color gradient.
  ///  * [ImageShader], a shader that tiles an [Image].
  ///  * [colorFilter], which overrides [shader].
  ///  * [color], which is used if [shader] and [colorFilter] are null.
  Shader? get shader {
    return _objects?[_kShaderIndex] as Shader?;
  }
  set shader(Shader? value) {
    _ensureObjectsInitialized()[_kShaderIndex] = value;
  }

  /// A color filter to apply when a shape is drawn or when a layer is
  /// composited.
  ///
  /// See [ColorFilter] for details.
  ///
  /// When a shape is being drawn, [colorFilter] overrides [color] and [shader].
  ColorFilter? get colorFilter {
    final _ColorFilter? nativeFilter = _objects?[_kColorFilterIndex] as _ColorFilter?;
    return nativeFilter?.creator;
  }

  set colorFilter(ColorFilter? value) {
    final _ColorFilter? nativeFilter = value?._toNativeColorFilter();
    if (nativeFilter == null) {
      if (_objects != null) {
        _objects![_kColorFilterIndex] = null;
      }
    } else {
      _ensureObjectsInitialized()[_kColorFilterIndex] = nativeFilter;
    }
  }

  /// The [ImageFilter] to use when drawing raster images.
  ///
  /// For example, to blur an image using [Canvas.drawImage], apply an
  /// [ImageFilter.blur]:
  ///
  /// ```dart
  /// import 'dart:ui' as ui;
  ///
  /// ui.Image image;
  ///
  /// void paint(Canvas canvas, Size size) {
  ///   canvas.drawImage(
  ///     image,
  ///     Offset.zero,
  ///     Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: .5, sigmaY: .5),
  ///   );
  /// }
  /// ```
  ///
  /// See also:
  ///
  ///  * [MaskFilter], which is used for drawing geometry.
  ImageFilter? get imageFilter {
    final _ImageFilter? nativeFilter = _objects?[_kImageFilterIndex] as _ImageFilter?;
    return nativeFilter?.creator;
  }

  set imageFilter(ImageFilter? value) {
    if (value == null) {
      if (_objects != null) {
        _objects![_kImageFilterIndex] = null;
      }
    } else {
      final List<Object?> objects = _ensureObjectsInitialized();
      final _ImageFilter? imageFilter = objects[_kImageFilterIndex] as _ImageFilter?;
      if (imageFilter?.creator != value) {
        objects[_kImageFilterIndex] = value._toNativeImageFilter();
      }
    }
  }

  /// Whether the colors of the image are inverted when drawn.
  ///
  /// Inverting the colors of an image applies a new color filter that will
  /// be composed with any user provided color filters. This is primarily
  /// used for implementing smart invert on iOS.
  bool get invertColors {
    return _data.getInt32(_kInvertColorOffset, _kFakeHostEndian) == 1;
  }
  set invertColors(bool value) {
    _data.setInt32(_kInvertColorOffset, value ? 1 : 0, _kFakeHostEndian);
  }

  bool get _dither {
    return _data.getInt32(_kDitherOffset, _kFakeHostEndian) == 1;
  }
  set _dither(bool value) {
    _data.setInt32(_kDitherOffset, value ? 1 : 0, _kFakeHostEndian);
  }

  /// Whether to dither the output when drawing images.
  ///
  /// If false, the default value, dithering will be enabled when the input
  /// color depth is higher than the output color depth. For example,
  /// drawing an RGB8 image onto an RGB565 canvas.
  ///
  /// This value also controls dithering of [shader]s, which can make
  /// gradients appear smoother.
  ///
  /// Whether or not dithering affects the output is implementation defined.
  /// Some implementations may choose to ignore this completely, if they're
  /// unable to control dithering.
  ///
  /// To ensure that dithering is consistently enabled for your entire
  /// application, set this to true before invoking any drawing related code.
  static bool enableDithering = false;

  @override
  String toString() {
    if (const bool.fromEnvironment('dart.vm.product', defaultValue: false)) {
      return super.toString();
    }
    final StringBuffer result = StringBuffer();
    String semicolon = '';
    result.write('Paint(');
    if (style == PaintingStyle.stroke) {
      result.write('$style');
      if (strokeWidth != 0.0)
        result.write(' ${strokeWidth.toStringAsFixed(1)}');
      else
        result.write(' hairline');
      if (strokeCap != StrokeCap.butt)
        result.write(' $strokeCap');
      if (strokeJoin == StrokeJoin.miter) {
        if (strokeMiterLimit != _kStrokeMiterLimitDefault)
          result.write(' $strokeJoin up to ${strokeMiterLimit.toStringAsFixed(1)}');
      } else {
        result.write(' $strokeJoin');
      }
      semicolon = '; ';
    }
    if (isAntiAlias != true) {
      result.write('${semicolon}antialias off');
      semicolon = '; ';
    }
    if (color != const Color(_kColorDefault)) {
      result.write('$semicolon$color');
      semicolon = '; ';
    }
    if (blendMode.index != _kBlendModeDefault) {
      result.write('$semicolon$blendMode');
      semicolon = '; ';
    }
    if (colorFilter != null) {
      result.write('${semicolon}colorFilter: $colorFilter');
      semicolon = '; ';
    }
    if (maskFilter != null) {
      result.write('${semicolon}maskFilter: $maskFilter');
      semicolon = '; ';
    }
    if (filterQuality != FilterQuality.none) {
      result.write('${semicolon}filterQuality: $filterQuality');
      semicolon = '; ';
    }
    if (shader != null) {
      result.write('${semicolon}shader: $shader');
      semicolon = '; ';
    }
    if (imageFilter != null) {
      result.write('${semicolon}imageFilter: $imageFilter');
      semicolon = '; ';
    }
    if (invertColors)
      result.write('${semicolon}invert: $invertColors');
    if (_dither)
      result.write('${semicolon}dither: $_dither');
    result.write(')');
    return result.toString();
  }
}

/// The format in which image bytes should be returned when using
/// [Image.toByteData].
// We do not expect to add more encoding formats to the ImageByteFormat enum,
// considering the binary size of the engine after LTO optimization. You can
// use the third-party pure dart image library to encode other formats.
// See: https://github.com/flutter/flutter/issues/16635 for more details.
enum ImageByteFormat {
  /// Raw RGBA format.
  ///
  /// Unencoded bytes, in RGBA row-primary form with premultiplied alpha, 8 bits per channel.
  rawRgba,

  /// Raw straight RGBA format.
  ///
  /// Unencoded bytes, in RGBA row-primary form with straight alpha, 8 bits per channel.
  rawStraightRgba,

  /// Raw unmodified format.
  ///
  /// Unencoded bytes, in the image's existing format. For example, a grayscale
  /// image may use a single 8-bit channel for each pixel.
  rawUnmodified,

  /// PNG format.
  ///
  /// A loss-less compression format for images. This format is well suited for
  /// images with hard edges, such as screenshots or sprites, and images with
  /// text. Transparency is supported. The PNG format supports images up to
  /// 2,147,483,647 pixels in either dimension, though in practice available
  /// memory provides a more immediate limitation on maximum image size.
  ///
  /// PNG images normally use the `.png` file extension and the `image/png` MIME
  /// type.
  ///
  /// See also:
  ///
  ///  * <https://en.wikipedia.org/wiki/Portable_Network_Graphics>, the Wikipedia page on PNG.
  ///  * <https://tools.ietf.org/rfc/rfc2083.txt>, the PNG standard.
  png,
}

/// The format of pixel data given to [decodeImageFromPixels].
enum PixelFormat {
  /// Each pixel is 32 bits, with the highest 8 bits encoding red, the next 8
  /// bits encoding green, the next 8 bits encoding blue, and the lowest 8 bits
  /// encoding alpha.
  rgba8888,

  /// Each pixel is 32 bits, with the highest 8 bits encoding blue, the next 8
  /// bits encoding green, the next 8 bits encoding red, and the lowest 8 bits
  /// encoding alpha.
  bgra8888,
}

/// Opaque handle to raw decoded image data (pixels).
///
/// To obtain an [Image] object, use the [ImageDescriptor] API.
///
/// To draw an [Image], use one of the methods on the [Canvas] class, such as
/// [Canvas.drawImage].
///
/// A class or method that receives an image object must call [dispose] on the
/// handle when it is no longer needed. To create a shareable reference to the
/// underlying image, call [clone]. The method or object that receives
/// the new instance will then be responsible for disposing it, and the
/// underlying image itself will be disposed when all outstanding handles are
/// disposed.
///
/// If `dart:ui` passes an `Image` object and the recipient wishes to share
/// that handle with other callers, [clone] must be called _before_ [dispose].
/// A handle that has been disposed cannot create new handles anymore.
///
/// See also:
///
///  * [Image](https://api.flutter.dev/flutter/widgets/Image-class.html), the class in the [widgets] library.
///  * [ImageDescriptor], which allows reading information about the image and
///    creating a codec to decode it.
///  * [instantiateImageCodec], a utility method that wraps [ImageDescriptor].
class Image {
  Image._(this._image) {
    assert(() {
      _debugStack = StackTrace.current;
      return true;
    }());
    _image._handles.add(this);
  }

  // C++ unit tests access this.
  @pragma('vm:entry-point')
  final _Image _image;

  StackTrace? _debugStack;

  /// The number of image pixels along the image's horizontal axis.
  int get width {
    assert(!_disposed && !_image._disposed);
    return _image.width;
  }

  /// The number of image pixels along the image's vertical axis.
  int get height {
    assert(!_disposed && !_image._disposed);
    return _image.height;
  }

  bool _disposed = false;
  /// Release this handle's claim on the underlying Image. This handle is no
  /// longer usable after this method is called.
  ///
  /// Once all outstanding handles have been disposed, the underlying image will
  /// be disposed as well.
  ///
  /// In debug mode, [debugGetOpenHandleStackTraces] will return a list of
  /// [StackTrace] objects from all open handles' creation points. This is
  /// useful when trying to determine what parts of the program are keeping an
  /// image resident in memory.
  void dispose() {
    assert(!_disposed && !_image._disposed);
    assert(_image._handles.contains(this));
    _disposed = true;
    final bool removed = _image._handles.remove(this);
    assert(removed);
    if (_image._handles.isEmpty) {
      _image.dispose();
    }
  }

  /// Whether this reference to the underlying image is [dispose]d.
  ///
  /// This only returns a valid value if asserts are enabled, and must not be
  /// used otherwise.
  bool get debugDisposed {
    bool? disposed;
    assert(() {
      disposed = _disposed;
      return true;
    }());
    return disposed ?? (throw StateError('Image.debugDisposed is only available when asserts are enabled.'));
  }

  /// Converts the [Image] object into a byte array.
  ///
  /// The [format] argument specifies the format in which the bytes will be
  /// returned.
  ///
  /// Returns a future that completes with the binary image data or an error
  /// if encoding fails.
  // We do not expect to add more encoding formats to the ImageByteFormat enum,
  // considering the binary size of the engine after LTO optimization. You can
  // use the third-party pure dart image library to encode other formats.
  // See: https://github.com/flutter/flutter/issues/16635 for more details.
  Future<ByteData?> toByteData({ImageByteFormat format = ImageByteFormat.rawRgba}) {
    assert(!_disposed && !_image._disposed);
    return _image.toByteData(format: format);
  }

  /// If asserts are enabled, returns the [StackTrace]s of each open handle from
  /// [clone], in creation order.
  ///
  /// If asserts are disabled, this method always returns null.
  List<StackTrace>? debugGetOpenHandleStackTraces() {
    List<StackTrace>? stacks;
    assert(() {
      stacks = _image._handles.map((Image handle) => handle._debugStack!).toList();
      return true;
    }());
    return stacks;
  }

  /// Creates a disposable handle to this image.
  ///
  /// Holders of an [Image] must dispose of the image when they no longer need
  /// to access it or draw it. However, once the underlying image is disposed,
  /// it is no longer possible to use it. If a holder of an image needs to share
  /// access to that image with another object or method, [clone] creates a
  /// duplicate handle. The underlying image will only be disposed once all
  /// outstanding handles are disposed. This allows for safe sharing of image
  /// references while still disposing of the underlying resources when all
  /// consumers are finished.
  ///
  /// It is safe to pass an [Image] handle to another object or method if the
  /// current holder no longer needs it.
  ///
  /// To check whether two [Image] references are referring to the same
  /// underlying image memory, use [isCloneOf] rather than the equality operator
  /// or [identical].
  ///
  /// The following example demonstrates valid usage.
  ///
  /// ```dart
  /// import 'dart:async';
  ///
  /// Future<Image> _loadImage(int width, int height) {
  ///   final Completer<Image> completer = Completer<Image>();
  ///   decodeImageFromPixels(
  ///     Uint8List.fromList(List<int>.filled(width * height * 4, 0xFF)),
  ///     width,
  ///     height,
  ///     PixelFormat.rgba8888,
  ///     // Don't worry about disposing or cloning this image - responsibility
  ///     // is transferred to the caller, and that is safe since this method
  ///     // will not touch it again.
  ///     (Image image) => completer.complete(image),
  ///   );
  ///   return completer.future;
  /// }
  ///
  /// Future<void> main() async {
  ///   final Image image = await _loadImage(5, 5);
  ///   // Make sure to clone the image, because MyHolder might dispose it
  ///   // and we need to access it again.
  ///   final MyImageHolder holder = MyImageHolder(image.clone());
  ///   final MyImageHolder holder2 = MyImageHolder(image.clone());
  ///   // Now we dispose it because we won't need it again.
  ///   image.dispose();
  ///
  ///   final PictureRecorder recorder = PictureRecorder();
  ///   final Canvas canvas = Canvas(recorder);
  ///
  ///   holder.draw(canvas);
  ///   holder.dispose();
  ///
  ///   canvas.translate(50, 50);
  ///   holder2.draw(canvas);
  ///   holder2.dispose();
  /// }
  ///
  /// class MyImageHolder {
  ///   MyImageLoader(this.image);
  ///
  ///   final Image image;
  ///
  ///   void draw(Canvas canvas) {
  ///     canvas.drawImage(image, Offset.zero, Paint());
  ///   }
  ///
  ///   void dispose() => image.dispose();
  /// }
  /// ```
  ///
  /// The returned object behaves identically to this image. Calling
  /// [dispose] on it will only dispose the underlying native resources if it
  /// is the last remaining handle.
  Image clone() {
    if (_disposed) {
      throw StateError(
        'Cannot clone a disposed image.\n'
        'The clone() method of a previously-disposed Image was called. Once an '
        'Image object has been disposed, it can no longer be used to create '
        'handles, as the underlying data may have been released.'
      );
    }
    assert(!_image._disposed);
    return Image._(_image);
  }

  /// Returns true if `other` is a [clone] of this and thus shares the same
  /// underlying image memory, even if this or `other` is [dispose]d.
  ///
  /// This method may return false for two images that were decoded from the
  /// same underlying asset, if they are not sharing the same memory. For
  /// example, if the same file is decoded using [instantiateImageCodec] twice,
  /// or the same bytes are decoded using [decodeImageFromPixels] twice, there
  /// will be two distinct [Image]s that render the same but do not share
  /// underlying memory, and so will not be treated as clones of each other.
  bool isCloneOf(Image other) => other._image == _image;

  @override
  String toString() => _image.toString();
}

@pragma('vm:entry-point')
class _Image extends NativeFieldWrapperClass1 {
  // This class is created by the engine, and should not be instantiated
  // or extended directly.
  //
  // _Images are always handed out wrapped in [Image]s. To create an [Image],
  // use the ImageDescriptor API.
  @pragma('vm:entry-point')
  _Image._();

  int get width native 'Image_width';

  int get height native 'Image_height';

  Future<ByteData?> toByteData({ImageByteFormat format = ImageByteFormat.rawRgba}) {
    return _futurize((_Callback<ByteData> callback) {
      return _toByteData(format.index, (Uint8List? encoded) {
        callback(encoded!.buffer.asByteData());
      });
    });
  }

  /// Returns an error message on failure, null on success.
  String? _toByteData(int format, _Callback<Uint8List?> callback) native 'Image_toByteData';

  bool _disposed = false;
  void dispose() {
    assert(!_disposed);
    assert(
      _handles.isEmpty,
      'Attempted to dispose of an Image object that has ${_handles.length} '
      'open handles.\n'
      'If you see this, it is a bug in dart:ui. Please file an issue at '
      'https://github.com/flutter/flutter/issues/new.',
    );
    _disposed = true;
    _dispose();
  }

  void _dispose() native 'Image_dispose';

  Set<Image> _handles = <Image>{};

  @override
  String toString() => '[$width\u00D7$height]';
}

/// Callback signature for [decodeImageFromList].
typedef ImageDecoderCallback = void Function(Image result);

/// Information for a single frame of an animation.
///
/// To obtain an instance of the [FrameInfo] interface, see
/// [Codec.getNextFrame].
///
/// The recipient of an instance of this class is responsible for calling
/// [Image.dispose] on [image]. To share the image with other interested
/// parties, use [Image.clone]. If the [FrameInfo] object itself is passed to
/// another method or object, that method or object must assume it is
/// responsible for disposing the image when done, and the passer must not
/// access the [image] after that point.
///
/// For example, the following code sample is incorrect:
///
/// ```dart
/// /// BAD
/// Future<void> nextFrameRoutine(Codec codec) async {
///   final FrameInfo frameInfo = await codec.getNextFrame();
///   _cacheImage(frameInfo);
///   // ERROR - _cacheImage is now responsible for disposing the image, and
///   // the image may not be available any more for this drawing routine.
///   _drawImage(frameInfo);
///   // ERROR again - the previous methods might or might not have created
///   // handles to the image.
///   frameInfo.image.dispose();
/// }
/// ```
///
/// Correct usage is:
///
/// ```dart
/// /// GOOD
/// Future<void> nextFrameRoutine(Codec codec) async {
///   final FrameInfo frameInfo = await codec.getNextFrame();
///   _cacheImage(frameInfo.image.clone(), frameInfo.duration);
///   _drawImage(frameInfo.image.clone(), frameInfo.duration);
///   // This method is done with its handle, and has passed handles to its
///   // clients already.
///   // The image will live until those clients dispose of their handles, and
///   // this one must not be disposed since it will not be used again.
///   frameInfo.image.dispose();
/// }
/// ```
class FrameInfo {
  /// This class is created by the engine, and should not be instantiated
  /// or extended directly.
  ///
  /// To obtain an instance of the [FrameInfo] interface, see
  /// [Codec.getNextFrame].
  FrameInfo._({required this.duration, required this.image});

  /// The duration this frame should be shown.
  ///
  /// A zero duration indicates that the frame should be shown indefinitely.
  final Duration duration;


  /// The [Image] object for this frame.
  ///
  /// This object must be disposed by the recipient of this frame info.
  ///
  /// To share this image with other interested parties, use [Image.clone].
  final Image image;
}

/// A handle to an image codec.
///
/// This class is created by the engine, and should not be instantiated
/// or extended directly.
///
/// To obtain an instance of the [Codec] interface, see
/// [instantiateImageCodec].
@pragma('vm:entry-point')
class Codec extends NativeFieldWrapperClass1 {
  //
  // This class is created by the engine, and should not be instantiated
  // or extended directly.
  //
  // To obtain an instance of the [Codec] interface, see
  // [instantiateImageCodec].
  @pragma('vm:entry-point')
  Codec._();

  int? _cachedFrameCount;
  /// Number of frames in this image.
  int get frameCount => _cachedFrameCount ??= _frameCount;
  int get _frameCount native 'Codec_frameCount';

  int? _cachedRepetitionCount;
  /// Number of times to repeat the animation.
  ///
  /// * 0 when the animation should be played once.
  /// * -1 for infinity repetitions.
  int get repetitionCount => _cachedRepetitionCount ??= _repetitionCount;
  int get _repetitionCount native 'Codec_repetitionCount';

  /// Fetches the next animation frame.
  ///
  /// Wraps back to the first frame after returning the last frame.
  ///
  /// The returned future can complete with an error if the decoding has failed.
  ///
  /// The caller of this method is responsible for disposing the
  /// [FrameInfo.image] on the returned object.
  Future<FrameInfo> getNextFrame() async {
    final Completer<FrameInfo> completer = Completer<FrameInfo>.sync();
    final String? error = _getNextFrame((_Image? image, int durationMilliseconds) {
      if (image == null) {
        completer.completeError(Exception('Codec failed to produce an image, possibly due to invalid image data.'));
      } else {
        completer.complete(FrameInfo._(
          image: Image._(image),
          duration: Duration(milliseconds: durationMilliseconds),
        ));
      }
    });
    if (error != null) {
      throw Exception(error);
    }
    return completer.future;
  }

  /// Returns an error message on failure, null on success.
  String? _getNextFrame(void Function(_Image?, int) callback) native 'Codec_getNextFrame';

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  void dispose() native 'Codec_dispose';
}

/// Instantiates an image [Codec].
///
/// This method is a convenience wrapper around the [ImageDescriptor] API, and
/// using [ImageDescriptor] directly is preferred since it allows the caller to
/// make better determinations about how and whether to use the `targetWidth`
/// and `targetHeight` parameters.
///
/// The `list` parameter is the binary image data (e.g a PNG or GIF binary data).
/// The data can be for either static or animated images. The following image
/// formats are supported: {@macro dart.ui.imageFormats}
///
/// The `targetWidth` and `targetHeight` arguments specify the size of the
/// output image, in image pixels. If they are not equal to the intrinsic
/// dimensions of the image, then the image will be scaled after being decoded.
/// If the `allowUpscaling` parameter is not set to true, both dimensions will
/// be capped at the intrinsic dimensions of the image, even if only one of
/// them would have exceeded those intrinsic dimensions. If exactly one of these
/// two arguments is specified, then the aspect ratio will be maintained while
/// forcing the image to match the other given dimension. If neither is
/// specified, then the image maintains its intrinsic size.
///
/// Scaling the image to larger than its intrinsic size should usually be
/// avoided, since it causes the image to use more memory than necessary.
/// Instead, prefer scaling the [Canvas] transform. If the image must be scaled
/// up, the `allowUpscaling` parameter must be set to true.
///
/// The returned future can complete with an error if the image decoding has
/// failed.
Future<Codec> instantiateImageCodec(
  Uint8List list, {
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) async {
  final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(list);
  return instantiateImageCodecFromBuffer(
    buffer,
    targetWidth: targetWidth,
    targetHeight: targetHeight,
    allowUpscaling: allowUpscaling,
  );
}

/// Instantiates an image [Codec].
///
/// This method is a convenience wrapper around the [ImageDescriptor] API, and
/// using [ImageDescriptor] directly is preferred since it allows the caller to
/// make better determinations about how and whether to use the `targetWidth`
/// and `targetHeight` parameters.
///
/// The [buffer] parameter is the binary image data (e.g a PNG or GIF binary data).
/// The data can be for either static or animated images. The following image
/// formats are supported: {@macro dart.ui.imageFormats}
///
/// The [targetWidth] and [targetHeight] arguments specify the size of the
/// output image, in image pixels. If they are not equal to the intrinsic
/// dimensions of the image, then the image will be scaled after being decoded.
/// If the `allowUpscaling` parameter is not set to true, both dimensions will
/// be capped at the intrinsic dimensions of the image, even if only one of
/// them would have exceeded those intrinsic dimensions. If exactly one of these
/// two arguments is specified, then the aspect ratio will be maintained while
/// forcing the image to match the other given dimension. If neither is
/// specified, then the image maintains its intrinsic size.
///
/// Scaling the image to larger than its intrinsic size should usually be
/// avoided, since it causes the image to use more memory than necessary.
/// Instead, prefer scaling the [Canvas] transform. If the image must be scaled
/// up, the `allowUpscaling` parameter must be set to true.
///
/// The returned future can complete with an error if the image decoding has
/// failed.
Future<Codec> instantiateImageCodecFromBuffer(
  ImmutableBuffer buffer, {
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) async {
  final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
  if (!allowUpscaling) {
    if (targetWidth != null && targetWidth > descriptor.width) {
      targetWidth = descriptor.width;
    }
    if (targetHeight != null && targetHeight > descriptor.height) {
      targetHeight = descriptor.height;
    }
  }
  buffer.dispose();
  return descriptor.instantiateCodec(
    targetWidth: targetWidth,
    targetHeight: targetHeight,
  );
}

/// Loads a single image frame from a byte array into an [Image] object.
///
/// This is a convenience wrapper around [instantiateImageCodec]. Prefer using
/// [instantiateImageCodec] which also supports multi frame images and offers
/// better error handling. This function swallows asynchronous errors.
void decodeImageFromList(Uint8List list, ImageDecoderCallback callback) {
  _decodeImageFromListAsync(list, callback);
}

Future<void> _decodeImageFromListAsync(Uint8List list,
                                       ImageDecoderCallback callback) async {
  final Codec codec = await instantiateImageCodec(list);
  final FrameInfo frameInfo = await codec.getNextFrame();
  callback(frameInfo.image);
}

/// Convert an array of pixel values into an [Image] object.
///
/// The `pixels` parameter is the pixel data. They are packed in bytes in the
/// order described by `format`, then grouped in rows, from left to right,
/// then top to bottom.
///
/// The `rowBytes` parameter is the number of bytes consumed by each row of
/// pixels in the data buffer. If unspecified, it defaults to `width` multiplied
/// by the number of bytes per pixel in the provided `format`.
///
/// The `targetWidth` and `targetHeight` arguments specify the size of the
/// output image, in image pixels. If they are not equal to the intrinsic
/// dimensions of the image, then the image will be scaled after being decoded.
/// If the `allowUpscaling` parameter is not set to true, both dimensions will
/// be capped at the intrinsic dimensions of the image, even if only one of
/// them would have exceeded those intrinsic dimensions. If exactly one of these
/// two arguments is specified, then the aspect ratio will be maintained while
/// forcing the image to match the other given dimension. If neither is
/// specified, then the image maintains its intrinsic size.
///
/// Scaling the image to larger than its intrinsic size should usually be
/// avoided, since it causes the image to use more memory than necessary.
/// Instead, prefer scaling the [Canvas] transform. If the image must be scaled
/// up, the `allowUpscaling` parameter must be set to true.
void decodeImageFromPixels(
  Uint8List pixels,
  int width,
  int height,
  PixelFormat format,
  ImageDecoderCallback callback, {
  int? rowBytes,
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) {
  if (targetWidth != null) {
    assert(allowUpscaling || targetWidth <= width);
  }
  if (targetHeight != null) {
    assert(allowUpscaling || targetHeight <= height);
  }

  ImmutableBuffer.fromUint8List(pixels)
    .then((ImmutableBuffer buffer) {
      final ImageDescriptor descriptor = ImageDescriptor.raw(
        buffer,
        width: width,
        height: height,
        rowBytes: rowBytes,
        pixelFormat: format,
      );

      if (!allowUpscaling) {
        if (targetWidth != null && targetWidth! > descriptor.width) {
          targetWidth = descriptor.width;
        }
        if (targetHeight != null && targetHeight! > descriptor.height) {
          targetHeight = descriptor.height;
        }
      }

      descriptor
        .instantiateCodec(
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        )
        .then((Codec codec) {
          final Future<FrameInfo> frameInfo = codec.getNextFrame();
          codec.dispose();
          return frameInfo;
        })
        .then((FrameInfo frameInfo) {
          buffer.dispose();
          descriptor.dispose();

          return callback(frameInfo.image);
        });
  });
}

/// Determines the winding rule that decides how the interior of a [Path] is
/// calculated.
///
/// This enum is used by the [Path.fillType] property.
enum PathFillType {
  /// The interior is defined by a non-zero sum of signed edge crossings.
  ///
  /// For a given point, the point is considered to be on the inside of the path
  /// if a line drawn from the point to infinity crosses lines going clockwise
  /// around the point a different number of times than it crosses lines going
  /// counter-clockwise around that point.
  ///
  /// See: <https://en.wikipedia.org/wiki/Nonzero-rule>
  nonZero,

  /// The interior is defined by an odd number of edge crossings.
  ///
  /// For a given point, the point is considered to be on the inside of the path
  /// if a line drawn from the point to infinity crosses an odd number of lines.
  ///
  /// See: <https://en.wikipedia.org/wiki/Even-odd_rule>
  evenOdd,
}

/// Strategies for combining paths.
///
/// See also:
///
/// * [Path.combine], which uses this enum to decide how to combine two paths.
// Must be kept in sync with SkPathOp
enum PathOperation {
  /// Subtract the second path from the first path.
  ///
  /// For example, if the two paths are overlapping circles of equal diameter
  /// but differing centers, the result would be a crescent portion of the
  /// first circle that was not overlapped by the second circle.
  ///
  /// See also:
  ///
  ///  * [reverseDifference], which is the same but subtracting the first path
  ///    from the second.
  difference,
  /// Create a new path that is the intersection of the two paths, leaving the
  /// overlapping pieces of the path.
  ///
  /// For example, if the two paths are overlapping circles of equal diameter
  /// but differing centers, the result would be only the overlapping portion
  /// of the two circles.
  ///
  /// See also:
  ///  * [xor], which is the inverse of this operation
  intersect,
  /// Create a new path that is the union (inclusive-or) of the two paths.
  ///
  /// For example, if the two paths are overlapping circles of equal diameter
  /// but differing centers, the result would be a figure-eight like shape
  /// matching the outer boundaries of both circles.
  union,
  /// Create a new path that is the exclusive-or of the two paths, leaving
  /// everything but the overlapping pieces of the path.
  ///
  /// For example, if the two paths are overlapping circles of equal diameter
  /// but differing centers, the figure-eight like shape less the overlapping parts
  ///
  /// See also:
  ///  * [intersect], which is the inverse of this operation
  xor,
  /// Subtract the first path from the second path.
  ///
  /// For example, if the two paths are overlapping circles of equal diameter
  /// but differing centers, the result would be a crescent portion of the
  /// second circle that was not overlapped by the first circle.
  ///
  /// See also:
  ///
  ///  * [difference], which is the same but subtracting the second path
  ///    from the first.
  reverseDifference,
}

/// A handle for the framework to hold and retain an engine layer across frames.
@pragma('vm:entry-point')
class EngineLayer extends NativeFieldWrapperClass1 {
  /// This class is created by the engine, and should not be instantiated
  /// or extended directly.
  @pragma('vm:entry-point')
  EngineLayer._();

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  ///
  /// EngineLayers indirectly retain platform specific graphics resources. Some
  /// of these resources, such as images, may be memory intensive. It is
  /// important to dispose of EngineLayer objects that will no longer be used as
  /// soon as possible to avoid retaining these resources until the next
  /// garbage collection.
  ///
  /// Once this EngineLayer is disposed, it is no longer eligible for use as a
  /// retained layer, and must not be passed as an `oldLayer` to any of the
  /// [SceneBuilder] methods which accept that parameter.
  void dispose() native 'EngineLayer_dispose';
}

/// A complex, one-dimensional subset of a plane.
///
/// A path consists of a number of sub-paths, and a _current point_.
///
/// Sub-paths consist of segments of various types, such as lines,
/// arcs, or beziers. Sub-paths can be open or closed, and can
/// self-intersect.
///
/// Closed sub-paths enclose a (possibly discontiguous) region of the
/// plane based on the current [fillType].
///
/// The _current point_ is initially at the origin. After each
/// operation adding a segment to a sub-path, the current point is
/// updated to the end of that segment.
///
/// Paths can be drawn on canvases using [Canvas.drawPath], and can
/// used to create clip regions using [Canvas.clipPath].
@pragma('vm:entry-point')
class Path extends NativeFieldWrapperClass1 {
  /// Create a new empty [Path] object.
  @pragma('vm:entry-point')
  Path() { _constructor(); }
  void _constructor() native 'Path_constructor';

  /// Avoids creating a new native backing for the path for methods that will
  /// create it later, such as [Path.from], [shift] and [transform].
  Path._();

  /// Creates a copy of another [Path].
  ///
  /// This copy is fast and does not require additional memory unless either
  /// the `source` path or the path returned by this constructor are modified.
  factory Path.from(Path source) {
    final Path clonedPath = Path._();
    source._clone(clonedPath);
    return clonedPath;
  }
  void _clone(Path outPath) native 'Path_clone';

  /// Determines how the interior of this path is calculated.
  ///
  /// Defaults to the non-zero winding rule, [PathFillType.nonZero].
  PathFillType get fillType => PathFillType.values[_getFillType()];
  set fillType(PathFillType value) => _setFillType(value.index);

  int _getFillType() native 'Path_getFillType';
  void _setFillType(int fillType) native 'Path_setFillType';

  /// Starts a new sub-path at the given coordinate.
  void moveTo(double x, double y) native 'Path_moveTo';

  /// Starts a new sub-path at the given offset from the current point.
  void relativeMoveTo(double dx, double dy) native 'Path_relativeMoveTo';

  /// Adds a straight line segment from the current point to the given
  /// point.
  void lineTo(double x, double y) native 'Path_lineTo';

  /// Adds a straight line segment from the current point to the point
  /// at the given offset from the current point.
  void relativeLineTo(double dx, double dy) native 'Path_relativeLineTo';

  /// Adds a quadratic bezier segment that curves from the current
  /// point to the given point (x2,y2), using the control point
  /// (x1,y1).
  void quadraticBezierTo(double x1, double y1, double x2, double y2) native 'Path_quadraticBezierTo';

  /// Adds a quadratic bezier segment that curves from the current
  /// point to the point at the offset (x2,y2) from the current point,
  /// using the control point at the offset (x1,y1) from the current
  /// point.
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) native 'Path_relativeQuadraticBezierTo';

  /// Adds a cubic bezier segment that curves from the current point
  /// to the given point (x3,y3), using the control points (x1,y1) and
  /// (x2,y2).
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) native 'Path_cubicTo';

  /// Adds a cubic bezier segment that curves from the current point
  /// to the point at the offset (x3,y3) from the current point, using
  /// the control points at the offsets (x1,y1) and (x2,y2) from the
  /// current point.
  void relativeCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) native 'Path_relativeCubicTo';

  /// Adds a bezier segment that curves from the current point to the
  /// given point (x2,y2), using the control points (x1,y1) and the
  /// weight w. If the weight is greater than 1, then the curve is a
  /// hyperbola; if the weight equals 1, it's a parabola; and if it is
  /// less than 1, it is an ellipse.
  void conicTo(double x1, double y1, double x2, double y2, double w) native 'Path_conicTo';

  /// Adds a bezier segment that curves from the current point to the
  /// point at the offset (x2,y2) from the current point, using the
  /// control point at the offset (x1,y1) from the current point and
  /// the weight w. If the weight is greater than 1, then the curve is
  /// a hyperbola; if the weight equals 1, it's a parabola; and if it
  /// is less than 1, it is an ellipse.
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) native 'Path_relativeConicTo';

  /// If the `forceMoveTo` argument is false, adds a straight line
  /// segment and an arc segment.
  ///
  /// If the `forceMoveTo` argument is true, starts a new sub-path
  /// consisting of an arc segment.
  ///
  /// In either case, the arc segment consists of the arc that follows
  /// the edge of the oval bounded by the given rectangle, from
  /// startAngle radians around the oval up to startAngle + sweepAngle
  /// radians around the oval, with zero radians being the point on
  /// the right hand side of the oval that crosses the horizontal line
  /// that intersects the center of the rectangle and with positive
  /// angles going clockwise around the oval.
  ///
  /// The line segment added if `forceMoveTo` is false starts at the
  /// current point and ends at the start of the arc.
  void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    assert(_rectIsValid(rect));
    _arcTo(rect.left, rect.top, rect.right, rect.bottom, startAngle, sweepAngle, forceMoveTo);
  }
  void _arcTo(double left, double top, double right, double bottom,
              double startAngle, double sweepAngle, bool forceMoveTo) native 'Path_arcTo';

  /// Appends up to four conic curves weighted to describe an oval of `radius`
  /// and rotated by `rotation` (measured in degrees and clockwise).
  ///
  /// The first curve begins from the last point in the path and the last ends
  /// at `arcEnd`. The curves follow a path in a direction determined by
  /// `clockwise` and `largeArc` in such a way that the sweep angle
  /// is always less than 360 degrees.
  ///
  /// A simple line is appended if either either radii are zero or the last
  /// point in the path is `arcEnd`. The radii are scaled to fit the last path
  /// point if both are greater than zero but too small to describe an arc.
  ///
  void arcToPoint(Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    assert(_offsetIsValid(arcEnd));
    assert(_radiusIsValid(radius));
    _arcToPoint(arcEnd.dx, arcEnd.dy, radius.x, radius.y, rotation,
                largeArc, clockwise);
  }
  void _arcToPoint(double arcEndX, double arcEndY, double radiusX,
                   double radiusY, double rotation, bool largeArc,
                   bool clockwise) native 'Path_arcToPoint';


  /// Appends up to four conic curves weighted to describe an oval of `radius`
  /// and rotated by `rotation` (measured in degrees and clockwise).
  ///
  /// The last path point is described by (px, py).
  ///
  /// The first curve begins from the last point in the path and the last ends
  /// at `arcEndDelta.dx + px` and `arcEndDelta.dy + py`. The curves follow a
  /// path in a direction determined by `clockwise` and `largeArc`
  /// in such a way that the sweep angle is always less than 360 degrees.
  ///
  /// A simple line is appended if either either radii are zero, or, both
  /// `arcEndDelta.dx` and `arcEndDelta.dy` are zero. The radii are scaled to
  /// fit the last path point if both are greater than zero but too small to
  /// describe an arc.
  void relativeArcToPoint(Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    assert(_offsetIsValid(arcEndDelta));
    assert(_radiusIsValid(radius));
    _relativeArcToPoint(arcEndDelta.dx, arcEndDelta.dy, radius.x, radius.y,
                        rotation, largeArc, clockwise);
  }
  void _relativeArcToPoint(double arcEndX, double arcEndY, double radiusX,
                           double radiusY, double rotation,
                           bool largeArc, bool clockwise)
                           native 'Path_relativeArcToPoint';

  /// Adds a new sub-path that consists of four lines that outline the
  /// given rectangle.
  void addRect(Rect rect) {
    assert(_rectIsValid(rect));
    _addRect(rect.left, rect.top, rect.right, rect.bottom);
  }
  void _addRect(double left, double top, double right, double bottom) native 'Path_addRect';

  /// Adds a new sub-path that consists of a curve that forms the
  /// ellipse that fills the given rectangle.
  ///
  /// To add a circle, pass an appropriate rectangle as `oval`. [Rect.fromCircle]
  /// can be used to easily describe the circle's center [Offset] and radius.
  void addOval(Rect oval) {
    assert(_rectIsValid(oval));
    _addOval(oval.left, oval.top, oval.right, oval.bottom);
  }
  void _addOval(double left, double top, double right, double bottom) native 'Path_addOval';

  /// Adds a new sub-path with one arc segment that consists of the arc
  /// that follows the edge of the oval bounded by the given
  /// rectangle, from startAngle radians around the oval up to
  /// startAngle + sweepAngle radians around the oval, with zero
  /// radians being the point on the right hand side of the oval that
  /// crosses the horizontal line that intersects the center of the
  /// rectangle and with positive angles going clockwise around the
  /// oval.
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    assert(_rectIsValid(oval));
    _addArc(oval.left, oval.top, oval.right, oval.bottom, startAngle, sweepAngle);
  }
  void _addArc(double left, double top, double right, double bottom,
               double startAngle, double sweepAngle) native 'Path_addArc';

  /// Adds a new sub-path with a sequence of line segments that connect the given
  /// points.
  ///
  /// If `close` is true, a final line segment will be added that connects the
  /// last point to the first point.
  ///
  /// The `points` argument is interpreted as offsets from the origin.
  void addPolygon(List<Offset> points, bool close) {
    assert(points != null);
    _addPolygon(_encodePointList(points), close);
  }
  void _addPolygon(Float32List points, bool close) native 'Path_addPolygon';

  /// Adds a new sub-path that consists of the straight lines and
  /// curves needed to form the rounded rectangle described by the
  /// argument.
  void addRRect(RRect rrect) {
    assert(_rrectIsValid(rrect));
    _addRRect(rrect._getValue32());
  }
  void _addRRect(Float32List rrect) native 'Path_addRRect';

  /// Adds the sub-paths of `path`, offset by `offset`, to this path.
  ///
  /// If `matrix4` is specified, the path will be transformed by this matrix
  /// after the matrix is translated by the given offset. The matrix is a 4x4
  /// matrix stored in column major order.
  void addPath(Path path, Offset offset, {Float64List? matrix4}) {
    assert(path != null); // path is checked on the engine side
    assert(_offsetIsValid(offset));
    if (matrix4 != null) {
      assert(_matrix4IsValid(matrix4));
      _addPathWithMatrix(path, offset.dx, offset.dy, matrix4);
    } else {
      _addPath(path, offset.dx, offset.dy);
    }
  }
  void _addPath(Path path, double dx, double dy) native 'Path_addPath';
  void _addPathWithMatrix(Path path, double dx, double dy, Float64List matrix) native 'Path_addPathWithMatrix';

  /// Adds the sub-paths of `path`, offset by `offset`, to this path.
  /// The current sub-path is extended with the first sub-path
  /// of `path`, connecting them with a lineTo if necessary.
  ///
  /// If `matrix4` is specified, the path will be transformed by this matrix
  /// after the matrix is translated by the given `offset`.  The matrix is a 4x4
  /// matrix stored in column major order.
  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) {
    assert(path != null); // path is checked on the engine side
    assert(_offsetIsValid(offset));
    if (matrix4 != null) {
      assert(_matrix4IsValid(matrix4));
      _extendWithPathAndMatrix(path, offset.dx, offset.dy, matrix4);
    } else {
      _extendWithPath(path, offset.dx, offset.dy);
    }
  }
  void _extendWithPath(Path path, double dx, double dy) native 'Path_extendWithPath';
  void _extendWithPathAndMatrix(Path path, double dx, double dy, Float64List matrix) native 'Path_extendWithPathAndMatrix';

  /// Closes the last sub-path, as if a straight line had been drawn
  /// from the current point to the first point of the sub-path.
  void close() native 'Path_close';

  /// Clears the [Path] object of all sub-paths, returning it to the
  /// same state it had when it was created. The _current point_ is
  /// reset to the origin.
  void reset() native 'Path_reset';

  /// Tests to see if the given point is within the path. (That is, whether the
  /// point would be in the visible portion of the path if the path was used
  /// with [Canvas.clipPath].)
  ///
  /// The `point` argument is interpreted as an offset from the origin.
  ///
  /// Returns true if the point is in the path, and false otherwise.
  bool contains(Offset point) {
    assert(_offsetIsValid(point));
    return _contains(point.dx, point.dy);
  }
  bool _contains(double x, double y) native 'Path_contains';

  /// Returns a copy of the path with all the segments of every
  /// sub-path translated by the given offset.
  Path shift(Offset offset) {
    assert(_offsetIsValid(offset));
    final Path path = Path._();
    _shift(path, offset.dx, offset.dy);
    return path;
  }
  void _shift(Path outPath, double dx, double dy) native 'Path_shift';

  /// Returns a copy of the path with all the segments of every
  /// sub-path transformed by the given matrix.
  Path transform(Float64List matrix4) {
    assert(_matrix4IsValid(matrix4));
    final Path path = Path._();
    _transform(path, matrix4);
    return path;
  }
  void _transform(Path outPath, Float64List matrix4) native 'Path_transform';

  /// Computes the bounding rectangle for this path.
  ///
  /// A path containing only axis-aligned points on the same straight line will
  /// have no area, and therefore `Rect.isEmpty` will return true for such a
  /// path. Consider checking `rect.width + rect.height > 0.0` instead, or
  /// using the [computeMetrics] API to check the path length.
  ///
  /// For many more elaborate paths, the bounds may be inaccurate.  For example,
  /// when a path contains a circle, the points used to compute the bounds are
  /// the circle's implied control points, which form a square around the circle;
  /// if the circle has a transformation applied using [transform] then that
  /// square is rotated, and the (axis-aligned, non-rotated) bounding box
  /// therefore ends up grossly overestimating the actual area covered by the
  /// circle.
  // see https://skia.org/user/api/SkPath_Reference#SkPath_getBounds
  Rect getBounds() {
    final Float32List rect = _getBounds();
    return Rect.fromLTRB(rect[0], rect[1], rect[2], rect[3]);
  }
  Float32List _getBounds() native 'Path_getBounds';

  /// Combines the two paths according to the manner specified by the given
  /// `operation`.
  ///
  /// The resulting path will be constructed from non-overlapping contours. The
  /// curve order is reduced where possible so that cubics may be turned into
  /// quadratics, and quadratics maybe turned into lines.
  static Path combine(PathOperation operation, Path path1, Path path2) {
    assert(path1 != null);
    assert(path2 != null);
    final Path path = Path();
    if (path._op(path1, path2, operation.index)) {
      return path;
    }
    throw StateError('Path.combine() failed.  This may be due an invalid path; in particular, check for NaN values.');
  }
  bool _op(Path path1, Path path2, int operation) native 'Path_op';

  /// Creates a [PathMetrics] object for this path, which can describe various
  /// properties about the contours of the path.
  ///
  /// A [Path] is made up of zero or more contours. A contour is made up of
  /// connected curves and segments, created via methods like [lineTo],
  /// [cubicTo], [arcTo], [quadraticBezierTo], their relative counterparts, as
  /// well as the add* methods such as [addRect]. Creating a new [Path] starts
  /// a new contour once it has any drawing instructions, and another new
  /// contour is started for each [moveTo] instruction.
  ///
  /// A [PathMetric] object describes properties of an individual contour,
  /// such as its length, whether it is closed, what the tangent vector of a
  /// particular offset along the path is. It also provides a method for
  /// creating sub-paths: [PathMetric.extractPath].
  ///
  /// Calculating [PathMetric] objects is not trivial. The [PathMetrics] object
  /// returned by this method is a lazy [Iterable], meaning it only performs
  /// calculations when the iterator is moved to the next [PathMetric]. Callers
  /// that wish to memoize this iterable can easily do so by using
  /// [Iterable.toList] on the result of this method. In particular, callers
  /// looking for information about how many contours are in the path should
  /// either store the result of `path.computeMetrics().length`, or should use
  /// `path.computeMetrics().toList()` so they can repeatedly check the length,
  /// since calling `Iterable.length` causes traversal of the entire iterable.
  ///
  /// In particular, callers should be aware that [PathMetrics.length] is the
  /// number of contours, **not the length of the path**. To get the length of
  /// a contour in a path, use [PathMetric.length].
  ///
  /// If `forceClosed` is set to true, the contours of the path will be measured
  /// as if they had been closed, even if they were not explicitly closed.
  PathMetrics computeMetrics({bool forceClosed = false}) {
    return PathMetrics._(this, forceClosed);
  }
}

/// The geometric description of a tangent: the angle at a point.
///
/// See also:
///  * [PathMetric.getTangentForOffset], which returns the tangent of an offset along a path.
class Tangent {
  /// Creates a [Tangent] with the given values.
  ///
  /// The arguments must not be null.
  const Tangent(this.position, this.vector)
    : assert(position != null),
      assert(vector != null);

  /// Creates a [Tangent] based on the angle rather than the vector.
  ///
  /// The [vector] is computed to be the unit vector at the given angle, interpreted
  /// as clockwise radians from the x axis.
  factory Tangent.fromAngle(Offset position, double angle) {
    return Tangent(position, Offset(math.cos(angle), math.sin(angle)));
  }

  /// Position of the tangent.
  ///
  /// When used with [PathMetric.getTangentForOffset], this represents the precise
  /// position that the given offset along the path corresponds to.
  final Offset position;

  /// The vector of the curve at [position].
  ///
  /// When used with [PathMetric.getTangentForOffset], this is the vector of the
  /// curve that is at the given offset along the path (i.e. the direction of the
  /// curve at [position]).
  final Offset vector;

  /// The direction of the curve at [position].
  ///
  /// When used with [PathMetric.getTangentForOffset], this is the angle of the
  /// curve that is the given offset along the path (i.e. the direction of the
  /// curve at [position]).
  ///
  /// This value is in radians, with 0.0 meaning pointing along the x axis in
  /// the positive x-axis direction, positive numbers pointing downward toward
  /// the negative y-axis, i.e. in a clockwise direction, and negative numbers
  /// pointing upward toward the positive y-axis, i.e. in a counter-clockwise
  /// direction.
  // flip the sign to be consistent with [Path.arcTo]'s `sweepAngle`
  double get angle => -math.atan2(vector.dy, vector.dx);
}

/// An iterable collection of [PathMetric] objects describing a [Path].
///
/// A [PathMetrics] object is created by using the [Path.computeMetrics] method,
/// and represents the path as it stood at the time of the call. Subsequent
/// modifications of the path do not affect the [PathMetrics] object.
///
/// Each path metric corresponds to a segment, or contour, of a path.
///
/// For example, a path consisting of a [Path.lineTo], a [Path.moveTo], and
/// another [Path.lineTo] will contain two contours and thus be represented by
/// two [PathMetric] objects.
///
/// This iterable does not memoize. Callers who need to traverse the list
/// multiple times, or who need to randomly access elements of the list, should
/// use [toList] on this object.
class PathMetrics extends collection.IterableBase<PathMetric> {
  PathMetrics._(Path path, bool forceClosed) :
    _iterator = PathMetricIterator._(_PathMeasure(path, forceClosed));

  final Iterator<PathMetric> _iterator;

  @override
  Iterator<PathMetric> get iterator => _iterator;
}

/// Used by [PathMetrics] to track iteration from one segment of a path to the
/// next for measurement.
class PathMetricIterator implements Iterator<PathMetric> {
  PathMetricIterator._(this._pathMeasure) : assert(_pathMeasure != null);

  PathMetric? _pathMetric;
  _PathMeasure _pathMeasure;

  @override
  PathMetric get current {
    final PathMetric? currentMetric = _pathMetric;
    if (currentMetric == null) {
      throw RangeError(
        'PathMetricIterator is not pointing to a PathMetric. This can happen in two situations:\n'
        '- The iteration has not started yet. If so, call "moveNext" to start iteration.\n'
        '- The iterator ran out of elements. If so, check that "moveNext" returns true prior to calling "current".'
      );
    }
    return currentMetric;
  }

  @override
  bool moveNext() {
    if (_pathMeasure._nextContour()) {
      _pathMetric = PathMetric._(_pathMeasure);
      return true;
    }
    _pathMetric = null;
    return false;
  }
}

/// Utilities for measuring a [Path] and extracting sub-paths.
///
/// Iterate over the object returned by [Path.computeMetrics] to obtain
/// [PathMetric] objects. Callers that want to randomly access elements or
/// iterate multiple times should use `path.computeMetrics().toList()`, since
/// [PathMetrics] does not memoize.
///
/// Once created, the metrics are only valid for the path as it was specified
/// when [Path.computeMetrics] was called. If additional contours are added or
/// any contours are updated, the metrics need to be recomputed. Previously
/// created metrics will still refer to a snapshot of the path at the time they
/// were computed, rather than to the actual metrics for the new mutations to
/// the path.
class PathMetric {
  PathMetric._(this._measure)
    : assert(_measure != null),
      length = _measure.length(_measure.currentContourIndex),
      isClosed = _measure.isClosed(_measure.currentContourIndex),
      contourIndex = _measure.currentContourIndex;

  /// Return the total length of the current contour.
  final double length;

  /// Whether the contour is closed.
  ///
  /// Returns true if the contour ends with a call to [Path.close] (which may
  /// have been implied when using methods like [Path.addRect]) or if
  /// `forceClosed` was specified as true in the call to [Path.computeMetrics].
  /// Returns false otherwise.
  final bool isClosed;

  /// The zero-based index of the contour.
  ///
  /// [Path] objects are made up of zero or more contours. The first contour is
  /// created once a drawing command (e.g. [Path.lineTo]) is issued. A
  /// [Path.moveTo] command after a drawing command may create a new contour,
  /// although it may not if optimizations are applied that determine the move
  /// command did not actually result in moving the pen.
  ///
  /// This property is only valid with reference to its original iterator and
  /// the contours of the path at the time the path's metrics were computed. If
  /// additional contours were added or existing contours updated, this metric
  /// will be invalid for the current state of the path.
  final int contourIndex;

  final _PathMeasure _measure;


  /// Computes the position of the current contour at the given offset, and the
  /// angle of the path at that point.
  ///
  /// For example, calling this method with a distance of 1.41 for a line from
  /// 0.0,0.0 to 2.0,2.0 would give a point 1.0,1.0 and the angle 45 degrees
  /// (but in radians).
  ///
  /// Returns null if the contour has zero [length].
  ///
  /// The distance is clamped to the [length] of the current contour.
  Tangent? getTangentForOffset(double distance) {
    return _measure.getTangentForOffset(contourIndex, distance);
  }

  /// Given a start and end distance, return the intervening segment(s).
  ///
  /// `start` and `end` are clamped to legal values (0..[length])
  /// Begin the segment with a moveTo if `startWithMoveTo` is true.
  Path extractPath(double start, double end, {bool startWithMoveTo = true}) {
    return _measure.extractPath(contourIndex, start, end, startWithMoveTo: startWithMoveTo);
  }

  @override
  String toString() => '$runtimeType{length: $length, isClosed: $isClosed, contourIndex:$contourIndex}';
}

class _PathMeasure extends NativeFieldWrapperClass1 {
  _PathMeasure(Path path, bool forceClosed) {
    _constructor(path, forceClosed);
  }
  void _constructor(Path path, bool forceClosed) native 'PathMeasure_constructor';

  double length(int contourIndex) {
    assert(contourIndex <= currentContourIndex, 'Iterator must be advanced before index $contourIndex can be used.');
    return _length(contourIndex);
  }
  double _length(int contourIndex) native 'PathMeasure_getLength';

  Tangent? getTangentForOffset(int contourIndex, double distance) {
    assert(contourIndex <= currentContourIndex, 'Iterator must be advanced before index $contourIndex can be used.');
    final Float32List posTan = _getPosTan(contourIndex, distance);
    // first entry == 0 indicates that Skia returned false
    if (posTan[0] == 0.0) {
      return null;
    } else {
      return Tangent(
        Offset(posTan[1], posTan[2]),
        Offset(posTan[3], posTan[4])
      );
    }
  }
  Float32List _getPosTan(int contourIndex, double distance) native 'PathMeasure_getPosTan';

  Path extractPath(int contourIndex, double start, double end, {bool startWithMoveTo = true}) {
    assert(contourIndex <= currentContourIndex, 'Iterator must be advanced before index $contourIndex can be used.');
    final Path path = Path._();
    _extractPath(path, contourIndex, start, end, startWithMoveTo: startWithMoveTo);
    return path;
  }
  void _extractPath(Path outPath, int contourIndex, double start, double end, {bool startWithMoveTo = true}) native 'PathMeasure_getSegment';

  bool isClosed(int contourIndex) {
    assert(contourIndex <= currentContourIndex, 'Iterator must be advanced before index $contourIndex can be used.');
    return _isClosed(contourIndex);
  }
  bool _isClosed(int contourIndex) native 'PathMeasure_isClosed';

  // Move to the next contour in the path.
  //
  // A path can have a next contour if [Path.moveTo] was called after drawing began.
  // Return true if one exists, or false.
  bool _nextContour() {
    final bool next = _nativeNextContour();
    if (next) {
      currentContourIndex++;
    }
    return next;
  }
  bool _nativeNextContour() native 'PathMeasure_nextContour';

  /// The index of the current contour in the list of contours in the path.
  ///
  /// [nextContour] will increment this to the zero based index.
  int currentContourIndex = -1;
}

/// Styles to use for blurs in [MaskFilter] objects.
// These enum values must be kept in sync with SkBlurStyle.
enum BlurStyle {
  // These mirror SkBlurStyle and must be kept in sync.

  /// Fuzzy inside and outside. This is useful for painting shadows that are
  /// offset from the shape that ostensibly is casting the shadow.
  normal,

  /// Solid inside, fuzzy outside. This corresponds to drawing the shape, and
  /// additionally drawing the blur. This can make objects appear brighter,
  /// maybe even as if they were fluorescent.
  solid,

  /// Nothing inside, fuzzy outside. This is useful for painting shadows for
  /// partially transparent shapes, when they are painted separately but without
  /// an offset, so that the shadow doesn't paint below the shape.
  outer,

  /// Fuzzy inside, nothing outside. This can make shapes appear to be lit from
  /// within.
  inner,
}

/// A mask filter to apply to shapes as they are painted. A mask filter is a
/// function that takes a bitmap of color pixels, and returns another bitmap of
/// color pixels.
///
/// Instances of this class are used with [Paint.maskFilter] on [Paint] objects.
class MaskFilter {
  /// Creates a mask filter that takes the shape being drawn and blurs it.
  ///
  /// This is commonly used to approximate shadows.
  ///
  /// The `style` argument controls the kind of effect to draw; see [BlurStyle].
  ///
  /// The `sigma` argument controls the size of the effect. It is the standard
  /// deviation of the Gaussian blur to apply. The value must be greater than
  /// zero. The sigma corresponds to very roughly half the radius of the effect
  /// in pixels.
  ///
  /// A blur is an expensive operation and should therefore be used sparingly.
  ///
  /// The arguments must not be null.
  ///
  /// See also:
  ///
  ///  * [Canvas.drawShadow], which is a more efficient way to draw shadows.
  const MaskFilter.blur(
    this._style,
    this._sigma,
  ) : assert(_style != null),
      assert(_sigma != null);

  final BlurStyle _style;
  final double _sigma;

  // The type of MaskFilter class to create for Skia.
  // These constants must be kept in sync with MaskFilterType in paint.cc.
  static const int _TypeNone = 0; // null
  static const int _TypeBlur = 1; // SkBlurMaskFilter

  @override
  bool operator ==(Object other) {
    return other is MaskFilter
        && other._style == _style
        && other._sigma == _sigma;
  }

  @override
  int get hashCode => Object.hash(_style, _sigma);

  @override
  String toString() => 'MaskFilter.blur($_style, ${_sigma.toStringAsFixed(1)})';
}

/// A description of a color filter to apply when drawing a shape or compositing
/// a layer with a particular [Paint]. A color filter is a function that takes
/// two colors, and outputs one color. When applied during compositing, it is
/// independently applied to each pixel of the layer being drawn before the
/// entire layer is merged with the destination.
///
/// Instances of this class are used with [Paint.colorFilter] on [Paint]
/// objects.
class ColorFilter implements ImageFilter {
  /// Creates a color filter that applies the blend mode given as the second
  /// argument. The source color is the one given as the first argument, and the
  /// destination color is the one from the layer being composited.
  ///
  /// The output of this filter is then composited into the background according
  /// to the [Paint.blendMode], using the output of this filter as the source
  /// and the background as the destination.
  const ColorFilter.mode(Color color, BlendMode blendMode)
      : _color = color,
        _blendMode = blendMode,
        _matrix = null,
        _type = _kTypeMode;

  /// Construct a color filter that transforms a color by a 5x5 matrix, where
  /// the fifth row is implicitly added in an identity configuration.
  ///
  /// Every pixel's color value, repsented as an `[R, G, B, A]`, is matrix
  /// multiplied to create a new color:
  ///
  /// ```text
  /// | R' |   | a00 a01 a02 a03 a04 |   | R |
  /// | G' |   | a10 a11 a22 a33 a44 |   | G |
  /// | B' | = | a20 a21 a22 a33 a44 | * | B |
  /// | A' |   | a30 a31 a22 a33 a44 |   | A |
  /// | 1  |   |  0   0   0   0   1  |   | 1 |
  /// ```
  ///
  /// The matrix is in row-major order and the translation column is specified
  /// in unnormalized, 0...255, space. For example, the identity matrix is:
  ///
  /// ```
  /// const ColorFilter identity = ColorFilter.matrix(<double>[
  ///   1, 0, 0, 0, 0,
  ///   0, 1, 0, 0, 0,
  ///   0, 0, 1, 0, 0,
  ///   0, 0, 0, 1, 0,
  /// ]);
  /// ```
  ///
  /// ## Examples
  ///
  /// An inversion color matrix:
  ///
  /// ```
  /// const ColorFilter invert = ColorFilter.matrix(<double>[
  ///   -1,  0,  0, 0, 255,
  ///    0, -1,  0, 0, 255,
  ///    0,  0, -1, 0, 255,
  ///    0,  0,  0, 1,   0,
  /// ]);
  /// ```
  ///
  /// A sepia-toned color matrix (values based on the [Filter Effects Spec](https://www.w3.org/TR/filter-effects-1/#sepiaEquivalent)):
  ///
  /// ```
  /// const ColorFilter sepia = ColorFilter.matrix(<double>[
  ///   0.393, 0.769, 0.189, 0, 0,
  ///   0.349, 0.686, 0.168, 0, 0,
  ///   0.272, 0.534, 0.131, 0, 0,
  ///   0,     0,     0,     1, 0,
  /// ]);
  /// ```
  ///
  /// A greyscale color filter (values based on the [Filter Effects Spec](https://www.w3.org/TR/filter-effects-1/#grayscaleEquivalent)):
  ///
  /// ```
  /// const ColorFilter greyscale = ColorFilter.matrix(<double>[
  ///   0.2126, 0.7152, 0.0722, 0, 0,
  ///   0.2126, 0.7152, 0.0722, 0, 0,
  ///   0.2126, 0.7152, 0.0722, 0, 0,
  ///   0,      0,      0,      1, 0,
  /// ]);
  /// ```
  const ColorFilter.matrix(List<double> matrix)
      : _color = null,
        _blendMode = null,
        _matrix = matrix,
        _type = _kTypeMatrix;

  /// Construct a color filter that applies the sRGB gamma curve to the RGB
  /// channels.
  const ColorFilter.linearToSrgbGamma()
      : _color = null,
        _blendMode = null,
        _matrix = null,
        _type = _kTypeLinearToSrgbGamma;

  /// Creates a color filter that applies the inverse of the sRGB gamma curve
  /// to the RGB channels.
  const ColorFilter.srgbToLinearGamma()
      : _color = null,
        _blendMode = null,
        _matrix = null,
        _type = _kTypeSrgbToLinearGamma;

  final Color? _color;
  final BlendMode? _blendMode;
  final List<double>? _matrix;
  final int _type;

  // The type of SkColorFilter class to create for Skia.
  static const int _kTypeMode = 1; // MakeModeFilter
  static const int _kTypeMatrix = 2; // MakeMatrixFilterRowMajor255
  static const int _kTypeLinearToSrgbGamma = 3; // MakeLinearToSRGBGamma
  static const int _kTypeSrgbToLinearGamma = 4; // MakeSRGBToLinearGamma

  // SkImageFilters::ColorFilter
  @override
  _ImageFilter _toNativeImageFilter() => _ImageFilter.fromColorFilter(this);

  _ColorFilter? _toNativeColorFilter() {
    switch (_type) {
      case _kTypeMode:
        if (_color == null || _blendMode == null) {
          return null;
        }
        return _ColorFilter.mode(this);
      case _kTypeMatrix:
        if (_matrix == null) {
          return null;
        }
        assert(_matrix!.length == 20, 'Color Matrix must have 20 entries.');
        return _ColorFilter.matrix(this);
      case _kTypeLinearToSrgbGamma:
        return _ColorFilter.linearToSrgbGamma(this);
      case _kTypeSrgbToLinearGamma:
        return _ColorFilter.srgbToLinearGamma(this);
      default:
        throw StateError('Unknown mode $_type for ColorFilter.');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is ColorFilter
        && other._type == _type
        && _listEquals<double>(other._matrix, _matrix)
        && other._color == _color
        && other._blendMode == _blendMode;
  }

  @override
  int get hashCode => Object.hash(_color, _blendMode, _matrix == null ? null : Object.hashAll(_matrix!), _type);

  @override
  String get _shortDescription {
    switch (_type) {
      case _kTypeMode:
        return 'ColorFilter.mode($_color, $_blendMode)';
      case _kTypeMatrix:
        return 'ColorFilter.matrix($_matrix)';
      case _kTypeLinearToSrgbGamma:
        return 'ColorFilter.linearToSrgbGamma()';
      case _kTypeSrgbToLinearGamma:
        return 'ColorFilter.srgbToLinearGamma()';
      default:
        return 'unknow ColorFilter';
    }
  }

  @override
  String toString() {
    switch (_type) {
      case _kTypeMode:
        return 'ColorFilter.mode($_color, $_blendMode)';
      case _kTypeMatrix:
        return 'ColorFilter.matrix($_matrix)';
      case _kTypeLinearToSrgbGamma:
        return 'ColorFilter.linearToSrgbGamma()';
      case _kTypeSrgbToLinearGamma:
        return 'ColorFilter.srgbToLinearGamma()';
      default:
        return 'Unknown ColorFilter type. This is an error. If you\'re seeing this, please file an issue at https://github.com/flutter/flutter/issues/new.';
    }
  }
}

/// A [ColorFilter] that is backed by a native SkColorFilter.
///
/// This is a private class, rather than being the implementation of the public
/// ColorFilter, because we want ColorFilter to be const constructible and
/// efficiently comparable, so that widgets can check for ColorFilter equality to
/// avoid repainting.
class _ColorFilter extends NativeFieldWrapperClass1 {
  _ColorFilter.mode(this.creator)
    : assert(creator != null),
      assert(creator._type == ColorFilter._kTypeMode) {
    _constructor();
    _initMode(creator._color!.value, creator._blendMode!.index);
  }

  _ColorFilter.matrix(this.creator)
    : assert(creator != null),
      assert(creator._type == ColorFilter._kTypeMatrix) {
    _constructor();
    _initMatrix(Float32List.fromList(creator._matrix!));
  }
  _ColorFilter.linearToSrgbGamma(this.creator)
    : assert(creator != null),
      assert(creator._type == ColorFilter._kTypeLinearToSrgbGamma) {
    _constructor();
    _initLinearToSrgbGamma();
  }

  _ColorFilter.srgbToLinearGamma(this.creator)
    : assert(creator != null),
      assert(creator._type == ColorFilter._kTypeSrgbToLinearGamma) {
    _constructor();
    _initSrgbToLinearGamma();
  }

  /// The original Dart object that created the native wrapper, which retains
  /// the values used for the filter.
  final ColorFilter creator;

  void _constructor() native 'ColorFilter_constructor';
  void _initMode(int color, int blendMode) native 'ColorFilter_initMode';
  void _initMatrix(Float32List matrix) native 'ColorFilter_initMatrix';
  void _initLinearToSrgbGamma() native 'ColorFilter_initLinearToSrgbGamma';
  void _initSrgbToLinearGamma() native 'ColorFilter_initSrgbToLinearGamma';
}

/// A filter operation to apply to a raster image.
///
/// See also:
///
///  * [BackdropFilter], a widget that applies [ImageFilter] to its rendering.
///  * [ImageFiltered], a widget that applies [ImageFilter] to its children.
///  * [SceneBuilder.pushBackdropFilter], which is the low-level API for using
///    this class as a backdrop filter.
///  * [SceneBuilder.pushImageFilter], which is the low-level API for using
///    this class as a child layer filter.
abstract class ImageFilter {
  /// Creates an image filter that applies a Gaussian blur.
  factory ImageFilter.blur({ double sigmaX = 0.0, double sigmaY = 0.0, TileMode tileMode = TileMode.clamp }) {
    assert(sigmaX != null);
    assert(sigmaY != null);
    assert(tileMode != null);
    return _GaussianBlurImageFilter(sigmaX: sigmaX, sigmaY: sigmaY, tileMode: tileMode);
  }

  /// Creates an image filter that dilates each input pixel's channel values
  /// to the max value within the given radii along the x and y axes.
  factory ImageFilter.dilate({ double radiusX = 0.0, double radiusY = 0.0 }) {
    assert(radiusX != null);
    assert(radiusY != null);
    return _DilateImageFilter(radiusX: radiusX, radiusY: radiusY);
  }

  /// Create a filter that erodes each input pixel's channel values
  /// to the minimum channel value within the given radii along the x and y axes.
  factory ImageFilter.erode({ double radiusX = 0.0, double radiusY = 0.0 }) {
    assert(radiusX != null);
    assert(radiusY != null);
    return _ErodeImageFilter(radiusX: radiusX, radiusY: radiusY);
  }

  /// Creates an image filter that applies a matrix transformation.
  ///
  /// For example, applying a positive scale matrix (see [Matrix4.diagonal3])
  /// when used with [BackdropFilter] would magnify the background image.
  factory ImageFilter.matrix(Float64List matrix4,
                     { FilterQuality filterQuality = FilterQuality.low }) {
    assert(matrix4 != null);
    assert(filterQuality != null);
    if (matrix4.length != 16)
      throw ArgumentError('"matrix4" must have 16 entries.');
    return _MatrixImageFilter(data: Float64List.fromList(matrix4), filterQuality: filterQuality);
  }

  /// Composes the `inner` filter with `outer`, to combine their effects.
  ///
  /// Creates a single [ImageFilter] that when applied, has the same effect as
  /// subsequently applying `inner` and `outer`, i.e.,
  /// result = outer(inner(source)).
  factory ImageFilter.compose({ required ImageFilter outer, required ImageFilter inner }) {
    assert (inner != null && outer != null);
    return _ComposeImageFilter(innerFilter: inner, outerFilter: outer);
  }

  // Converts this to a native SkImageFilter. See the comments of this method in
  // subclasses for the exact type of SkImageFilter this method converts to.
  _ImageFilter _toNativeImageFilter();

  // The description text to show when the filter is part of a composite
  // [ImageFilter] created using [ImageFilter.compose].
  String get _shortDescription;
}

class _MatrixImageFilter implements ImageFilter {
  _MatrixImageFilter({ required this.data, required this.filterQuality });

  final Float64List data;
  final FilterQuality filterQuality;

  // MakeMatrixFilterRowMajor255
  late final _ImageFilter nativeFilter = _ImageFilter.matrix(this);
  @override
  _ImageFilter _toNativeImageFilter() => nativeFilter;

  @override
  String get _shortDescription => 'matrix($data, $filterQuality)';

  @override
  String toString() => 'ImageFilter.matrix($data, $filterQuality)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _MatrixImageFilter
        && other.filterQuality == filterQuality
        && _listEquals<double>(other.data, data);
  }

  @override
  int get hashCode => Object.hash(filterQuality, Object.hashAll(data));
}

class _GaussianBlurImageFilter implements ImageFilter {
  _GaussianBlurImageFilter({ required this.sigmaX, required this.sigmaY, required this.tileMode });

  final double sigmaX;
  final double sigmaY;
  final TileMode tileMode;

  // MakeBlurFilter
  late final _ImageFilter nativeFilter = _ImageFilter.blur(this);
  @override
  _ImageFilter _toNativeImageFilter() => nativeFilter;

  String get _modeString {
    switch(tileMode) {
      case TileMode.clamp: return 'clamp';
      case TileMode.mirror: return 'mirror';
      case TileMode.repeated: return 'repeated';
      case TileMode.decal: return 'decal';
    }
  }

  @override
  String get _shortDescription => 'blur($sigmaX, $sigmaY, $_modeString)';

  @override
  String toString() => 'ImageFilter.blur($sigmaX, $sigmaY, $_modeString)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _GaussianBlurImageFilter
        && other.sigmaX == sigmaX
        && other.sigmaY == sigmaY
        && other.tileMode == tileMode;
  }

  @override
  int get hashCode => Object.hash(sigmaX, sigmaY);
}

class _DilateImageFilter implements ImageFilter {
  _DilateImageFilter({ required this.radiusX, required this.radiusY });

  final double radiusX;
  final double radiusY;

  late final _ImageFilter nativeFilter = _ImageFilter.dilate(this);
  @override
  _ImageFilter _toNativeImageFilter() => nativeFilter;

  @override
  String get _shortDescription => 'dilate($radiusX, $radiusY)';

  @override
  String toString() => 'ImageFilter.dilate($radiusX, $radiusY)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _DilateImageFilter
        && other.radiusX == radiusX
        && other.radiusY == radiusY;
  }

  @override
  int get hashCode => Object.hash(radiusX, radiusY);
}

class _ErodeImageFilter implements ImageFilter {
  _ErodeImageFilter({ required this.radiusX, required this.radiusY });

  final double radiusX;
  final double radiusY;

  late final _ImageFilter nativeFilter = _ImageFilter.erode(this);
  @override
  _ImageFilter _toNativeImageFilter() => nativeFilter;

  @override
  String get _shortDescription => 'erode($radiusX, $radiusY)';

  @override
  String toString() => 'ImageFilter.erode($radiusX, $radiusY)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _ErodeImageFilter
        && other.radiusX == radiusX
        && other.radiusY == radiusY;
  }

  @override
  int get hashCode => hashValues(radiusX, radiusY);
}

class _ComposeImageFilter implements ImageFilter {
  _ComposeImageFilter({ required this.innerFilter, required this.outerFilter });

  final ImageFilter innerFilter;
  final ImageFilter outerFilter;

  // SkImageFilters::Compose
  late final _ImageFilter nativeFilter = _ImageFilter.composed(this);
  @override
  _ImageFilter _toNativeImageFilter() => nativeFilter;

  @override
  String get _shortDescription => '${innerFilter._shortDescription} -> ${outerFilter._shortDescription}';

  @override
  String toString() => 'ImageFilter.compose(source -> $_shortDescription -> result)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _ComposeImageFilter
        && other.innerFilter == innerFilter
        && other.outerFilter == outerFilter;
  }

  @override
  int get hashCode => Object.hash(innerFilter, outerFilter);
}

/// An [ImageFilter] that is backed by a native SkImageFilter.
///
/// This is a private class, rather than being the implementation of the public
/// ImageFilter, because we want ImageFilter to be efficiently comparable, so that
/// widgets can check for ImageFilter equality to avoid repainting.
class _ImageFilter extends NativeFieldWrapperClass1 {
  void _constructor() native 'ImageFilter_constructor';

  /// Creates an image filter that applies a Gaussian blur.
  _ImageFilter.blur(_GaussianBlurImageFilter filter)
    : assert(filter != null),
      creator = filter {    // ignore: prefer_initializing_formals
    _constructor();
    _initBlur(filter.sigmaX, filter.sigmaY, filter.tileMode.index);
  }
  void _initBlur(double sigmaX, double sigmaY, int tileMode) native 'ImageFilter_initBlur';

  /// Creates an image filter that dilates each input pixel's channel values
  /// to the max value within the given radii along the x and y axes.
  _ImageFilter.dilate(_DilateImageFilter filter)
    : assert(filter != null),
      creator = filter {    // ignore: prefer_initializing_formals
    _constructor();
    _initDilate(filter.radiusX, filter.radiusY);
  }
  void _initDilate(double radiusX, double radiusY) native 'ImageFilter_initDilate';

  /// Create a filter that erodes each input pixel's channel values
  /// to the minimum channel value within the given radii along the x and y axes.
  _ImageFilter.erode(_ErodeImageFilter filter)
    : assert(filter != null),
      creator = filter {    // ignore: prefer_initializing_formals
    _constructor();
    _initErode(filter.radiusX, filter.radiusY);
  }
  void _initErode(double radiusX, double radiusY) native 'ImageFilter_initErode';

  /// Creates an image filter that applies a matrix transformation.
  ///
  /// For example, applying a positive scale matrix (see [Matrix4.diagonal3])
  /// when used with [BackdropFilter] would magnify the background image.
  _ImageFilter.matrix(_MatrixImageFilter filter)
    : assert(filter != null),
      creator = filter {    // ignore: prefer_initializing_formals
    if (filter.data.length != 16)
      throw ArgumentError('"matrix4" must have 16 entries.');
    _constructor();
    _initMatrix(filter.data, filter.filterQuality.index);
  }
  void _initMatrix(Float64List matrix4, int filterQuality) native 'ImageFilter_initMatrix';

  /// Converts a color filter to an image filter.
  _ImageFilter.fromColorFilter(ColorFilter filter)
    : assert(filter != null),
      creator = filter {    // ignore: prefer_initializing_formals
    _constructor();
    final _ColorFilter? nativeFilter = filter._toNativeColorFilter();
    _initColorFilter(nativeFilter!);
  }
  void _initColorFilter(_ColorFilter colorFilter) native 'ImageFilter_initColorFilter';

  /// Composes `_innerFilter` with `_outerFilter`.
  _ImageFilter.composed(_ComposeImageFilter filter)
    : assert(filter != null),
      creator = filter {    // ignore: prefer_initializing_formals
    _constructor();
    final _ImageFilter nativeFilterInner = filter.innerFilter._toNativeImageFilter();
    final _ImageFilter nativeFilterOuter = filter.outerFilter._toNativeImageFilter();
    _initComposed(nativeFilterOuter,  nativeFilterInner);
  }
  void _initComposed(_ImageFilter outerFilter, _ImageFilter innerFilter) native 'ImageFilter_initComposeFilter';
  /// The original Dart object that created the native wrapper, which retains
  /// the values used for the filter.
  final ImageFilter creator;
}

/// Base class for objects such as [Gradient] and [ImageShader] which
/// correspond to shaders as used by [Paint.shader].
class Shader extends NativeFieldWrapperClass1 {
  /// This class is created by the engine, and should not be instantiated
  /// or extended directly.
  @pragma('vm:entry-point')
  Shader._();
}

/// Defines what happens at the edge of a gradient or the sampling of a source image
/// in an [ImageFilter].
///
/// A gradient is defined along a finite inner area. In the case of a linear
/// gradient, it's between the parallel lines that are orthogonal to the line
/// drawn between two points. In the case of radial gradients, it's the disc
/// that covers the circle centered on a particular point up to a given radius.
///
/// An image filter reads source samples from a source image and performs operations
/// on those samples to produce a result image. An image defines color samples only
/// for pixels within the bounds of the image but some filter operations, such as a blur
/// filter, read samples over a wide area to compute the output for a given pixel. Such
/// a filter would need to combine samples from inside the image with hypothetical
/// color values from outside the image.
///
/// This enum is used to define how the gradient or image filter should treat the regions
/// outside that defined inner area.
///
/// See also:
///
///  * [painting.Gradient], the superclass for [LinearGradient] and
///    [RadialGradient], as used by [BoxDecoration] et al, which works in
///    relative coordinates and can create a [Shader] representing the gradient
///    for a particular [Rect] on demand.
///  * [dart:ui.Gradient], the low-level class used when dealing with the
///    [Paint.shader] property directly, with its [Gradient.linear] and
///    [Gradient.radial] constructors.
///  * [dart:ui.ImageFilter.blur], an ImageFilter that may sometimes need to
///    read samples from outside an image to combine with the pixels near the
///    edge of the image.
// These enum values must be kept in sync with SkTileMode.
enum TileMode {
  /// Samples beyond the edge are clamped to the nearest color in the defined inner area.
  ///
  /// A gradient will paint all the regions outside the inner area with the
  /// color at the end of the color stop list closest to that region.
  ///
  /// An image filter will substitute the nearest edge pixel for any samples taken from
  /// outside its source image.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_sweep.png)
  clamp,

  /// Samples beyond the edge are repeated from the far end of the defined area.
  ///
  /// For a gradient, this technique is as if the stop points from 0.0 to 1.0 were then
  /// repeated from 1.0 to 2.0, 2.0 to 3.0, and so forth (and for linear gradients, similarly
  /// from -1.0 to 0.0, -2.0 to -1.0, etc).
  ///
  /// An image filter will treat its source image as if it were tiled across the enlarged
  /// sample space from which it reads, each tile in the same orientation as the base image.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_sweep.png)
  repeated,

  /// Samples beyond the edge are mirrored back and forth across the defined area.
  ///
  /// For a gradient, this technique is as if the stop points from 0.0 to 1.0 were then
  /// repeated backwards from 2.0 to 1.0, then forwards from 2.0 to 3.0, then backwards
  /// again from 4.0 to 3.0, and so forth (and for linear gradients, similarly in the
  /// negative direction).
  ///
  /// An image filter will treat its source image as tiled in an alternating forwards and
  /// backwards or upwards and downwards direction across the sample space from which
  /// it is reading.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_sweep.png)
  mirror,

  /// Samples beyond the edge are treated as transparent black.
  ///
  /// A gradient will render transparency over any region that is outside the circle of a
  /// radial gradient or outside the parallel lines that define the inner area of a linear
  /// gradient.
  ///
  /// An image filter will substitute transparent black for any sample it must read from
  /// outside its source image.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_sweep.png)
  decal,
}

Int32List _encodeColorList(List<Color> colors) {
  final int colorCount = colors.length;
  final Int32List result = Int32List(colorCount);
  for (int i = 0; i < colorCount; ++i)
    result[i] = colors[i].value;
  return result;
}

Float32List _encodePointList(List<Offset> points) {
  assert(points != null);
  final int pointCount = points.length;
  final Float32List result = Float32List(pointCount * 2);
  for (int i = 0; i < pointCount; ++i) {
    final int xIndex = i * 2;
    final int yIndex = xIndex + 1;
    final Offset point = points[i];
    assert(_offsetIsValid(point));
    result[xIndex] = point.dx;
    result[yIndex] = point.dy;
  }
  return result;
}

Float32List _encodeTwoPoints(Offset pointA, Offset pointB) {
  assert(_offsetIsValid(pointA));
  assert(_offsetIsValid(pointB));
  final Float32List result = Float32List(4);
  result[0] = pointA.dx;
  result[1] = pointA.dy;
  result[2] = pointB.dx;
  result[3] = pointB.dy;
  return result;
}

/// A shader (as used by [Paint.shader]) that renders a color gradient.
///
/// There are several types of gradients, represented by the various constructors
/// on this class.
///
/// See also:
///
///  * [Gradient](https://api.flutter.dev/flutter/painting/Gradient-class.html), the class in the [painting] library.
///
class Gradient extends Shader {

  void _constructor() native 'Gradient_constructor';

  /// Creates a linear gradient from `from` to `to`.
  ///
  /// If `colorStops` is provided, `colorStops[i]` is a number from 0.0 to 1.0
  /// that specifies where `color[i]` begins in the gradient. If `colorStops` is
  /// not provided, then only two stops, at 0.0 and 1.0, are implied (and
  /// `color` must therefore only have two entries).
  ///
  /// The behavior before `from` and after `to` is described by the `tileMode`
  /// argument. For details, see the [TileMode] enum.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_linear.png)
  ///
  /// If `from`, `to`, `colors`, or `tileMode` are null, or if `colors` or
  /// `colorStops` contain null values, this constructor will throw a
  /// [NoSuchMethodError].
  ///
  /// If `matrix4` is provided, the gradient fill will be transformed by the
  /// specified 4x4 matrix relative to the local coordinate system. `matrix4` must
  /// be a column-major matrix packed into a list of 16 values.
  Gradient.linear(
    Offset from,
    Offset to,
    List<Color> colors, [
    List<double>? colorStops,
    TileMode tileMode = TileMode.clamp,
    Float64List? matrix4,
  ]) : assert(_offsetIsValid(from)),
       assert(_offsetIsValid(to)),
       assert(colors != null),
       assert(tileMode != null),
       assert(matrix4 == null || _matrix4IsValid(matrix4)),
       super._() {
    _validateColorStops(colors, colorStops);
    final Float32List endPointsBuffer = _encodeTwoPoints(from, to);
    final Int32List colorsBuffer = _encodeColorList(colors);
    final Float32List? colorStopsBuffer = colorStops == null ? null : Float32List.fromList(colorStops);
    _constructor();
    _initLinear(endPointsBuffer, colorsBuffer, colorStopsBuffer, tileMode.index, matrix4);
  }
  void _initLinear(Float32List endPoints, Int32List colors, Float32List? colorStops, int tileMode, Float64List? matrix4) native 'Gradient_initLinear';

  /// Creates a radial gradient centered at `center` that ends at `radius`
  /// distance from the center.
  ///
  /// If `colorStops` is provided, `colorStops[i]` is a number from 0.0 to 1.0
  /// that specifies where `color[i]` begins in the gradient. If `colorStops` is
  /// not provided, then only two stops, at 0.0 and 1.0, are implied (and
  /// `color` must therefore only have two entries).
  ///
  /// The behavior before and after the radius is described by the `tileMode`
  /// argument. For details, see the [TileMode] enum.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_radial.png)
  ///
  /// If `center`, `radius`, `colors`, or `tileMode` are null, or if `colors` or
  /// `colorStops` contain null values, this constructor will throw a
  /// [NoSuchMethodError].
  ///
  /// If `matrix4` is provided, the gradient fill will be transformed by the
  /// specified 4x4 matrix relative to the local coordinate system. `matrix4` must
  /// be a column-major matrix packed into a list of 16 values.
  ///
  /// If `focal` is provided and not equal to `center` and `focalRadius` is
  /// provided and not equal to 0.0, the generated shader will be a two point
  /// conical radial gradient, with `focal` being the center of the focal
  /// circle and `focalRadius` being the radius of that circle. If `focal` is
  /// provided and not equal to `center`, at least one of the two offsets must
  /// not be equal to [Offset.zero].
  Gradient.radial(
    Offset center,
    double radius,
    List<Color> colors, [
    List<double>? colorStops,
    TileMode tileMode = TileMode.clamp,
    Float64List? matrix4,
    Offset? focal,
    double focalRadius = 0.0
  ]) : assert(_offsetIsValid(center)),
       assert(colors != null),
       assert(tileMode != null),
       assert(matrix4 == null || _matrix4IsValid(matrix4)),
       super._() {
    _validateColorStops(colors, colorStops);
    final Int32List colorsBuffer = _encodeColorList(colors);
    final Float32List? colorStopsBuffer = colorStops == null ? null : Float32List.fromList(colorStops);

    // If focal is null or focal radius is null, this should be treated as a regular radial gradient
    // If focal == center and the focal radius is 0.0, it's still a regular radial gradient
    if (focal == null || (focal == center && focalRadius == 0.0)) {
      _constructor();
      _initRadial(center.dx, center.dy, radius, colorsBuffer, colorStopsBuffer, tileMode.index, matrix4);
    } else {
      assert(center != Offset.zero || focal != Offset.zero); // will result in exception(s) in Skia side
      _constructor();
      _initConical(focal.dx, focal.dy, focalRadius, center.dx, center.dy, radius, colorsBuffer, colorStopsBuffer, tileMode.index, matrix4);
    }
  }
  void _initRadial(double centerX, double centerY, double radius, Int32List colors, Float32List? colorStops, int tileMode, Float64List? matrix4) native 'Gradient_initRadial';
  void _initConical(double startX, double startY, double startRadius, double endX, double endY, double endRadius, Int32List colors, Float32List? colorStops, int tileMode, Float64List? matrix4) native 'Gradient_initTwoPointConical';

  /// Creates a sweep gradient centered at `center` that starts at `startAngle`
  /// and ends at `endAngle`.
  ///
  /// `startAngle` and `endAngle` should be provided in radians, with zero
  /// radians being the horizontal line to the right of the `center` and with
  /// positive angles going clockwise around the `center`.
  ///
  /// If `colorStops` is provided, `colorStops[i]` is a number from 0.0 to 1.0
  /// that specifies where `color[i]` begins in the gradient. If `colorStops` is
  /// not provided, then only two stops, at 0.0 and 1.0, are implied (and
  /// `color` must therefore only have two entries).
  ///
  /// The behavior before `startAngle` and after `endAngle` is described by the
  /// `tileMode` argument. For details, see the [TileMode] enum.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_sweep.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_sweep.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_sweep.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_sweep.png)
  ///
  /// If `center`, `colors`, `tileMode`, `startAngle`, or `endAngle` are null,
  /// or if `colors` or `colorStops` contain null values, this constructor will
  /// throw a [NoSuchMethodError].
  ///
  /// If `matrix4` is provided, the gradient fill will be transformed by the
  /// specified 4x4 matrix relative to the local coordinate system. `matrix4` must
  /// be a column-major matrix packed into a list of 16 values.
  Gradient.sweep(
    Offset center,
    List<Color> colors, [
    List<double>? colorStops,
    TileMode tileMode = TileMode.clamp,
    double startAngle = 0.0,
    double endAngle = math.pi * 2,
    Float64List? matrix4,
  ]) : assert(_offsetIsValid(center)),
       assert(colors != null),
       assert(tileMode != null),
       assert(startAngle != null),
       assert(endAngle != null),
       assert(startAngle < endAngle),
       assert(matrix4 == null || _matrix4IsValid(matrix4)),
       super._() {
    _validateColorStops(colors, colorStops);
    final Int32List colorsBuffer = _encodeColorList(colors);
    final Float32List? colorStopsBuffer = colorStops == null ? null : Float32List.fromList(colorStops);
    _constructor();
    _initSweep(center.dx, center.dy, colorsBuffer, colorStopsBuffer, tileMode.index, startAngle, endAngle, matrix4);
  }
  void _initSweep(double centerX, double centerY, Int32List colors, Float32List? colorStops, int tileMode, double startAngle, double endAngle, Float64List? matrix) native 'Gradient_initSweep';

  static void _validateColorStops(List<Color> colors, List<double>? colorStops) {
    if (colorStops == null) {
      if (colors.length != 2)
        throw ArgumentError('"colors" must have length 2 if "colorStops" is omitted.');
    } else {
      if (colors.length != colorStops.length)
        throw ArgumentError('"colors" and "colorStops" arguments must have equal length.');
    }
  }
}

/// A shader (as used by [Paint.shader]) that tiles an image.
class ImageShader extends Shader {
  /// Creates an image-tiling shader. The first argument specifies the image to
  /// tile. The second and third arguments specify the [TileMode] for the x
  /// direction and y direction respectively. The fourth argument gives the
  /// matrix to apply to the effect. All the arguments are required and must not
  /// be null, except for [filterQuality]. If [filterQuality] is not specified
  /// at construction time it will be deduced from the environment where it is used,
  /// such as from [Paint.filterQuality].
  @pragma('vm:entry-point')
  ImageShader(Image image, TileMode tmx, TileMode tmy, Float64List matrix4, {
    FilterQuality? filterQuality,
  }) :
    assert(image != null), // image is checked on the engine side
    assert(tmx != null),
    assert(tmy != null),
    assert(matrix4 != null),
    super._() {
    if (matrix4.length != 16)
      throw ArgumentError('"matrix4" must have 16 entries.');
    _constructor();
    _initWithImage(image._image, tmx.index, tmy.index, filterQuality?.index ?? -1, matrix4);
  }
  void _constructor() native 'ImageShader_constructor';
  void _initWithImage(_Image image, int tmx, int tmy, int filterQualityIndex, Float64List matrix4) native 'ImageShader_initWithImage';
}

/// An instance of [FragmentProgram] creates [Shader] objects (as used by [Paint.shader]) that run SPIR-V code.
///
/// This API is in beta and does not yet work on web.
/// See https://github.com/flutter/flutter/projects/207 for roadmap.
///
/// [A current specification of valid SPIR-V is here.](https://github.com/flutter/engine/blob/main/lib/spirv/README.md)
///
class FragmentProgram extends NativeFieldWrapperClass1 {

  /// Creates a fragment program from SPIR-V byte data as an input.
  ///
  /// One instance should be created per SPIR-V input. The constructed object
  /// should then be reused via the [shader] method to create [Shader] objects
  /// that can be used by [Shader.paint].
  ///
  /// [A current specification of valid SPIR-V is here.](https://github.com/flutter/engine/blob/master/lib/spirv/README.md)
  /// SPIR-V not meeting this specification will throw an exception.
  static Future<FragmentProgram> compile({
    required ByteBuffer spirv,
    bool debugPrint = false,
  }) {
    // Delay compilation without creating a timer, which interacts poorly with the
    // flutter test framework. See: https://github.com/flutter/flutter/issues/104084
    return Future<FragmentProgram>.microtask(() => FragmentProgram._(spirv: spirv, debugPrint: debugPrint));
  }

  @pragma('vm:entry-point')
  FragmentProgram._({
    required ByteBuffer spirv,
    bool debugPrint = false,
  }) {
    _constructor();
    final spv.TranspileResult result = spv.transpile(
      spirv,
      spv.TargetLanguage.sksl,
    );
    _init(result.src, debugPrint);
    _uniformFloatCount = result.uniformFloatCount;
    _samplerCount = result.samplerCount;
  }

  late final int _uniformFloatCount;
  late final int _samplerCount;

  void _constructor() native 'FragmentProgram_constructor';
  void _init(String sksl, bool debugPrint) native 'FragmentProgram_init';

  /// Constructs a [Shader] object suitable for use by [Paint.shader] with
  /// the given uniforms.
  ///
  /// This method is suitable to be called synchronously within a widget's
  /// `build` method or from [CustomPainter.paint].
  ///
  /// `floatUniforms` can be passed optionally to initialize the shader's
  /// uniforms. If they are not set they will each default to 0.
  ///
  /// When initializing `floatUniforms`, the length of float uniforms must match
  /// the total number of floats defined as uniforms in the shader, or an
  /// [ArgumentError] will be thrown. Details are below.
  ///
  /// Consider the following snippit of GLSL code.
  ///
  /// ```
  /// layout (location = 0) uniform float a;
  /// layout (location = 1) uniform vec2 b;
  /// layout (location = 2) uniform vec3 c;
  /// layout (location = 3) uniform mat2x2 d;
  /// ```
  ///
  /// When compiled to SPIR-V and provided to the constructor, `floatUniforms`
  /// must have a length of 10. One per float-component of each uniform.
  ///
  /// `program.shader(floatUniforms: Float32List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));`
  ///
  /// The uniforms will be set as follows:
  ///
  /// a: 1
  /// b: [2, 3]
  /// c: [4, 5, 6]
  /// d: [7, 8, 9, 10] // 2x2 matrix in column-major order
  ///
  /// `imageSamplers` must also be sized correctly, matching the number of UniformConstant
  /// variables of type SampledImage specified in the SPIR-V code.
  ///
  /// Consider the following snippit of GLSL code.
  ///
  /// ```
  /// layout (location = 0) uniform sampler2D a;
  /// layout (location = 1) uniform sampler2D b;
  /// ```
  ///
  /// After being compiled to SPIR-V  `imageSamplers` must have a length
  /// of 2.
  ///
  /// Once a [Shader] is built, uniform values cannot be changed. Instead,
  /// [shader] must be called again with new uniform values.
  Shader shader({
    Float32List? floatUniforms,
    List<ImageShader>? samplerUniforms,
  }) {
    if (floatUniforms == null) {
      floatUniforms = Float32List(_uniformFloatCount);
    }
    if (floatUniforms.length != _uniformFloatCount) {
      throw ArgumentError(
        'floatUniforms size: ${floatUniforms.length} must match given shader uniform count: $_uniformFloatCount.');
    }
    if (_samplerCount > 0 && (samplerUniforms == null || samplerUniforms.length != _samplerCount)) {
      throw ArgumentError('samplerUniforms must have length $_samplerCount');
    }
    if (samplerUniforms == null) {
      samplerUniforms = <ImageShader>[];
    } else {
      samplerUniforms = <ImageShader>[...samplerUniforms];
    }
    final _FragmentShader shader = _FragmentShader(
        this, Float32List.fromList(floatUniforms), samplerUniforms);
    _shader(shader, floatUniforms, samplerUniforms);
    return shader;
  }

  void _shader(
    _FragmentShader shader,
    Float32List floatUniforms,
    List<ImageShader> samplerUniforms,
  ) native 'FragmentProgram_shader';
}

@pragma('vm:entry-point')
class _FragmentShader extends Shader {
  /// This class is created by the engine and should not be instantiated
  /// or extended directly.
  ///
  /// To create a [_FragmentShader], use a [FragmentProgram].
  _FragmentShader(
    this._builder,
    this._floatUniforms,
    this._samplerUniforms,
  ) : super._();

  final FragmentProgram _builder;
  final Float32List _floatUniforms;
  final List<ImageShader> _samplerUniforms;

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is _FragmentShader
        && other._builder == _builder
        && _listEquals<double>(other._floatUniforms, _floatUniforms)
        && _listEquals<ImageShader>(other._samplerUniforms, _samplerUniforms);
  }

  @override
  int get hashCode => Object.hash(_builder, Object.hashAll(_floatUniforms), Object.hashAll(_samplerUniforms));
}

/// Defines how a list of points is interpreted when drawing a set of triangles.
///
/// Used by [Canvas.drawVertices].
// These enum values must be kept in sync with SkVertices::VertexMode.
enum VertexMode {
  /// Draw each sequence of three points as the vertices of a triangle.
  triangles,

  /// Draw each sliding window of three points as the vertices of a triangle.
  triangleStrip,

  /// Draw the first point and each sliding window of two points as the vertices of a triangle.
  triangleFan,
}

/// A set of vertex data used by [Canvas.drawVertices].
class Vertices extends NativeFieldWrapperClass1 {
  /// Creates a set of vertex data for use with [Canvas.drawVertices].
  ///
  /// The [mode] and [positions] parameters must not be null.
  /// The [positions] parameter is a list of triangular mesh vertices(xy).
  ///
  /// If the [textureCoordinates] or [colors] parameters are provided, they must
  /// be the same length as [positions].
  ///
  /// The [textureCoordinates] parameter is used to cutout
  /// the image set in the image shader.
  /// The cut part is applied to the triangular mesh.
  /// Note that the [textureCoordinates] are the coordinates on the image.
  ///
  /// If the [indices] parameter is provided, all values in the list must be
  /// valid index values for [positions].
  /// e.g. The [indices] parameter for a simple triangle is [0,1,2].
  Vertices(
    VertexMode mode,
    List<Offset> positions, {
    List<Offset>? textureCoordinates,
    List<Color>? colors,
    List<int>? indices,
  }) : assert(mode != null),
       assert(positions != null) {
    if (textureCoordinates != null && textureCoordinates.length != positions.length)
      throw ArgumentError('"positions" and "textureCoordinates" lengths must match.');
    if (colors != null && colors.length != positions.length)
      throw ArgumentError('"positions" and "colors" lengths must match.');
    if (indices != null && indices.any((int i) => i < 0 || i >= positions.length))
      throw ArgumentError('"indices" values must be valid indices in the positions list.');

    final Float32List encodedPositions = _encodePointList(positions);
    final Float32List? encodedTextureCoordinates = (textureCoordinates != null)
      ? _encodePointList(textureCoordinates)
      : null;
    final Int32List? encodedColors = colors != null
      ? _encodeColorList(colors)
      : null;
    final Uint16List? encodedIndices = indices != null
      ? Uint16List.fromList(indices)
      : null;

    if (!_init(this, mode.index, encodedPositions, encodedTextureCoordinates, encodedColors, encodedIndices))
      throw ArgumentError('Invalid configuration for vertices.');
  }

  /// Creates a set of vertex data for use with [Canvas.drawVertices], directly
  /// using the encoding methods of [new Vertices].
  /// Note that this constructor uses raw typed data lists,
  /// so it runs faster than the [Vertices()] constructor
  /// because it doesn't require any conversion from Dart lists.
  ///
  /// The [mode] parameter must not be null.
  ///
  /// The [positions] parameter is a list of triangular mesh vertices and
  /// is interpreted as a list of repeated pairs of x,y coordinates.
  /// It must not be null.
  ///
  /// The [textureCoordinates] list is interpreted as a list of repeated pairs
  /// of x,y coordinates, and must be the same length of [positions] if it
  /// is not null.
  /// The [textureCoordinates] parameter is used to cutout
  /// the image set in the image shader.
  /// The cut part is applied to the triangular mesh.
  /// Note that the [textureCoordinates] are the coordinates on the image.
  ///
  /// The [colors] list is interpreted as a list of ARGB encoded colors, similar
  /// to [Color.value]. It must be half length of [positions] if it is not
  /// null.
  ///
  /// If the [indices] list is provided, all values in the list must be
  /// valid index values for [positions].
  /// e.g. The [indices] parameter for a simple triangle is [0,1,2].
  Vertices.raw(
    VertexMode mode,
    Float32List positions, {
    Float32List? textureCoordinates,
    Int32List? colors,
    Uint16List? indices,
  }) : assert(mode != null),
       assert(positions != null) {
    if (textureCoordinates != null && textureCoordinates.length != positions.length)
      throw ArgumentError('"positions" and "textureCoordinates" lengths must match.');
    if (colors != null && colors.length * 2 != positions.length)
      throw ArgumentError('"positions" and "colors" lengths must match.');
    if (indices != null && indices.any((int i) => i < 0 || i >= positions.length))
      throw ArgumentError('"indices" values must be valid indices in the positions list.');

    if (!_init(this, mode.index, positions, textureCoordinates, colors, indices))
      throw ArgumentError('Invalid configuration for vertices.');
  }

  bool _init(Vertices outVertices,
             int mode,
             Float32List positions,
             Float32List? textureCoordinates,
             Int32List? colors,
             Uint16List? indices) native 'Vertices_init';
}

/// Defines how a list of points is interpreted when drawing a set of points.
///
/// Used by [Canvas.drawPoints].
// These enum values must be kept in sync with SkCanvas::PointMode.
enum PointMode {
  /// Draw each point separately.
  ///
  /// If the [Paint.strokeCap] is [StrokeCap.round], then each point is drawn
  /// as a circle with the diameter of the [Paint.strokeWidth], filled as
  /// described by the [Paint] (ignoring [Paint.style]).
  ///
  /// Otherwise, each point is drawn as an axis-aligned square with sides of
  /// length [Paint.strokeWidth], filled as described by the [Paint] (ignoring
  /// [Paint.style]).
  points,

  /// Draw each sequence of two points as a line segment.
  ///
  /// If the number of points is odd, then the last point is ignored.
  ///
  /// The lines are stroked as described by the [Paint] (ignoring
  /// [Paint.style]).
  lines,

  /// Draw the entire sequence of point as one line.
  ///
  /// The lines are stroked as described by the [Paint] (ignoring
  /// [Paint.style]).
  polygon,
}

/// Defines how a new clip region should be merged with the existing clip
/// region.
///
/// Used by [Canvas.clipRect].
enum ClipOp {
  /// Subtract the new region from the existing region.
  difference,

  /// Intersect the new region from the existing region.
  intersect,
}

/// An interface for recording graphical operations.
///
/// [Canvas] objects are used in creating [Picture] objects, which can
/// themselves be used with a [SceneBuilder] to build a [Scene]. In
/// normal usage, however, this is all handled by the framework.
///
/// A canvas has a current transformation matrix which is applied to all
/// operations. Initially, the transformation matrix is the identity transform.
/// It can be modified using the [translate], [scale], [rotate], [skew],
/// and [transform] methods.
///
/// A canvas also has a current clip region which is applied to all operations.
/// Initially, the clip region is infinite. It can be modified using the
/// [clipRect], [clipRRect], and [clipPath] methods.
///
/// The current transform and clip can be saved and restored using the stack
/// managed by the [save], [saveLayer], and [restore] methods.
class Canvas extends NativeFieldWrapperClass1 {
  /// Creates a canvas for recording graphical operations into the
  /// given picture recorder.
  ///
  /// Graphical operations that affect pixels entirely outside the given
  /// `cullRect` might be discarded by the implementation. However, the
  /// implementation might draw outside these bounds if, for example, a command
  /// draws partially inside and outside the `cullRect`. To ensure that pixels
  /// outside a given region are discarded, consider using a [clipRect]. The
  /// `cullRect` is optional; by default, all operations are kept.
  ///
  /// To end the recording, call [PictureRecorder.endRecording] on the
  /// given recorder.
  @pragma('vm:entry-point')
  Canvas(PictureRecorder recorder, [ Rect? cullRect ]) : assert(recorder != null) {
    if (recorder.isRecording)
      throw ArgumentError('"recorder" must not already be associated with another Canvas.');
    _recorder = recorder;
    _recorder!._canvas = this;
    cullRect ??= Rect.largest;
    _constructor(recorder, cullRect.left, cullRect.top, cullRect.right, cullRect.bottom);
  }
  void _constructor(PictureRecorder recorder,
                    double left,
                    double top,
                    double right,
                    double bottom) native 'Canvas_constructor';

  // The underlying Skia SkCanvas is owned by the PictureRecorder used to create this Canvas.
  // The Canvas holds a reference to the PictureRecorder to prevent the recorder from being
  // garbage collected until PictureRecorder.endRecording is called.
  PictureRecorder? _recorder;

  /// Saves a copy of the current transform and clip on the save stack.
  ///
  /// Call [restore] to pop the save stack.
  ///
  /// See also:
  ///
  ///  * [saveLayer], which does the same thing but additionally also groups the
  ///    commands done until the matching [restore].
  void save() native 'Canvas_save';

  /// Saves a copy of the current transform and clip on the save stack, and then
  /// creates a new group which subsequent calls will become a part of. When the
  /// save stack is later popped, the group will be flattened into a layer and
  /// have the given `paint`'s [Paint.colorFilter] and [Paint.blendMode]
  /// applied.
  ///
  /// This lets you create composite effects, for example making a group of
  /// drawing commands semi-transparent. Without using [saveLayer], each part of
  /// the group would be painted individually, so where they overlap would be
  /// darker than where they do not. By using [saveLayer] to group them
  /// together, they can be drawn with an opaque color at first, and then the
  /// entire group can be made transparent using the [saveLayer]'s paint.
  ///
  /// Call [restore] to pop the save stack and apply the paint to the group.
  ///
  /// ## Using saveLayer with clips
  ///
  /// When a rectangular clip operation (from [clipRect]) is not axis-aligned
  /// with the raster buffer, or when the clip operation is not rectilinear
  /// (e.g. because it is a rounded rectangle clip created by [clipRRect] or an
  /// arbitrarily complicated path clip created by [clipPath]), the edge of the
  /// clip needs to be anti-aliased.
  ///
  /// If two draw calls overlap at the edge of such a clipped region, without
  /// using [saveLayer], the first drawing will be anti-aliased with the
  /// background first, and then the second will be anti-aliased with the result
  /// of blending the first drawing and the background. On the other hand, if
  /// [saveLayer] is used immediately after establishing the clip, the second
  /// drawing will cover the first in the layer, and thus the second alone will
  /// be anti-aliased with the background when the layer is clipped and
  /// composited (when [restore] is called).
  ///
  /// For example, this [CustomPainter.paint] method paints a clean white
  /// rounded rectangle:
  ///
  /// ```dart
  /// void paint(Canvas canvas, Size size) {
  ///   Rect rect = Offset.zero & size;
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(rect, 100.0, 100.0));
  ///   canvas.saveLayer(rect, Paint());
  ///   canvas.drawPaint(Paint()..color = Colors.red);
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  ///   canvas.restore();
  /// }
  /// ```
  ///
  /// On the other hand, this one renders a red outline, the result of the red
  /// paint being anti-aliased with the background at the clip edge, then the
  /// white paint being similarly anti-aliased with the background _including
  /// the clipped red paint_:
  ///
  /// ```dart
  /// void paint(Canvas canvas, Size size) {
  ///   // (this example renders poorly, prefer the example above)
  ///   Rect rect = Offset.zero & size;
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(rect, 100.0, 100.0));
  ///   canvas.drawPaint(Paint()..color = Colors.red);
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  /// }
  /// ```
  ///
  /// This point is moot if the clip only clips one draw operation. For example,
  /// the following paint method paints a pair of clean white rounded
  /// rectangles, even though the clips are not done on a separate layer:
  ///
  /// ```dart
  /// void paint(Canvas canvas, Size size) {
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(Offset.zero & (size / 2.0), 50.0, 50.0));
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(size.center(Offset.zero) & (size / 2.0), 50.0, 50.0));
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  /// }
  /// ```
  ///
  /// (Incidentally, rather than using [clipRRect] and [drawPaint] to draw
  /// rounded rectangles like this, prefer the [drawRRect] method. These
  /// examples are using [drawPaint] as a proxy for "complicated draw operations
  /// that will get clipped", to illustrate the point.)
  ///
  /// ## Performance considerations
  ///
  /// Generally speaking, [saveLayer] is relatively expensive.
  ///
  /// There are a several different hardware architectures for GPUs (graphics
  /// processing units, the hardware that handles graphics), but most of them
  /// involve batching commands and reordering them for performance. When layers
  /// are used, they cause the rendering pipeline to have to switch render
  /// target (from one layer to another). Render target switches can flush the
  /// GPU's command buffer, which typically means that optimizations that one
  /// could get with larger batching are lost. Render target switches also
  /// generate a lot of memory churn because the GPU needs to copy out the
  /// current frame buffer contents from the part of memory that's optimized for
  /// writing, and then needs to copy it back in once the previous render target
  /// (layer) is restored.
  ///
  /// See also:
  ///
  ///  * [save], which saves the current state, but does not create a new layer
  ///    for subsequent commands.
  ///  * [BlendMode], which discusses the use of [Paint.blendMode] with
  ///    [saveLayer].
  void saveLayer(Rect? bounds, Paint paint) {
    assert(paint != null);
    if (bounds == null) {
      _saveLayerWithoutBounds(paint._objects, paint._data);
    } else {
      assert(_rectIsValid(bounds));
      _saveLayer(bounds.left, bounds.top, bounds.right, bounds.bottom,
                 paint._objects, paint._data);
    }
  }
  void _saveLayerWithoutBounds(List<Object?>? paintObjects, ByteData paintData)
      native 'Canvas_saveLayerWithoutBounds';
  void _saveLayer(double left,
                  double top,
                  double right,
                  double bottom,
                  List<Object?>? paintObjects,
                  ByteData paintData) native 'Canvas_saveLayer';

  /// Pops the current save stack, if there is anything to pop.
  /// Otherwise, does nothing.
  ///
  /// Use [save] and [saveLayer] to push state onto the stack.
  ///
  /// If the state was pushed with with [saveLayer], then this call will also
  /// cause the new layer to be composited into the previous layer.
  void restore() native 'Canvas_restore';

  /// Returns the number of items on the save stack, including the
  /// initial state. This means it returns 1 for a clean canvas, and
  /// that each call to [save] and [saveLayer] increments it, and that
  /// each matching call to [restore] decrements it.
  ///
  /// This number cannot go below 1.
  int getSaveCount() native 'Canvas_getSaveCount';

  /// Add a translation to the current transform, shifting the coordinate space
  /// horizontally by the first argument and vertically by the second argument.
  void translate(double dx, double dy) native 'Canvas_translate';

  /// Add an axis-aligned scale to the current transform, scaling by the first
  /// argument in the horizontal direction and the second in the vertical
  /// direction.
  ///
  /// If [sy] is unspecified, [sx] will be used for the scale in both
  /// directions.
  void scale(double sx, [double? sy]) => _scale(sx, sy ?? sx);

  void _scale(double sx, double sy) native 'Canvas_scale';

  /// Add a rotation to the current transform. The argument is in radians clockwise.
  void rotate(double radians) native 'Canvas_rotate';

  /// Add an axis-aligned skew to the current transform, with the first argument
  /// being the horizontal skew in rise over run units clockwise around the
  /// origin, and the second argument being the vertical skew in rise over run
  /// units clockwise around the origin.
  void skew(double sx, double sy) native 'Canvas_skew';

  /// Multiply the current transform by the specified 4⨉4 transformation matrix
  /// specified as a list of values in column-major order.
  void transform(Float64List matrix4) {
    assert(matrix4 != null);
    if (matrix4.length != 16)
      throw ArgumentError('"matrix4" must have 16 entries.');
    _transform(matrix4);
  }
  void _transform(Float64List matrix4) native 'Canvas_transform';

  /// Returns the current transform including the combined result of all transform
  /// methods executed since the creation of this [Canvas] object, and respecting the
  /// save/restore history.
  ///
  /// Methods that can change the current transform include [translate], [scale],
  /// [rotate], [skew], and [transform]. The [restore] method can also modify
  /// the current transform by restoring it to the same value it had before its
  /// associated [save] or [saveLayer] call.
  Float64List getTransform() {
    final Float64List matrix4 = Float64List(16);
    _getTransform(matrix4);
    return matrix4;
  }
  void _getTransform(Float64List matrix4) native 'Canvas_getTransform';

  /// Reduces the clip region to the intersection of the current clip and the
  /// given rectangle.
  ///
  /// If [doAntiAlias] is true, then the clip will be anti-aliased.
  ///
  /// If multiple draw commands intersect with the clip boundary, this can result
  /// in incorrect blending at the clip boundary. See [saveLayer] for a
  /// discussion of how to address that.
  ///
  /// Use [ClipOp.difference] to subtract the provided rectangle from the
  /// current clip.
  void clipRect(Rect rect, { ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true }) {
    assert(_rectIsValid(rect));
    assert(clipOp != null);
    assert(doAntiAlias != null);
    _clipRect(rect.left, rect.top, rect.right, rect.bottom, clipOp.index, doAntiAlias);
  }
  void _clipRect(double left,
                 double top,
                 double right,
                 double bottom,
                 int clipOp,
                 bool doAntiAlias) native 'Canvas_clipRect';

  /// Reduces the clip region to the intersection of the current clip and the
  /// given rounded rectangle.
  ///
  /// If [doAntiAlias] is true, then the clip will be anti-aliased.
  ///
  /// If multiple draw commands intersect with the clip boundary, this can result
  /// in incorrect blending at the clip boundary. See [saveLayer] for a
  /// discussion of how to address that and some examples of using [clipRRect].
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    assert(_rrectIsValid(rrect));
    assert(doAntiAlias != null);
    _clipRRect(rrect._getValue32(), doAntiAlias);
  }
  void _clipRRect(Float32List rrect, bool doAntiAlias) native 'Canvas_clipRRect';

  /// Reduces the clip region to the intersection of the current clip and the
  /// given [Path].
  ///
  /// If [doAntiAlias] is true, then the clip will be anti-aliased.
  ///
  /// If multiple draw commands intersect with the clip boundary, this can result
  /// in incorrect blending at the clip boundary. See [saveLayer] for a
  /// discussion of how to address that.
  void clipPath(Path path, {bool doAntiAlias = true}) {
    assert(path != null); // path is checked on the engine side
    assert(doAntiAlias != null);
    _clipPath(path, doAntiAlias);
  }
  void _clipPath(Path path, bool doAntiAlias) native 'Canvas_clipPath';

  /// Returns the conservative bounds of the combined result of all clip methods
  /// executed within the current save stack of this [Canvas] object, as measured
  /// in the local coordinate space under which rendering operations are curretnly
  /// performed.
  ///
  /// The combined clip results are rounded out to an integer pixel boundary before
  /// they are transformed back into the local coordinate space which accounts for
  /// the pixel roundoff in rendering operations, particularly when antialiasing.
  /// Because the [Picture] may eventually be rendered into a scene within the
  /// context of transforming widgets or layers, the result may thus be overly
  /// conservative due to premature rounding. Using the [getDestinationClipBounds]
  /// method combined with the external transforms and rounding in the true device
  /// coordinate system will produce more accurate results, but this value may
  /// provide a more convenient approximation to compare rendering operations to
  /// the established clip.
  ///
  /// {@template dart.ui.canvas.conservativeClipBounds}
  /// The conservative estimate of the bounds is based on intersecting the bounds
  /// of each clip method that was executed with [ClipOp.intersect] and potentially
  /// ignoring any clip method that was executed with [ClipOp.difference]. The
  /// [ClipOp] argument is only present on the [clipRect] method.
  ///
  /// To understand how the bounds estimate can be conservative, consider the
  /// following two clip method calls:
  ///
  /// ```dart
  ///    clipPath(Path()
  ///      ..addRect(const Rect.fromLTRB(10, 10, 20, 20))
  ///      ..addRect(const Rect.fromLTRB(80, 80, 100, 100)));
  ///    clipPath(Path()
  ///      ..addRect(const Rect.fromLTRB(80, 10, 100, 20))
  ///      ..addRect(const Rect.fromLTRB(10, 80, 20, 100)));
  /// ```
  ///
  /// After executing both of those calls there is no area left in which to draw
  /// because the two paths have no overlapping regions. But, in this case,
  /// [getClipBounds] would return a rectangle from `10, 10` to `100, 100` because it
  /// only intersects the bounds of the two path objects to obtain its conservative
  /// estimate.
  ///
  /// The clip bounds are not affected by the bounds of any enclosing
  /// [saveLayer] call as the engine does not currently guarantee the strict
  /// enforcement of those bounds during rendering.
  ///
  /// Methods that can change the current clip include [clipRect], [clipRRect],
  /// and [clipPath]. The [restore] method can also modify the current clip by
  /// restoring it to the same value it had before its associated [save] or
  /// [saveLayer] call.
  /// {@endtemplate}
  Rect getLocalClipBounds() {
    final Float64List bounds = Float64List(4);
    _getLocalClipBounds(bounds);
    return Rect.fromLTRB(bounds[0], bounds[1], bounds[2], bounds[3]);
  }
  void _getLocalClipBounds(Float64List bounds) native 'Canvas_getLocalClipBounds';

  /// Returns the conservative bounds of the combined result of all clip methods
  /// executed within the current save stack of this [Canvas] object, as measured
  /// in the destination coordinate space in which the [Picture] will be rendered.
  ///
  /// Unlike [getLocalClipBounds], the bounds are not rounded out to an integer
  /// pixel boundary as the Destination coordinate space may not represent pixels
  /// if the [Picture] being constructed will be further transformed when it is
  /// rendered or added to a scene. In order to determine the true pixels being
  /// affected, those external transforms should be applied first before rounding
  /// out the result to integer pixel boundaries. Most typically, [Picture] objects
  /// are rendered in a scene with a scale transform representing the Device Pixel
  /// Ratio.
  ///
  /// {@macro dart.ui.canvas.conservativeClipBounds}
  Rect getDestinationClipBounds() {
    final Float64List bounds = Float64List(4);
    _getDestinationClipBounds(bounds);
    return Rect.fromLTRB(bounds[0], bounds[1], bounds[2], bounds[3]);
  }
  void _getDestinationClipBounds(Float64List bounds) native 'Canvas_getDestinationClipBounds';

  /// Paints the given [Color] onto the canvas, applying the given
  /// [BlendMode], with the given color being the source and the background
  /// being the destination.
  void drawColor(Color color, BlendMode blendMode) {
    assert(color != null);
    assert(blendMode != null);
    _drawColor(color.value, blendMode.index);
  }
  void _drawColor(int color, int blendMode) native 'Canvas_drawColor';

  /// Draws a line between the given points using the given paint. The line is
  /// stroked, the value of the [Paint.style] is ignored for this call.
  ///
  /// The `p1` and `p2` arguments are interpreted as offsets from the origin.
  void drawLine(Offset p1, Offset p2, Paint paint) {
    assert(_offsetIsValid(p1));
    assert(_offsetIsValid(p2));
    assert(paint != null);
    _drawLine(p1.dx, p1.dy, p2.dx, p2.dy, paint._objects, paint._data);
  }
  void _drawLine(double x1,
                 double y1,
                 double x2,
                 double y2,
                 List<Object?>? paintObjects,
                 ByteData paintData) native 'Canvas_drawLine';

  /// Fills the canvas with the given [Paint].
  ///
  /// To fill the canvas with a solid color and blend mode, consider
  /// [drawColor] instead.
  void drawPaint(Paint paint) {
    assert(paint != null);
    _drawPaint(paint._objects, paint._data);
  }
  void _drawPaint(List<Object?>? paintObjects, ByteData paintData) native 'Canvas_drawPaint';

  /// Draws a rectangle with the given [Paint]. Whether the rectangle is filled
  /// or stroked (or both) is controlled by [Paint.style].
  void drawRect(Rect rect, Paint paint) {
    assert(_rectIsValid(rect));
    assert(paint != null);
    _drawRect(rect.left, rect.top, rect.right, rect.bottom,
              paint._objects, paint._data);
  }
  void _drawRect(double left,
                 double top,
                 double right,
                 double bottom,
                 List<Object?>? paintObjects,
                 ByteData paintData) native 'Canvas_drawRect';

  /// Draws a rounded rectangle with the given [Paint]. Whether the rectangle is
  /// filled or stroked (or both) is controlled by [Paint.style].
  void drawRRect(RRect rrect, Paint paint) {
    assert(_rrectIsValid(rrect));
    assert(paint != null);
    _drawRRect(rrect._getValue32(), paint._objects, paint._data);
  }
  void _drawRRect(Float32List rrect,
                  List<Object?>? paintObjects,
                  ByteData paintData) native 'Canvas_drawRRect';

  /// Draws a shape consisting of the difference between two rounded rectangles
  /// with the given [Paint]. Whether this shape is filled or stroked (or both)
  /// is controlled by [Paint.style].
  ///
  /// This shape is almost but not quite entirely unlike an annulus.
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    assert(_rrectIsValid(outer));
    assert(_rrectIsValid(inner));
    assert(paint != null);
    _drawDRRect(outer._getValue32(), inner._getValue32(), paint._objects, paint._data);
  }
  void _drawDRRect(Float32List outer,
                   Float32List inner,
                   List<Object?>? paintObjects,
                   ByteData paintData) native 'Canvas_drawDRRect';

  /// Draws an axis-aligned oval that fills the given axis-aligned rectangle
  /// with the given [Paint]. Whether the oval is filled or stroked (or both) is
  /// controlled by [Paint.style].
  void drawOval(Rect rect, Paint paint) {
    assert(_rectIsValid(rect));
    assert(paint != null);
    _drawOval(rect.left, rect.top, rect.right, rect.bottom,
              paint._objects, paint._data);
  }
  void _drawOval(double left,
                 double top,
                 double right,
                 double bottom,
                 List<Object?>? paintObjects,
                 ByteData paintData) native 'Canvas_drawOval';

  /// Draws a circle centered at the point given by the first argument and
  /// that has the radius given by the second argument, with the [Paint] given in
  /// the third argument. Whether the circle is filled or stroked (or both) is
  /// controlled by [Paint.style].
  void drawCircle(Offset c, double radius, Paint paint) {
    assert(_offsetIsValid(c));
    assert(paint != null);
    _drawCircle(c.dx, c.dy, radius, paint._objects, paint._data);
  }
  void _drawCircle(double x,
                   double y,
                   double radius,
                   List<Object?>? paintObjects,
                   ByteData paintData) native 'Canvas_drawCircle';

  /// Draw an arc scaled to fit inside the given rectangle.
  ///
  /// It starts from `startAngle` radians around the oval up to
  /// `startAngle` + `sweepAngle` radians around the oval, with zero radians
  /// being the point on the right hand side of the oval that crosses the
  /// horizontal line that intersects the center of the rectangle and with positive
  /// angles going clockwise around the oval. If `useCenter` is true, the arc is
  /// closed back to the center, forming a circle sector. Otherwise, the arc is
  /// not closed, forming a circle segment.
  ///
  /// This method is optimized for drawing arcs and should be faster than [Path.arcTo].
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint) {
    assert(_rectIsValid(rect));
    assert(paint != null);
    _drawArc(rect.left, rect.top, rect.right, rect.bottom, startAngle,
             sweepAngle, useCenter, paint._objects, paint._data);
  }
  void _drawArc(double left,
                double top,
                double right,
                double bottom,
                double startAngle,
                double sweepAngle,
                bool useCenter,
                List<Object?>? paintObjects,
                ByteData paintData) native 'Canvas_drawArc';

  /// Draws the given [Path] with the given [Paint].
  ///
  /// Whether this shape is filled or stroked (or both) is controlled by
  /// [Paint.style]. If the path is filled, then sub-paths within it are
  /// implicitly closed (see [Path.close]).
  void drawPath(Path path, Paint paint) {
    assert(path != null); // path is checked on the engine side
    assert(paint != null);
    _drawPath(path, paint._objects, paint._data);
  }
  void _drawPath(Path path,
                 List<Object?>? paintObjects,
                 ByteData paintData) native 'Canvas_drawPath';

  /// Draws the given [Image] into the canvas with its top-left corner at the
  /// given [Offset]. The image is composited into the canvas using the given [Paint].
  void drawImage(Image image, Offset offset, Paint paint) {
    assert(image != null); // image is checked on the engine side
    assert(_offsetIsValid(offset));
    assert(paint != null);
    _drawImage(image._image, offset.dx, offset.dy, paint._objects, paint._data, paint.filterQuality.index);
  }
  void _drawImage(_Image image,
                  double x,
                  double y,
                  List<Object?>? paintObjects,
                  ByteData paintData,
                  int filterQualityIndex) native 'Canvas_drawImage';

  /// Draws the subset of the given image described by the `src` argument into
  /// the canvas in the axis-aligned rectangle given by the `dst` argument.
  ///
  /// This might sample from outside the `src` rect by up to half the width of
  /// an applied filter.
  ///
  /// Multiple calls to this method with different arguments (from the same
  /// image) can be batched into a single call to [drawAtlas] to improve
  /// performance.
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    assert(image != null); // image is checked on the engine side
    assert(_rectIsValid(src));
    assert(_rectIsValid(dst));
    assert(paint != null);
    _drawImageRect(image._image,
                   src.left,
                   src.top,
                   src.right,
                   src.bottom,
                   dst.left,
                   dst.top,
                   dst.right,
                   dst.bottom,
                   paint._objects,
                   paint._data,
                   paint.filterQuality.index);
  }
  void _drawImageRect(_Image image,
                      double srcLeft,
                      double srcTop,
                      double srcRight,
                      double srcBottom,
                      double dstLeft,
                      double dstTop,
                      double dstRight,
                      double dstBottom,
                      List<Object?>? paintObjects,
                      ByteData paintData,
                      int filterQualityIndex) native 'Canvas_drawImageRect';

  /// Draws the given [Image] into the canvas using the given [Paint].
  ///
  /// The image is drawn in nine portions described by splitting the image by
  /// drawing two horizontal lines and two vertical lines, where the `center`
  /// argument describes the rectangle formed by the four points where these
  /// four lines intersect each other. (This forms a 3-by-3 grid of regions,
  /// the center region being described by the `center` argument.)
  ///
  /// The four regions in the corners are drawn, without scaling, in the four
  /// corners of the destination rectangle described by `dst`. The remaining
  /// five regions are drawn by stretching them to fit such that they exactly
  /// cover the destination rectangle while maintaining their relative
  /// positions.
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    assert(image != null); // image is checked on the engine side
    assert(_rectIsValid(center));
    assert(_rectIsValid(dst));
    assert(paint != null);
    _drawImageNine(image._image,
                   center.left,
                   center.top,
                   center.right,
                   center.bottom,
                   dst.left,
                   dst.top,
                   dst.right,
                   dst.bottom,
                   paint._objects,
                   paint._data,
                   paint.filterQuality.index);
  }
  void _drawImageNine(_Image image,
                      double centerLeft,
                      double centerTop,
                      double centerRight,
                      double centerBottom,
                      double dstLeft,
                      double dstTop,
                      double dstRight,
                      double dstBottom,
                      List<Object?>? paintObjects,
                      ByteData paintData,
                      int filterQualityIndex) native 'Canvas_drawImageNine';

  /// Draw the given picture onto the canvas. To create a picture, see
  /// [PictureRecorder].
  void drawPicture(Picture picture) {
    assert(picture != null); // picture is checked on the engine side
    _drawPicture(picture);
  }
  void _drawPicture(Picture picture) native 'Canvas_drawPicture';

  /// Draws the text in the given [Paragraph] into this canvas at the given
  /// [Offset].
  ///
  /// The [Paragraph] object must have had [Paragraph.layout] called on it
  /// first.
  ///
  /// To align the text, set the `textAlign` on the [ParagraphStyle] object
  /// passed to the [new ParagraphBuilder] constructor. For more details see
  /// [TextAlign] and the discussion at [new ParagraphStyle].
  ///
  /// If the text is left aligned or justified, the left margin will be at the
  /// position specified by the `offset` argument's [Offset.dx] coordinate.
  ///
  /// If the text is right aligned or justified, the right margin will be at the
  /// position described by adding the [ParagraphConstraints.width] given to
  /// [Paragraph.layout], to the `offset` argument's [Offset.dx] coordinate.
  ///
  /// If the text is centered, the centering axis will be at the position
  /// described by adding half of the [ParagraphConstraints.width] given to
  /// [Paragraph.layout], to the `offset` argument's [Offset.dx] coordinate.
  void drawParagraph(Paragraph paragraph, Offset offset) {
    assert(paragraph != null);
    assert(_offsetIsValid(offset));
    assert(!paragraph._needsLayout);
    paragraph._paint(this, offset.dx, offset.dy);
  }

  /// Draws a sequence of points according to the given [PointMode].
  ///
  /// The `points` argument is interpreted as offsets from the origin.
  ///
  /// See also:
  ///
  ///  * [drawRawPoints], which takes `points` as a [Float32List] rather than a
  ///    [List<Offset>].
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    assert(pointMode != null);
    assert(points != null);
    assert(paint != null);
    _drawPoints(paint._objects, paint._data, pointMode.index, _encodePointList(points));
  }

  /// Draws a sequence of points according to the given [PointMode].
  ///
  /// The `points` argument is interpreted as a list of pairs of floating point
  /// numbers, where each pair represents an x and y offset from the origin.
  ///
  /// See also:
  ///
  ///  * [drawPoints], which takes `points` as a [List<Offset>] rather than a
  ///    [List<Float32List>].
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    assert(pointMode != null);
    assert(points != null);
    assert(paint != null);
    if (points.length % 2 != 0)
      throw ArgumentError('"points" must have an even number of values.');
    _drawPoints(paint._objects, paint._data, pointMode.index, points);
  }

  void _drawPoints(List<Object?>? paintObjects,
                   ByteData paintData,
                   int pointMode,
                   Float32List points) native 'Canvas_drawPoints';

  /// Draws the set of [Vertices] onto the canvas.
  ///
  /// The [blendMode] parameter is used to control how the colors in
  /// the [vertices] are combined with the colors in the [paint].
  /// If there are no colors specified in [vertices] then the [blendMode] has
  /// no effect. If there are colors in the [vertices],
  /// then the color taken from the [Shader] or [Color] in the [paint] is
  /// blended with the colors specified in the [vertices] using
  /// the [blendMode] parameter.
  /// For purposes of this blending,
  /// the colors from the [paint] are considered the source and the colors from
  /// the [vertices] are considered the destination.
  ///
  /// All parameters must not be null.
  ///
  /// See also:
  ///   * [new Vertices], which creates a set of vertices to draw on the canvas.
  ///   * [Vertices.raw], which creates the vertices using typed data lists
  ///     rather than unencoded lists.
  ///   * [paint], Image shaders can be used to draw images on a triangular mesh.
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {

    assert(vertices != null); // vertices is checked on the engine side
    assert(paint != null);
    assert(blendMode != null);
    _drawVertices(vertices, blendMode.index, paint._objects, paint._data);
  }
  void _drawVertices(Vertices vertices,
                     int blendMode,
                     List<Object?>? paintObjects,
                     ByteData paintData) native 'Canvas_drawVertices';

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  ///
  /// This method allows for optimization when you want to draw many parts of an
  /// image onto the canvas, such as when using sprites or zooming. It is more efficient
  /// than using multiple calls to [drawImageRect] and provides more functionality
  /// to individually transform each image part by a separate rotation or scale and
  /// blend or modulate those parts with a solid color.
  ///
  /// The method takes a list of [Rect] objects that each define a piece of the
  /// [atlas] image to be drawn independently. Each [Rect] is associated with an
  /// [RSTransform] entry in the [transforms] list which defines the location,
  /// rotation, and (uniform) scale with which to draw that portion of the image.
  /// Each [Rect] can also be associated with an optional [Color] which will be
  /// composed with the associated image part using the [blendMode] before blending
  /// the result onto the canvas. The full operation can be broken down as:
  ///
  /// - Blend each rectangular portion of the image specified by an entry in the
  /// [rects] argument with its associated entry in the [colors] list using the
  /// [blendMode] argument (if a color is specified). In this part of the operation,
  /// the image part will be considered the source of the operation and the associated
  /// color will be considered the destination.
  /// - Blend the result from the first step onto the canvas using the translation,
  /// rotation, and scale properties expressed in the associated entry in the
  /// [transforms] list using the properties of the [Paint] object.
  ///
  /// If the first stage of the operation which blends each part of the image with
  /// a color is needed, then both the [colors] and [blendMode] arguments must
  /// not be null and there must be an entry in the [colors] list for each
  /// image part. If that stage is not needed, then the [colors] argument can
  /// be either null or an empty list and the [blendMode] argument may also be null.
  ///
  /// The optional [cullRect] argument can provide an estimate of the bounds of the
  /// coordinates rendered by all components of the atlas to be compared against
  /// the clip to quickly reject the operation if it does not intersect.
  ///
  /// An example usage to render many sprites from a single sprite atlas with no
  /// rotations or scales:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, <RSTransform>[
  ///       for (Sprite sprite in allSprites)
  ///         RSTransform.fromComponents(
  ///           rotation: 0.0,
  ///           scale: 1.0,
  ///           // Center of the sprite relative to its rect
  ///           anchorX: 5.0,
  ///           anchorY: 5.0,
  ///           // Location at which to draw the center of the sprite
  ///           translateX: sprite.centerX,
  ///           translateY: sprite.centerY,
  ///         ),
  ///     ], <Rect>[
  ///       for (Sprite sprite in allSprites)
  ///         Rect.fromLTWH(sprite.index * 10.0, 0.0, 10.0, 10.0),
  ///     ], null, null, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// Another example usage which renders sprites with an optional opacity and rotation:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  ///   int alpha;
  ///   double rotation;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, <RSTransform>[
  ///       for (Sprite sprite in allSprites)
  ///         RSTransform.fromComponents(
  ///           rotation: sprite.rotation,
  ///           scale: 1.0,
  ///           // Center of the sprite relative to its rect
  ///           anchorX: 5.0,
  ///           anchorY: 5.0,
  ///           // Location at which to draw the center of the sprite
  ///           translateX: sprite.centerX,
  ///           translateY: sprite.centerY,
  ///         ),
  ///     ], <Rect>[
  ///       for (Sprite sprite in allSprites)
  ///         Rect.fromLTWH(sprite.index * 10.0, 0.0, 10.0, 10.0),
  ///     ], <Color>[
  ///       for (Sprite sprite in allSprites)
  ///         Colors.white.withAlpha(sprite.alpha),
  ///     ], BlendMode.srcIn, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// The length of the [transforms] and [rects] lists must be equal and
  /// if the [colors] argument is not null then it must either be empty or
  /// have the same length as the other two lists.
  ///
  /// See also:
  ///
  ///  * [drawRawAtlas], which takes its arguments as typed data lists rather
  ///    than objects.
  void drawAtlas(Image atlas,
                 List<RSTransform> transforms,
                 List<Rect> rects,
                 List<Color>? colors,
                 BlendMode? blendMode,
                 Rect? cullRect,
                 Paint paint) {
    assert(atlas != null); // atlas is checked on the engine side
    assert(transforms != null);
    assert(rects != null);
    assert(colors == null || colors.isEmpty || blendMode != null);
    assert(paint != null);

    final int rectCount = rects.length;
    if (transforms.length != rectCount)
      throw ArgumentError('"transforms" and "rects" lengths must match.');
    if (colors != null && colors.isNotEmpty && colors.length != rectCount)
      throw ArgumentError('If non-null, "colors" length must match that of "transforms" and "rects".');

    final Float32List rstTransformBuffer = Float32List(rectCount * 4);
    final Float32List rectBuffer = Float32List(rectCount * 4);

    for (int i = 0; i < rectCount; ++i) {
      final int index0 = i * 4;
      final int index1 = index0 + 1;
      final int index2 = index0 + 2;
      final int index3 = index0 + 3;
      final RSTransform rstTransform = transforms[i];
      final Rect rect = rects[i];
      assert(_rectIsValid(rect));
      rstTransformBuffer[index0] = rstTransform.scos;
      rstTransformBuffer[index1] = rstTransform.ssin;
      rstTransformBuffer[index2] = rstTransform.tx;
      rstTransformBuffer[index3] = rstTransform.ty;
      rectBuffer[index0] = rect.left;
      rectBuffer[index1] = rect.top;
      rectBuffer[index2] = rect.right;
      rectBuffer[index3] = rect.bottom;
    }

    final Int32List? colorBuffer = (colors == null || colors.isEmpty) ? null : _encodeColorList(colors);
    final Float32List? cullRectBuffer = cullRect?._getValue32();
    final int qualityIndex = paint.filterQuality.index;

    _drawAtlas(
      paint._objects, paint._data, qualityIndex, atlas._image, rstTransformBuffer, rectBuffer,
      colorBuffer, (blendMode ?? BlendMode.src).index, cullRectBuffer
    );
  }

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  ///
  /// This method allows for optimization when you want to draw many parts of an
  /// image onto the canvas, such as when using sprites or zooming. It is more efficient
  /// than using multiple calls to [drawImageRect] and provides more functionality
  /// to individually transform each image part by a separate rotation or scale and
  /// blend or modulate those parts with a solid color. It is also more efficient
  /// than [drawAtlas] as the data in the arguments is already packed in a format
  /// that can be directly used by the rendering code.
  ///
  /// A full description of how this method uses its arguments to draw onto the
  /// canvas can be found in the description of the [drawAtlas] method.
  ///
  /// The [rstTransforms] argument is interpreted as a list of four-tuples, with
  /// each tuple being ([RSTransform.scos], [RSTransform.ssin],
  /// [RSTransform.tx], [RSTransform.ty]).
  ///
  /// The [rects] argument is interpreted as a list of four-tuples, with each
  /// tuple being ([Rect.left], [Rect.top], [Rect.right], [Rect.bottom]).
  ///
  /// The [colors] argument, which can be null, is interpreted as a list of
  /// 32-bit colors, with the same packing as [Color.value]. If the [colors]
  /// argument is not null then the [blendMode] argument must also not be null.
  ///
  /// An example usage to render many sprites from a single sprite atlas with no rotations
  /// or scales:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     // For best advantage, these lists should be cached and only specific
  ///     // entries updated when the sprite information changes. This code is
  ///     // illustrative of how to set up the data and not a recommendation for
  ///     // optimal usage.
  ///     Float32List rectList = Float32List(allSprites.length * 4);
  ///     Float32List transformList = Float32List(allSprites.length * 4);
  ///     for (int i = 0; i < allSprites.length; i++) {
  ///       final double rectX = sprite.spriteIndex * 10.0;
  ///       rectList[i * 4 + 0] = rectX;
  ///       rectList[i * 4 + 1] = 0.0;
  ///       rectList[i * 4 + 2] = rectX + 10.0;
  ///       rectList[i * 4 + 3] = 10.0;
  ///
  ///       // This example sets the RSTransform values directly for a common case of no
  ///       // rotations or scales and just a translation to position the atlas entry. For
  ///       // more complicated transforms one could use the RSTransform class to compute
  ///       // the necessary values or do the same math directly.
  ///       transformList[i * 4 + 0] = 1.0;
  ///       transformList[i * 4 + 1] = 0.0;
  ///       transformList[i * 4 + 2] = sprite.centerX - 5.0;
  ///       transformList[i * 4 + 3] = sprite.centerY - 5.0;
  ///     }
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, transformList, rectList, null, null, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// Another example usage which renders sprites with an optional opacity and rotation:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  ///   int alpha;
  ///   double rotation;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     // For best advantage, these lists should be cached and only specific
  ///     // entries updated when the sprite information changes. This code is
  ///     // illustrative of how to set up the data and not a recommendation for
  ///     // optimal usage.
  ///     Float32List rectList = Float32List(allSprites.length * 4);
  ///     Float32List transformList = Float32List(allSprites.length * 4);
  ///     Int32List colorList = Int32List(allSprites.length);
  ///     for (int i = 0; i < allSprites.length; i++) {
  ///       final double rectX = sprite.spriteIndex * 10.0;
  ///       rectList[i * 4 + 0] = rectX;
  ///       rectList[i * 4 + 1] = 0.0;
  ///       rectList[i * 4 + 2] = rectX + 10.0;
  ///       rectList[i * 4 + 3] = 10.0;
  ///
  ///       // This example uses an RSTransform object to compute the necessary values for
  ///       // the transform using a factory helper method because the sprites contain
  ///       // rotation values which are not trivial to work with. But if the math for the
  ///       // values falls out from other calculations on the sprites then the values could
  ///       // possibly be generated directly from the sprite update code.
  ///       final RSTransform transform = RSTransform.fromComponents(
  ///         rotation: sprite.rotation,
  ///         scale: 1.0,
  ///         // Center of the sprite relative to its rect
  ///         anchorX: 5.0,
  ///         anchorY: 5.0,
  ///         // Location at which to draw the center of the sprite
  ///         translateX: sprite.centerX,
  ///         translateY: sprite.centerY,
  ///       );
  ///       transformList[i * 4 + 0] = transform.scos;
  ///       transformList[i * 4 + 1] = transform.ssin;
  ///       transformList[i * 4 + 2] = transform.tx;
  ///       transformList[i * 4 + 3] = transform.ty;
  ///
  ///       // This example computes the color value directly, but one could also compute
  ///       // an actual Color object and use its Color.value getter for the same result.
  ///       // Since we are using BlendMode.srcIn, only the alpha component matters for
  ///       // these colors which makes this a simple shift operation.
  ///       colorList[i] = sprite.alpha << 24;
  ///     }
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, transformList, rectList, colorList, BlendMode.srcIn, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// See also:
  ///
  ///  * [drawAtlas], which takes its arguments as objects rather than typed
  ///    data lists.
  void drawRawAtlas(Image atlas,
                    Float32List rstTransforms,
                    Float32List rects,
                    Int32List? colors,
                    BlendMode? blendMode,
                    Rect? cullRect,
                    Paint paint) {
    assert(atlas != null); // atlas is checked on the engine side
    assert(rstTransforms != null);
    assert(rects != null);
    assert(colors == null || blendMode != null);
    assert(paint != null);

    final int rectCount = rects.length;
    if (rstTransforms.length != rectCount)
      throw ArgumentError('"rstTransforms" and "rects" lengths must match.');
    if (rectCount % 4 != 0)
      throw ArgumentError('"rstTransforms" and "rects" lengths must be a multiple of four.');
    if (colors != null && colors.length * 4 != rectCount)
      throw ArgumentError('If non-null, "colors" length must be one fourth the length of "rstTransforms" and "rects".');
    final int qualityIndex = paint.filterQuality.index;

    _drawAtlas(
      paint._objects, paint._data, qualityIndex, atlas._image, rstTransforms, rects,
      colors, (blendMode ?? BlendMode.src).index, cullRect?._getValue32()
    );
  }

  void _drawAtlas(List<Object?>? paintObjects,
                  ByteData paintData,
                  int filterQualityIndex,
                  _Image atlas,
                  Float32List rstTransforms,
                  Float32List rects,
                  Int32List? colors,
                  int blendMode,
                  Float32List? cullRect) native 'Canvas_drawAtlas';

  /// Draws a shadow for a [Path] representing the given material elevation.
  ///
  /// The `transparentOccluder` argument should be true if the occluding object
  /// is not opaque.
  ///
  /// The arguments must not be null.
  void drawShadow(Path path, Color color, double elevation, bool transparentOccluder) {
    assert(path != null); // path is checked on the engine side
    assert(color != null);
    assert(transparentOccluder != null);
    _drawShadow(path, color.value, elevation, transparentOccluder);
  }
  void _drawShadow(Path path,
                   int color,
                   double elevation,
                   bool transparentOccluder) native 'Canvas_drawShadow';
}

/// An object representing a sequence of recorded graphical operations.
///
/// To create a [Picture], use a [PictureRecorder].
///
/// A [Picture] can be placed in a [Scene] using a [SceneBuilder], via
/// the [SceneBuilder.addPicture] method. A [Picture] can also be
/// drawn into a [Canvas], using the [Canvas.drawPicture] method.
@pragma('vm:entry-point')
class Picture extends NativeFieldWrapperClass1 {
  /// This class is created by the engine, and should not be instantiated
  /// or extended directly.
  ///
  /// To create a [Picture], use a [PictureRecorder].
  @pragma('vm:entry-point')
  Picture._();

  /// Creates an image from this picture.
  ///
  /// The returned image will be `width` pixels wide and `height` pixels high.
  /// The picture is rasterized within the 0 (left), 0 (top), `width` (right),
  /// `height` (bottom) bounds. Content outside these bounds is clipped.
  ///
  /// Although the image is returned synchronously, the picture is actually
  /// rasterized the first time the image is drawn and then cached.
  Future<Image> toImage(int width, int height) {
    assert(!_disposed);
    if (width <= 0 || height <= 0)
      throw Exception('Invalid image dimensions.');
    return _futurize(
      (_Callback<Image?> callback) => _toImage(width, height, (_Image? image) {
        if (image == null) {
          callback(null);
        } else {
          callback(Image._(image));
        }
      }),
    );
  }

  String? _toImage(int width, int height, _Callback<_Image?> callback) native 'Picture_toImage';

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  void dispose() {
    assert(!_disposed);
    assert(() {
      _disposed = true;
      return true;
    }());
    _dispose();
  }

  void _dispose() native 'Picture_dispose';


  bool _disposed = false;
  /// Whether this reference to the underlying picture is [dispose]d.
  ///
  /// This only returns a valid value if asserts are enabled, and must not be
  /// used otherwise.
  bool get debugDisposed {
    bool? disposed;
    assert(() {
      disposed = _disposed;
      return true;
    }());
    return disposed ?? (throw StateError('Picture.debugDisposed is only available when asserts are enabled.'));
  }

  /// Returns the approximate number of bytes allocated for this object.
  ///
  /// The actual size of this picture may be larger, particularly if it contains
  /// references to image or other large objects.
  int get approximateBytesUsed native 'Picture_GetAllocationSize';
}

/// Records a [Picture] containing a sequence of graphical operations.
///
/// To begin recording, construct a [Canvas] to record the commands.
/// To end recording, use the [PictureRecorder.endRecording] method.
class PictureRecorder extends NativeFieldWrapperClass1 {
  /// Creates a new idle PictureRecorder. To associate it with a
  /// [Canvas] and begin recording, pass this [PictureRecorder] to the
  /// [Canvas] constructor.
  @pragma('vm:entry-point')
  PictureRecorder() { _constructor(); }
  void _constructor() native 'PictureRecorder_constructor';

  /// Whether this object is currently recording commands.
  ///
  /// Specifically, this returns true if a [Canvas] object has been
  /// created to record commands and recording has not yet ended via a
  /// call to [endRecording], and false if either this
  /// [PictureRecorder] has not yet been associated with a [Canvas],
  /// or the [endRecording] method has already been called.
  bool get isRecording => _canvas != null;

  /// Finishes recording graphical operations.
  ///
  /// Returns a picture containing the graphical operations that have been
  /// recorded thus far. After calling this function, both the picture recorder
  /// and the canvas objects are invalid and cannot be used further.
  Picture endRecording() {
    if (_canvas == null)
      throw StateError('PictureRecorder did not start recording.');
    final Picture picture = Picture._();
    _endRecording(picture);
    _canvas!._recorder = null;
    _canvas = null;
    return picture;
  }

  void _endRecording(Picture outPicture) native 'PictureRecorder_endRecording';

  Canvas? _canvas;
}

/// A single shadow.
///
/// Multiple shadows are stacked together in a [TextStyle].
class Shadow {
  /// Construct a shadow.
  ///
  /// The default shadow is a black shadow with zero offset and zero blur.
  /// Default shadows should be completely covered by the casting element,
  /// and not be visible.
  ///
  /// Transparency should be adjusted through the [color] alpha.
  ///
  /// Shadow order matters due to compositing multiple translucent objects not
  /// being commutative.
  const Shadow({
    this.color = const Color(_kColorDefault),
    this.offset = Offset.zero,
    this.blurRadius = 0.0,
  }) : assert(color != null, 'Text shadow color was null.'),
       assert(offset != null, 'Text shadow offset was null.'),
       assert(blurRadius >= 0.0, 'Text shadow blur radius should be non-negative.');

  static const int _kColorDefault = 0xFF000000;
  // Constants for shadow encoding.
  static const int _kBytesPerShadow = 16;
  static const int _kColorOffset = 0 << 2;
  static const int _kXOffset = 1 << 2;
  static const int _kYOffset = 2 << 2;
  static const int _kBlurOffset = 3 << 2;

  /// Color that the shadow will be drawn with.
  ///
  /// The shadows are shapes composited directly over the base canvas, and do not
  /// represent optical occlusion.
  final Color color;

  /// The displacement of the shadow from the casting element.
  ///
  /// Positive x/y offsets will shift the shadow to the right and down, while
  /// negative offsets shift the shadow to the left and up. The offsets are
  /// relative to the position of the element that is casting it.
  final Offset offset;

  /// The standard deviation of the Gaussian to convolve with the shadow's shape.
  final double blurRadius;

  /// Converts a blur radius in pixels to sigmas.
  ///
  /// See the sigma argument to [MaskFilter.blur].
  ///
  // See SkBlurMask::ConvertRadiusToSigma().
  // <https://github.com/google/skia/blob/bb5b77db51d2e149ee66db284903572a5aac09be/src/effects/SkBlurMask.cpp#L23>
  static double convertRadiusToSigma(double radius) {
    return radius > 0 ? radius * 0.57735 + 0.5 : 0;
  }

  /// The [blurRadius] in sigmas instead of logical pixels.
  ///
  /// See the sigma argument to [MaskFilter.blur].
  double get blurSigma => convertRadiusToSigma(blurRadius);

  /// Create the [Paint] object that corresponds to this shadow description.
  ///
  /// The [offset] is not represented in the [Paint] object.
  /// To honor this as well, the shape should be translated by [offset] before
  /// being filled using this [Paint].
  ///
  /// This class does not provide a way to disable shadows to avoid
  /// inconsistencies in shadow blur rendering, primarily as a method of
  /// reducing test flakiness. [toPaint] should be overridden in subclasses to
  /// provide this functionality.
  Paint toPaint() {
    return Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
  }

  /// Returns a new shadow with its [offset] and [blurRadius] scaled by the given
  /// factor.
  Shadow scale(double factor) {
    return Shadow(
      color: color,
      offset: offset * factor,
      blurRadius: blurRadius * factor,
    );
  }

  /// Linearly interpolate between two shadows.
  ///
  /// If either shadow is null, this function linearly interpolates from a
  /// a shadow that matches the other shadow in color but has a zero
  /// offset and a zero blurRadius.
  ///
  /// {@template dart.ui.shadow.lerp}
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  /// {@endtemplate}
  static Shadow? lerp(Shadow? a, Shadow? b, double t) {
    assert(t != null);
    if (b == null) {
      if (a == null) {
        return null;
      } else {
        return a.scale(1.0 - t);
      }
    } else {
      if (a == null) {
        return b.scale(t);
      } else {
        return Shadow(
          color: Color.lerp(a.color, b.color, t)!,
          offset: Offset.lerp(a.offset, b.offset, t)!,
          blurRadius: _lerpDouble(a.blurRadius, b.blurRadius, t),
        );
      }
    }
  }

  /// Linearly interpolate between two lists of shadows.
  ///
  /// If the lists differ in length, excess items are lerped with null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static List<Shadow>? lerpList(List<Shadow>? a, List<Shadow>? b, double t) {
    assert(t != null);
    if (a == null && b == null)
      return null;
    a ??= <Shadow>[];
    b ??= <Shadow>[];
    final List<Shadow> result = <Shadow>[];
    final int commonLength = math.min(a.length, b.length);
    for (int i = 0; i < commonLength; i += 1)
      result.add(Shadow.lerp(a[i], b[i], t)!);
    for (int i = commonLength; i < a.length; i += 1)
      result.add(a[i].scale(1.0 - t));
    for (int i = commonLength; i < b.length; i += 1)
      result.add(b[i].scale(t));
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    return other is Shadow
        && other.color == color
        && other.offset == offset
        && other.blurRadius == blurRadius;
  }

  @override
  int get hashCode => Object.hash(color, offset, blurRadius);

  // Serialize [shadows] into ByteData. The format is a single uint_32_t at
  // the beginning indicating the number of shadows, followed by _kBytesPerShadow
  // bytes for each shadow.
  static ByteData _encodeShadows(List<Shadow>? shadows) {
    if (shadows == null)
      return ByteData(0);

    final int byteCount = shadows.length * _kBytesPerShadow;
    final ByteData shadowsData = ByteData(byteCount);

    int shadowOffset = 0;
    for (int shadowIndex = 0; shadowIndex < shadows.length; ++shadowIndex) {
      final Shadow shadow = shadows[shadowIndex];
      // TODO(yjbanov): remove the null check when the framework is migrated. While the list
      //                of shadows contains non-nullable elements, unmigrated code can still
      //                pass nulls.
      if (shadow != null) {
        shadowOffset = shadowIndex * _kBytesPerShadow;

        shadowsData.setInt32(_kColorOffset + shadowOffset,
          shadow.color.value ^ Shadow._kColorDefault, _kFakeHostEndian);

        shadowsData.setFloat32(_kXOffset + shadowOffset,
          shadow.offset.dx, _kFakeHostEndian);

        shadowsData.setFloat32(_kYOffset + shadowOffset,
          shadow.offset.dy, _kFakeHostEndian);

        final double blurSigma = Shadow.convertRadiusToSigma(shadow.blurRadius);
        shadowsData.setFloat32(_kBlurOffset + shadowOffset,
          blurSigma, _kFakeHostEndian);
      }
    }

    return shadowsData;
  }

  @override
  String toString() => 'TextShadow($color, $offset, $blurRadius)';
}

/// A handle to a read-only byte buffer that is managed by the engine.
///
/// The creator of this object is responsible for calling [dispose] when it is
/// no longer needed.
class ImmutableBuffer extends NativeFieldWrapperClass1 {
  ImmutableBuffer._(this._length);

  /// Creates a copy of the data from a [Uint8List] suitable for internal use
  /// in the engine.
  static Future<ImmutableBuffer> fromUint8List(Uint8List list) {
    final ImmutableBuffer instance = ImmutableBuffer._(list.length);
    return _futurize((_Callback<void> callback) {
      instance._init(list, callback);
    }).then((_) => instance);
  }

  /// Create a buffer from the asset with key [assetKey].
  ///
  /// Throws an [Exception] if the asset does not exist.
  static Future<ImmutableBuffer> fromAsset(String assetKey) {
    final ImmutableBuffer instance = ImmutableBuffer._(0);
    return _futurize((_Callback<int> callback) {
      return instance._initFromAsset(assetKey, callback);
    }).then((int length) => instance.._length = length);
  }

  void _init(Uint8List list, _Callback<void> callback) native 'ImmutableBuffer_init';

  String? _initFromAsset(String assetKey, _Callback<int> callback) native 'ImmutableBuffer_initFromAsset';

  /// The length, in bytes, of the underlying data.
  int get length => _length;
  int _length;

  bool _debugDisposed = false;

  /// Whether [dispose] has been called.
  ///
  /// This must only be used when asserts are enabled. Otherwise, it will throw.
  bool get debugDisposed {
    late bool disposed;
    assert(() {
      disposed = _debugDisposed;
      return true;
    }());
    return disposed;
  }

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  ///
  /// The underlying memory allocated by this object will be retained beyond
  /// this call if it is still needed by another object that has not been
  /// disposed. For example, an [ImageDescriptor] that has not been disposed
  /// may still retain a reference to the memory from this buffer even if it
  /// has been disposed. Freeing that memory requires disposing all resources
  /// that may still hold it.
  void dispose() {
    assert(() {
      assert(!_debugDisposed);
      _debugDisposed = true;
      return true;
    }());
    _dispose();
  }

  void _dispose() native 'ImmutableBuffer_dispose';
}

/// A descriptor of data that can be turned into an [Image] via a [Codec].
///
/// Use this class to determine the height, width, and byte size of image data
/// before decoding it.
class ImageDescriptor extends NativeFieldWrapperClass1 {
  ImageDescriptor._();

  /// Creates an image descriptor from encoded data in a supported format.
  static Future<ImageDescriptor> encoded(ImmutableBuffer buffer) {
    final ImageDescriptor descriptor = ImageDescriptor._();
    return _futurize((_Callback<void> callback) {
      return descriptor._initEncoded(buffer, callback);
    }).then((_) => descriptor);
  }
  String? _initEncoded(ImmutableBuffer buffer, _Callback<void> callback) native 'ImageDescriptor_initEncoded';

  /// Creates an image descriptor from raw image pixels.
  ///
  /// The `pixels` parameter is the pixel data. They are packed in bytes in the
  /// order described by `pixelFormat`, then grouped in rows, from left to right,
  /// then top to bottom.
  ///
  /// The `rowBytes` parameter is the number of bytes consumed by each row of
  /// pixels in the data buffer. If unspecified, it defaults to `width` multiplied
  /// by the number of bytes per pixel in the provided `format`.
  // Not async because there's no expensive work to do here.
  ImageDescriptor.raw(
    ImmutableBuffer buffer, {
    required int width,
    required int height,
    int? rowBytes,
    required PixelFormat pixelFormat,
  }) {
    _width = width;
    _height = height;
    // We only support 4 byte pixel formats in the PixelFormat enum.
    _bytesPerPixel = 4;
    _initRaw(this, buffer, width, height, rowBytes ?? -1, pixelFormat.index);
  }
  void _initRaw(ImageDescriptor outDescriptor, ImmutableBuffer buffer, int width, int height, int rowBytes, int pixelFormat) native 'ImageDescriptor_initRaw';

  int? _width;
  int _getWidth() native 'ImageDescriptor_width';
  /// The width, in pixels, of the image.
  ///
  /// On the Web, this is only supported for [raw] images.
  int get width => _width ??= _getWidth();

  int? _height;
  int _getHeight() native 'ImageDescriptor_height';
  /// The height, in pixels, of the image.
  ///
  /// On the Web, this is only supported for [raw] images.
  int get height => _height ??= _getHeight();

  int? _bytesPerPixel;
  int _getBytesPerPixel() native 'ImageDescriptor_bytesPerPixel';
  /// The number of bytes per pixel in the image.
  ///
  /// On web, this is only supported for [raw] images.
  int get bytesPerPixel => _bytesPerPixel ??= _getBytesPerPixel();

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  void dispose() native 'ImageDescriptor_dispose';

  /// Creates a [Codec] object which is suitable for decoding the data in the
  /// buffer to an [Image].
  ///
  /// If only one of targetWidth or  targetHeight are specified, the other
  /// dimension will be scaled according to the aspect ratio of the supplied
  /// dimension.
  ///
  /// If either targetWidth or targetHeight is less than or equal to zero, it
  /// will be treated as if it is null.
  Future<Codec> instantiateCodec({int? targetWidth, int? targetHeight}) async {
    if (targetWidth != null && targetWidth <= 0) {
      targetWidth = null;
    }
    if (targetHeight != null && targetHeight <= 0) {
      targetHeight = null;
    }

    if (targetWidth == null && targetHeight == null) {
      targetWidth = width;
      targetHeight = height;
    } else if (targetWidth == null && targetHeight != null) {
      targetWidth = (targetHeight * (width / height)).round();
      targetHeight = targetHeight;
    } else if (targetHeight == null && targetWidth != null) {
      targetWidth = targetWidth;
      targetHeight = targetWidth ~/ (width / height);
    }
    assert(targetWidth != null);
    assert(targetHeight != null);

    final Codec codec = Codec._();
    _instantiateCodec(codec, targetWidth!, targetHeight!);
    return codec;
  }
  void _instantiateCodec(Codec outCodec, int targetWidth, int targetHeight) native 'ImageDescriptor_instantiateCodec';
}

/// Generic callback signature, used by [_futurize].
typedef _Callback<T> = void Function(T result);

/// Signature for a method that receives a [_Callback].
///
/// Return value should be null on success, and a string error message on
/// failure.
typedef _Callbacker<T> = String? Function(_Callback<T?> callback);

/// Converts a method that receives a value-returning callback to a method that
/// returns a Future.
///
/// Return a [String] to cause an [Exception] to be synchronously thrown with
/// that string as a message.
///
/// If the callback is called with null, the future completes with an error.
///
/// Example usage:
///
/// ```dart
/// typedef IntCallback = void Function(int result);
///
/// String _doSomethingAndCallback(IntCallback callback) {
///   Timer(Duration(seconds: 1), () { callback(1); });
/// }
///
/// Future<int> doSomething() {
///   return _futurize(_doSomethingAndCallback);
/// }
/// ```
// Note: this function is not directly tested so that it remains private, instead an exact
// copy of it has been inlined into the test at lib/ui/fixtures/ui_test.dart. if you change
// this function, then you  must update the test.
Future<T> _futurize<T>(_Callbacker<T> callbacker) {
  final Completer<T> completer = Completer<T>.sync();
  // If the callback synchronously throws an error, then synchronously
  // rethrow that error instead of adding it to the completer. This
  // prevents the Zone from receiving an uncaught exception.
  bool sync = true;
  final String? error = callbacker((T? t) {
    if (t == null) {
      if (sync) {
        throw Exception('operation failed');
      } else {
        completer.completeError(Exception('operation failed'));
      }
    } else {
      completer.complete(t);
    }
  });
  sync = false;
  if (error != null)
    throw Exception(error);
  return completer.future;
}
