class DatabaseException implements Exception {
  final String message;
  final String? details;

  const DatabaseException(this.message, {this.details});

  @override
  String toString() {
    return 'DatabaseException: $message${details != null ? ' - $details' : ''}';
  }
}

class UserNotFoundException extends DatabaseException {
  const UserNotFoundException() : super('Usuario no encontrado');
}

class InvalidCredentialsException extends DatabaseException {
  const InvalidCredentialsException() : super('Credenciales inválidas');
}

class PropertyNotFoundException extends DatabaseException {
  const PropertyNotFoundException() : super('Propiedad no encontrada');
}

class DuplicateUserException extends DatabaseException {
  const DuplicateUserException() : super('El usuario ya existe');
}
