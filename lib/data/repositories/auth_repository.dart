import '../local/user_dao.dart';
import '../../features/auth/models/user_model.dart';
import '../../core/exceptions/database_exception.dart';

class AuthRepository {
  final UserDao _userDao = UserDao();

  Future<User> registerUser({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final user = User(
        email: email.toLowerCase().trim(),
        password: password,
        name: name.trim(),
        phone: phone?.trim(),
      );

      return await _userDao.insertUser(user);
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Error al registrar usuario: ${e.toString()}');
    }
  }

  Future<User> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _userDao.authenticateUser(
        email.toLowerCase().trim(),
        password,
      );
      if (user == null) {
        throw const InvalidCredentialsException();
      }
      return user;
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      return await _userDao.getUserByEmail(email.toLowerCase().trim());
    } catch (e) {
      throw DatabaseException('Error al obtener usuario: ${e.toString()}');
    }
  }

  Future<User?> getUserById(int id) async {
    try {
      return await _userDao.getUserById(id);
    } catch (e) {
      throw DatabaseException('Error al obtener usuario: ${e.toString()}');
    }
  }

  Future<User> updateUser(User user) async {
    try {
      return await _userDao.updateUser(user);
    } catch (e) {
      throw DatabaseException('Error al actualizar usuario: ${e.toString()}');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _userDao.deleteUser(id);
    } catch (e) {
      throw DatabaseException('Error al eliminar usuario: ${e.toString()}');
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final user = await _userDao.getUserByEmail(email.toLowerCase().trim());
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
