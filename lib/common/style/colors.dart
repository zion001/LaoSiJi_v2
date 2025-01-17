import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  /// 自定义颜色
  static Color get highLight =>
      Get.isDarkMode ? const Color(0xFFFFB4A9) : const Color(0xFFF77866);

  /// Material 颜色
  static Brightness get brightness => Get.theme.colorScheme.brightness;
  static Color get primary => Get.theme.colorScheme.primary;
  static Color get onPrimary => Get.theme.colorScheme.onPrimary;
  static Color get primaryContainer => Get.theme.colorScheme.primaryContainer;
  static Color get onPrimaryContainer =>
      Get.theme.colorScheme.onPrimaryContainer;
  static Color get secondary => Get.theme.colorScheme.secondary;
  static Color get onSecondary => Get.theme.colorScheme.onSecondary;
  static Color get secondaryContainer =>
      Get.theme.colorScheme.secondaryContainer;
  static Color get onSecondaryContainer =>
      Get.theme.colorScheme.onSecondaryContainer;
  static Color get tertiary => Get.theme.colorScheme.tertiary;
  static Color get onTertiary => Get.theme.colorScheme.onTertiary;
  static Color get tertiaryContainer => Get.theme.colorScheme.tertiaryContainer;
  static Color get onTertiaryContainer =>
      Get.theme.colorScheme.onTertiaryContainer;
  static Color get error => Get.theme.colorScheme.error;
  static Color get errorContainer => Get.theme.colorScheme.errorContainer;
  static Color get onError => Get.theme.colorScheme.onError;
  static Color get onErrorContainer => Get.theme.colorScheme.onErrorContainer;
  static Color get background => Get.theme.colorScheme.background;
  static Color get onBackground => Get.theme.colorScheme.onBackground;
  static Color get surface => Get.theme.colorScheme.surface;
  static Color get onSurface => Get.theme.colorScheme.onSurface;
  static Color get surfaceVariant => Get.theme.colorScheme.surfaceVariant;
  static Color get onSurfaceVariant => Get.theme.colorScheme.onSurfaceVariant;
  static Color get outline => Get.theme.colorScheme.outline;
  static Color get onInverseSurface => Get.theme.colorScheme.onInverseSurface;
  static Color get inverseSurface => Get.theme.colorScheme.inverseSurface;
  static Color get inversePrimary => Get.theme.colorScheme.inversePrimary;
  static Color get shadow => Get.theme.colorScheme.shadow;
  static Color get surfaceTint => Get.theme.colorScheme.surfaceTint;
  static Color get outlineVariant => Get.theme.colorScheme.outlineVariant;
  static Color get scrim => Get.theme.colorScheme.scrim;
}
