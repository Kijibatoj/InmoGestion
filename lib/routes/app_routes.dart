import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../features/auth/views/login_view.dart';
import '../features/auth/views/register_view.dart';
import '../features/properties/views/home_view.dart';
import '../features/properties/views/property_detail_view.dart';
import '../features/properties/views/property_form_view.dart';
import '../features/onboarding/onboarding_service.dart';
import '../features/onboarding/onboarding_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String propertyDetail = '/property/:id';
  static const String propertyForm = '/property-form';
  static const String propertyEdit = '/property-edit/:id';

  // Índices de pestañas
  static const int dashboardTab = 0;
  static const int propertiesTab = 1;
  static const int searchTab = 2;
  static const int profileTab = 3;
  // Métodos helper para navegación de pestañas
  static String homeWithTab(int tabIndex) => '/?tab=$tabIndex';
  static String get homeDashboard => homeWithTab(dashboardTab);
  static String get homeProperties => homeWithTab(propertiesTab);
  static String get homeSearch => homeWithTab(searchTab);
  static String get homeProfile => homeWithTab(profileTab);

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final onboardingComplete = await OnboardingService.isOnboardingComplete();

      // Si no ha completado el onboarding, redirigir al onboarding
      if (!onboardingComplete) {
        if (state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        return null; // Ya está en onboarding
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;

      if (isLoading) return null;

      final isAuthRoute =
          state.matchedLocation == login || state.matchedLocation == register;
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // Si ya completó onboarding pero está en la página de onboarding, redirigir
      if (onboardingComplete && isOnboardingRoute) {
        return isAuthenticated ? home : login;
      }

      if (!isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
        return login;
      }

      if (isAuthenticated && isAuthRoute) {
        return home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) {
          final tabIndex =
              int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return HomeView(initialTabIndex: tabIndex);
        },
      ),
      GoRoute(
        path: propertyDetail,
        name: 'property-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyDetailView(propertyId: id);
        },
      ),
      GoRoute(
        path: propertyForm,
        name: 'property-form',
        builder: (context, state) => const PropertyFormView(),
      ),
      GoRoute(
        path: propertyEdit,
        name: 'property-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyFormView(propertyId: id);
        },
      ),
    ],
  );
}
