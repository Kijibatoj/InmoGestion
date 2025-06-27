import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'features/shared/theme/app_theme.dart';
import 'data/local/database.dart';

class InmoGestionApp extends StatelessWidget {
  const InmoGestionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => PropertyProvider()),
          ],
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return MaterialApp.router(
                title: 'InmoGestion',
                theme: AppTheme.lightTheme,
                routerConfig: AppRoutes.router,
                debugShowCheckedModeBanner: false,

                builder: (context, child) {
                  return PopScope(
                    canPop: false,
                    onPopInvoked: (didPop) async {
                      if (didPop) return;

                      // Cerrar teclado si está abierto antes de navegar
                      final currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus &&
                          currentFocus.focusedChild != null) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await Future.delayed(const Duration(milliseconds: 100));
                      }

                      // Permitir la navegación hacia atrás
                      if (context.mounted && context.canPop()) {
                        context.pop();
                      }
                    },
                    child: GestureDetector(
                      onTap: () {
                        // Cerrar teclado al tocar fuera de los campos de texto
                        final currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus &&
                            currentFocus.focusedChild != null) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      child: child!,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
