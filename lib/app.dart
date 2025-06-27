import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              );
            },
          ),
        );
      },
    );
  }
}
