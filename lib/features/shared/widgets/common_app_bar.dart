import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showHomeButton;
  final bool automaticallyImplyLeading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showHomeButton = true,
    this.automaticallyImplyLeading = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar si podemos navegar hacia atrás
    final canPop = context.canPop();
    final shouldShowBackButton =
        showBackButton || (automaticallyImplyLeading && canPop);

    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: false,
      leading: shouldShowBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => _handleBackNavigation(context),
              tooltip: 'Volver',
            )
          : null,
      actions: [
        if (showHomeButton && !shouldShowBackButton) ...[
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => _handleHomeNavigation(context),
            tooltip: 'Ir al menú principal',
          ),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }

  /// Maneja la navegación hacia atrás de manera segura,
  /// cerrando el teclado primero si está abierto
  void _handleBackNavigation(BuildContext context) async {
    try {
      // Cerrar el teclado si está abierto
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();

        // Esperar a que se cierre el teclado antes de navegar
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Verificar que el contexto sigue siendo válido
      if (!context.mounted) return;

      // Navegar de manera segura
      final canPop = context.canPop();
      if (canPop) {
        context.pop();
      } else {
        context.go(AppRoutes.homeDashboard);
      }
    } catch (e) {
      // Si hay algún error, intentar navegar al dashboard como fallback
      debugPrint('Error en navegación: $e');
      try {
        if (context.mounted) {
          context.go(AppRoutes.homeDashboard);
        }
      } catch (e2) {
        debugPrint('Error en navegación fallback: $e2');
      }
    }
  }

  /// Maneja la navegación al home de manera segura,
  /// cerrando el teclado primero si está abierto
  void _handleHomeNavigation(BuildContext context) async {
    try {
      // Cerrar el teclado si está abierto
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();

        // Esperar a que se cierre el teclado antes de navegar
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Verificar que el contexto sigue siendo válido
      if (!context.mounted) return;

      // Navegar al dashboard
      context.go(AppRoutes.homeDashboard);
    } catch (e) {
      debugPrint('Error en navegación al home: $e');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
