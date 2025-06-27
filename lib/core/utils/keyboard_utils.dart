import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utilidades para el manejo seguro del teclado y la navegación
class KeyboardUtils {
  /// Cierra el teclado de manera segura
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Navega de manera segura, cerrando el teclado primero
  static Future<void> safeNavigate(
    BuildContext context,
    String route, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    try {
      // Cerrar el teclado si está abierto
      dismissKeyboard(context);

      // Esperar a que se cierre el teclado
      await Future.delayed(delay);

      // Verificar que el contexto sigue siendo válido
      if (!context.mounted) return;

      // Navegar
      context.go(route);
    } catch (e) {
      debugPrint('Error en navegación segura: $e');
    }
  }

  /// Navega hacia atrás de manera segura
  static Future<void> safeGoBack(
    BuildContext context, {
    String? fallbackRoute,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    try {
      // Cerrar el teclado si está abierto
      dismissKeyboard(context);

      // Esperar a que se cierre el teclado
      await Future.delayed(delay);

      // Verificar que el contexto sigue siendo válido
      if (!context.mounted) return;

      // Navegar hacia atrás
      final canPop = context.canPop();
      if (canPop) {
        context.pop();
      } else if (fallbackRoute != null) {
        context.go(fallbackRoute);
      }
    } catch (e) {
      debugPrint('Error en navegación hacia atrás: $e');
      // Fallback de emergencia
      if (fallbackRoute != null && context.mounted) {
        try {
          context.go(fallbackRoute);
        } catch (e2) {
          debugPrint('Error en fallback: $e2');
        }
      }
    }
  }
}

/// Mixin para facilitar el uso de KeyboardUtils en StatefulWidgets
mixin SafeNavigationMixin<T extends StatefulWidget> on State<T> {
  /// Cierra el teclado de manera segura
  void dismissKeyboard() {
    KeyboardUtils.dismissKeyboard(context);
  }

  /// Navega de manera segura
  Future<void> safeNavigate(String route) async {
    await KeyboardUtils.safeNavigate(context, route);
  }

  /// Navega hacia atrás de manera segura
  Future<void> safeGoBack({String? fallbackRoute}) async {
    await KeyboardUtils.safeGoBack(context, fallbackRoute: fallbackRoute);
  }

  @override
  void dispose() {
    // Asegurar que el teclado se cierre al hacer dispose
    try {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    } catch (e) {
      // Ignorar errores en dispose
    }
    super.dispose();
  }
}
