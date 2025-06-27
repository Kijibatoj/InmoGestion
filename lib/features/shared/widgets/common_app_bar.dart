import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showHomeButton;
  final bool automaticallyImplyLeading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showHomeButton = true,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        if (showHomeButton) ...[
          IconButton(
            icon: Icon(Icons.home, color: AppColors.primaryRed),
            onPressed: () => context.go(AppRoutes.homeDashboard),
            tooltip: 'Ir al menú principal',
          ),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
