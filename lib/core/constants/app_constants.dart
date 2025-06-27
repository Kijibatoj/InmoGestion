class AppConstants {
  static const String appName = 'InmoGestion';
  static const String dbName = 'inmogestion.db';
  static const int dbVersion = 1;

  static const String userTableName = 'users';
  static const String propertyTableName = 'properties';

  static const int maxImageSize = 5000000;
  static const String defaultProfileImage = 'assets/icons/default_profile.png';
  static const String defaultPropertyImage =
      'assets/icons/default_property.png';

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double borderRadius = 8.0;
  static const double defaultPadding = 16.0;
}
