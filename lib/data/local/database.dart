/*
Este archivo es la base de datos de la aplicacion, es decir la base de datos de la aplicacion

A nivel de codigo podemos determinar cuales son las tablas de la base de datos, y las funciones de la base de datos,
tambien se puede determinar cuales son los usuarios de la aplicacion, y cuales son las propiedades de la aplicacion
hay un usuario de admin por defecto, pero no lo uso para que gente se pueda registrar en la aplicacion
*/

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.userTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.propertyTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        property_type TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        bedrooms INTEGER,
        bathrooms INTEGER,
        area REAL,
        image_paths TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.userTableName} (id) ON DELETE CASCADE
      )
    ''');

    await _insertDefaultUser(db);
  }

  Future _insertDefaultUser(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.insert(AppConstants.userTableName, {
      'email': 'admin@inmogestion.com',
      'password': _hashPassword('admin123'),
      'name': 'Administrador',
      'phone': '+1234567890',
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> recreateAdminUser() async {
    final db = await database;

    await db.delete(
      AppConstants.userTableName,
      where: 'email = ?',
      whereArgs: ['admin@inmogestion.com'],
    );

    await _insertDefaultUser(db);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
