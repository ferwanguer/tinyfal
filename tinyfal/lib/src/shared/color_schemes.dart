import 'package:flutter/material.dart';

final ColorScheme lightGreyColorScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary
  primary: Colors.grey[800]!,
  onPrimary: const Color.fromARGB(255, 255, 255, 255)!,
  primaryContainer: Colors.grey[100]!,
  onPrimaryContainer: Colors.grey[900]!,
  primaryFixed: const Color.fromARGB(255, 136, 136, 136)!,
  primaryFixedDim: Colors.grey[600]!,
  onPrimaryFixed: Colors.grey[50]!,
  onPrimaryFixedVariant: Colors.grey[200]!,

  // Secondary
  secondary: Colors.grey[700]!,
  onSecondary: Colors.grey[50]!,
  secondaryContainer: Colors.grey[100]!,
  onSecondaryContainer: Colors.grey[900]!,
  secondaryFixed: Colors.grey[700]!,
  secondaryFixedDim: Colors.grey[600]!,
  onSecondaryFixed: Colors.grey[50]!,
  onSecondaryFixedVariant: Colors.grey[200]!,

  // Tertiary
  tertiary: Colors.grey[600]!,
  onTertiary: Colors.grey[50]!,
  tertiaryContainer: Colors.grey[100]!,
  onTertiaryContainer: Colors.grey[900]!,
  tertiaryFixed: Color.fromARGB(255, 189, 136, 135),
  tertiaryFixedDim: Colors.grey[500]!,
  onTertiaryFixed: Colors.grey[50]!,
  onTertiaryFixedVariant: Colors.grey[300]!,

  // Error
  error: Colors.grey[600]!,
  onError: Colors.grey[50]!,
  errorContainer: Colors.grey[100]!,
  onErrorContainer: Colors.grey[900]!,

  // Surfaces
  surface: Colors.grey[50]!,
  onSurface: Colors.grey[900]!,
  surfaceDim: Colors.grey[100]!,
  surfaceBright: Colors.white,
  surfaceContainerLowest: Colors.grey[50]!,
  surfaceContainerLow: Colors.grey[100]!,
  surfaceContainer: Colors.grey[200]!,
  surfaceContainerHigh: Colors.grey[300]!,
  surfaceContainerHighest: Colors.grey[400]!,

  // Additional "onSurface" variants, outlines, shadows, etc.
  onSurfaceVariant: Colors.grey[600]!,
  outline: Colors.grey[500]!,
  outlineVariant: Colors.grey[400]!,
  shadow: Colors.grey[900]!,
  scrim: Colors.grey[900]!,
  inverseSurface: Colors.grey[900]!,
  onInverseSurface: Colors.grey[50]!,
  inversePrimary: Colors.grey[800]!,
  surfaceTint: Colors.grey[800]!,

  // Deprecated fields
  // Use the recommended properties above where possible.
  background: Colors.grey[50]!, // Deprecated, use 'surface' instead.
  onBackground: Colors.grey[900]!, // Deprecated, use 'onSurface' instead.
  surfaceVariant:
      Colors.grey[200]!, // Deprecated, use 'surfaceContainerHighest' instead.
);

final ColorScheme darkGreyColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // Primary
  primary: Colors.grey[50]!,
  onPrimary: const Color.fromARGB(255, 0, 0, 0),
  primaryContainer: Colors.grey[900]!,
  onPrimaryContainer: Colors.grey[100]!,
  primaryFixed: Colors.grey[300]!,
  primaryFixedDim: Colors.grey[400]!,
  onPrimaryFixed: Colors.grey[900]!,
  onPrimaryFixedVariant: Colors.grey[900]!,

  // Secondary
  secondary: Colors.grey[300]!,
  onSecondary: Colors.grey[900]!,
  secondaryContainer: Colors.grey[800]!,
  onSecondaryContainer: Colors.grey[100]!,
  secondaryFixed: Colors.grey[300]!,
  secondaryFixedDim: Colors.grey[400]!,
  onSecondaryFixed: Colors.grey[900]!,
  onSecondaryFixedVariant: Colors.grey[700]!,

  // Tertiary
  tertiary: Colors.grey[700]!,
  onTertiary: Colors.grey[900]!,
  tertiaryContainer: Colors.grey[900]!,
  onTertiaryContainer: Colors.grey[100]!,
  tertiaryFixed: Colors.grey[400]!,
  tertiaryFixedDim: Colors.grey[500]!,
  onTertiaryFixed: Colors.grey[900]!,
  onTertiaryFixedVariant: Colors.grey[600]!,

  // Error
  error: Colors.grey[400]!,
  onError: Colors.grey[900]!,
  errorContainer: Colors.grey[800]!,
  onErrorContainer: Colors.grey[100]!,

  // Surface, background, and related
  surface: const Color.fromARGB(255, 0, 0, 0),
  onSurface: Colors.grey[50]!,
  surfaceDim: Colors.grey[900]!,
  surfaceBright: Colors.grey[900]!,
  surfaceContainerLowest: Colors.grey[900]!,
  surfaceContainerLow: Colors.grey[900]!,
  surfaceContainer: Colors.grey[600]!,
  surfaceContainerHigh: Colors.grey[500]!,
  surfaceContainerHighest: Colors.grey[400]!,

  // Additional "onSurface" variants, outlines, shadows, etc.
  onSurfaceVariant: Colors.grey[300]!,
  outline: Colors.grey[500]!,
  outlineVariant: Colors.grey[400]!,
  shadow: Colors.grey[900]!,
  scrim: Colors.grey[900]!,
  inverseSurface: Colors.grey[50]!,
  onInverseSurface: Colors.grey[900]!,
  inversePrimary: Colors.grey[200]!,
  surfaceTint: Colors.grey[200]!,

  // Deprecated (use recommended fields above)
  background: Colors.grey[900]!, // Deprecated, use 'surface' instead.
  onBackground: Colors.grey[50]!, // Deprecated, use 'onSurface' instead.
  surfaceVariant:
      Colors.grey[900]!, // Deprecated, use 'surfaceContainerHighest' instead.
);
