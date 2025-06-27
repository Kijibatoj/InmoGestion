import 'package:flutter/material.dart';

/// Utilidades para diseño responsive
class ResponsiveUtils {
  /// Breakpoints para diferentes tamaños de pantalla
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  /// Obtiene el tipo de dispositivo basado en el ancho de pantalla
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.mobileLarge;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Verifica si la pantalla está en orientación horizontal
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Verifica si es una pantalla pequeña (móvil)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Verifica si es una pantalla mediana (móvil grande o tablet pequeño)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Verifica si es una pantalla grande (desktop)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Obtiene el padding responsivo basado en el tamaño de pantalla
  static double getResponsivePadding(
    BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Obtiene el número de columnas para grids responsivos
  static int getGridColumns(
    BuildContext context, {
    int mobile = 1,
    int mobileLarge = 2,
    int tablet = 2,
    int desktop = 3,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.mobileLarge:
        return mobileLarge;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Obtiene el tamaño de fuente responsivo
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
    double? mobileFontSize,
    double? tabletFontSize,
    double? desktopFontSize,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return mobileFontSize ?? baseFontSize * 0.9;
    } else if (width < tabletBreakpoint) {
      return mobileFontSize ?? baseFontSize * 0.95;
    } else if (width < desktopBreakpoint) {
      return tabletFontSize ?? baseFontSize;
    } else {
      return desktopFontSize ?? baseFontSize * 1.1;
    }
  }

  /// Obtiene la altura responsiva basada en el porcentaje de la pantalla
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Obtiene el ancho responsivo basado en el porcentaje de la pantalla
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Calcula el aspect ratio responsivo para diferentes pantallas
  static double getResponsiveAspectRatio(
    BuildContext context, {
    double mobile = 16 / 9,
    double tablet = 4 / 3,
    double desktop = 16 / 10,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Obtiene el espaciado vertical responsivo
  static double getVerticalSpacing(
    BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Obtiene el espaciado horizontal responsivo
  static double getHorizontalSpacing(
    BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Widget responsivo que cambia según el tamaño de pantalla
  static Widget responsiveWidget({
    required BuildContext context,
    Widget? mobile,
    Widget? mobileLarge,
    Widget? tablet,
    Widget? desktop,
    required Widget fallback,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? fallback;
      case DeviceType.mobileLarge:
        return mobileLarge ?? mobile ?? fallback;
      case DeviceType.tablet:
        return tablet ?? mobileLarge ?? mobile ?? fallback;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobileLarge ?? mobile ?? fallback;
    }
  }

  /// Determina si se debe usar diseño de una columna
  static bool shouldUseSingleColumn(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Obtiene el máximo ancho para contenido centrado
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > largeDesktopBreakpoint) {
      return largeDesktopBreakpoint * 0.8;
    } else if (width > desktopBreakpoint) {
      return width * 0.85;
    } else {
      return width;
    }
  }

  /// Calcula el tamaño de imagen responsivo
  static double getImageSize(
    BuildContext context, {
    double mobile = 80.0,
    double tablet = 100.0,
    double desktop = 120.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Obtiene el radio de borde responsivo
  static double getBorderRadius(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}

/// Enumeración para tipos de dispositivo
enum DeviceType { mobile, mobileLarge, tablet, desktop }

/// Mixin para widgets que necesitan diseño responsive
mixin ResponsiveMixin {
  /// Obtiene el tipo de dispositivo
  DeviceType getDeviceType(BuildContext context) =>
      ResponsiveUtils.getDeviceType(context);

  /// Verifica si es móvil
  bool isMobile(BuildContext context) => ResponsiveUtils.isMobile(context);

  /// Verifica si es tablet
  bool isTablet(BuildContext context) => ResponsiveUtils.isTablet(context);

  /// Verifica si es desktop
  bool isDesktop(BuildContext context) => ResponsiveUtils.isDesktop(context);

  /// Verifica si está en modo landscape
  bool isLandscape(BuildContext context) =>
      ResponsiveUtils.isLandscape(context);

  /// Obtiene padding responsivo
  double getResponsivePadding(BuildContext context) =>
      ResponsiveUtils.getResponsivePadding(context);

  /// Obtiene el número de columnas para grids
  int getGridColumns(BuildContext context) =>
      ResponsiveUtils.getGridColumns(context);
}
