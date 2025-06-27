import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/auth_repository.dart';
import '../features/auth/models/user_model.dart';
import '../core/exceptions/database_exception.dart';
import '../data/local/database.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _currentUser;
  AuthStatus _status = AuthStatus.loading;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Recrear usuario admin con contraseña hasheada
      await DatabaseHelper.instance.recreateAdminUser();
    } catch (e) {
      // Si falla la recreación del admin, continuar normalmente
      debugPrint('Error al recrear usuario admin: $e');
    }

    // Verificar estado de autenticación
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        final user = await _authRepository.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
        } else {
          await _clearSession();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Error al verificar autenticación';
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authRepository.loginUser(
        email: email,
        password: password,
      );

      await _saveSession(user);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Error inesperado al iniciar sesión';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authRepository.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      await _saveSession(user);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Error inesperado al registrar usuario';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? password,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        password: password ?? _currentUser!.password,
      );

      final result = await _authRepository.updateUser(updatedUser);
      _currentUser = result;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil';
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id!);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
