# Documentación Completa - InmoGestion

## Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Base de Datos SQLite](#base-de-datos-sqlite)
4. [Estructura de Carpetas](#estructura-de-carpetas)
5. [Modelos de Datos](#modelos-de-datos)
6. [Capa de Datos (DAO y Repositorios)](#capa-de-datos)
7. [Gestión de Estado (Providers)](#gestión-de-estado)
8. [Vistas y Navegación](#vistas-y-navegación)
9. [Dependencias Utilizadas](#dependencias-utilizadas)
10. [Instalación y Configuración](#instalación-y-configuración)
11. [Funcionalidades Implementadas](#funcionalidades-implementadas)
12. [Manual de Usuario](#manual-de-usuario)

---

## Descripción General

**InmoGestion** es una aplicación móvil desarrollada en Flutter que permite gestionar un catálogo de inmuebles de forma local. La aplicación incluye:

- Sistema de autenticación de usuarios
- Gestión completa de propiedades (CRUD)
- Base de datos SQLite local
- Búsqueda y filtrado de propiedades
- Interfaz moderna y responsiva
- Gestión de imágenes para propiedades

### Características Principales
- ✅ Autenticación local con encriptación de contraseñas
- ✅ CRUD completo de propiedades
- ✅ Base de datos SQLite integrada
- ✅ Búsqueda avanzada de propiedades
- ✅ Interfaz responsiva y moderna
- ✅ Gestión de sesiones persistentes
- ✅ Validación de formularios
- ✅ Manejo de errores robusto

---

## Arquitectura del Proyecto

La aplicación sigue una arquitectura limpia basada en capas:

```
┌─────────────────┐
│   Presentación  │ ← Views, Widgets
├─────────────────┤
│ Gestión Estado  │ ← Providers (ChangeNotifier)
├─────────────────┤
│   Repositorios  │ ← Lógica de negocio
├─────────────────┤
│     DAO/Data    │ ← Acceso a datos
├─────────────────┤
│   SQLite Local  │ ← Base de datos
└─────────────────┘
```

### Principios Aplicados
- **Separación de responsabilidades**: Cada capa tiene una función específica
- **Inversión de dependencias**: Las capas superiores no dependen de implementaciones específicas
- **Single Responsibility**: Cada clase tiene una única responsabilidad
- **DRY (Don't Repeat Yourself)**: Reutilización de código y componentes

---

## Base de Datos SQLite

### Esquema de Base de Datos

#### Tabla `users`
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

#### Tabla `properties`
```sql
CREATE TABLE properties (
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
  image_path TEXT,
  user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
```

### Configuración de Base de Datos
- **Nombre**: `inmogestion.db`
- **Versión**: 1
- **Ubicación**: Directorio de documentos de la aplicación
- **Usuario por defecto**: admin@inmogestion.com / admin123

---

## Estructura de Carpetas

```
lib/
├── main.dart                          # Punto de entrada
├── app.dart                           # Configuración principal
├── routes/
│   └── app_routes.dart                # Configuración de rutas
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Constantes globales
│   ├── utils/
│   │   └── form_validators.dart       # Validadores de formularios
│   └── exceptions/
│       └── database_exception.dart    # Excepciones personalizadas
├── features/
│   ├── auth/                          # Módulo de autenticación
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── services/
│   │   ├── views/
│   │   │   ├── login_view.dart
│   │   │   ├── register_view.dart
│   │   │   └── profile_view.dart
│   │   └── viewmodels/
│   ├── properties/                    # Módulo de propiedades
│   │   ├── models/
│   │   │   └── property_model.dart
│   │   ├── services/
│   │   ├── views/
│   │   │   ├── home_view.dart
│   │   │   ├── property_list_view.dart
│   │   │   ├── property_detail_view.dart
│   │   │   ├── property_form_view.dart
│   │   │   └── search_view.dart
│   │   └── viewmodels/
│   └── shared/
│       ├── widgets/                   # Widgets reutilizables
│       └── theme/
│           └── app_theme.dart         # Tema de la aplicación
├── data/
│   ├── local/
│   │   ├── database.dart              # Configuración SQLite
│   │   ├── property_dao.dart          # DAO propiedades
│   │   └── user_dao.dart              # DAO usuarios
│   └── repositories/
│       ├── property_repository.dart   # Repositorio propiedades
│       └── auth_repository.dart       # Repositorio autenticación
└── providers/
    ├── auth_provider.dart             # Provider autenticación
    └── property_provider.dart         # Provider propiedades
```

---

## Modelos de Datos

### User Model
```dart
class User {
  final int? id;
  final String email;
  final String password;
  final String name;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Property Model
```dart
class Property {
  final int? id;
  final String title;
  final String? description;
  final double price;
  final String propertyType;
  final String address;
  final String city;
  final String state;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final String? imagePath;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

---

## Capa de Datos

### DAO (Data Access Objects)

#### UserDao
- `insertUser()`: Crear nuevo usuario
- `getUserByEmail()`: Buscar usuario por email
- `getUserById()`: Buscar usuario por ID
- `authenticateUser()`: Autenticar credenciales
- `updateUser()`: Actualizar datos de usuario
- `deleteUser()`: Eliminar usuario
- `getAllUsers()`: Obtener todos los usuarios

#### PropertyDao
- `insertProperty()`: Crear nueva propiedad
- `getPropertyById()`: Buscar propiedad por ID
- `getAllProperties()`: Obtener todas las propiedades
- `getPropertiesByUser()`: Propiedades de un usuario
- `searchProperties()`: Búsqueda avanzada
- `updateProperty()`: Actualizar propiedad
- `deleteProperty()`: Eliminar propiedad
- `getPropertiesCount()`: Contar propiedades

### Repositorios

Los repositorios actúan como una capa de abstracción entre los providers y los DAO, manejando la lógica de negocio y el manejo de errores.

---

## Gestión de Estado

### AuthProvider
- Manejo del estado de autenticación
- Persistencia de sesión con SharedPreferences
- Métodos: `login()`, `register()`, `logout()`, `updateProfile()`

### PropertyProvider
- Gestión del estado de propiedades
- Cache local de datos
- Métodos: `loadProperties()`, `createProperty()`, `updateProperty()`, `deleteProperty()`, `searchProperties()`

---

## Vistas y Navegación

### Sistema de Navegación
Utiliza **GoRouter** para navegación declarativa:
- `/login` - Vista de inicio de sesión
- `/register` - Vista de registro
- `/` - Dashboard principal
- `/properties` - Lista de propiedades
- `/property/:id` - Detalle de propiedad
- `/property-form` - Formulario nueva propiedad
- `/property-edit/:id` - Editar propiedad
- `/search` - Búsqueda de propiedades
- `/profile` - Perfil de usuario

### Vistas Principales

#### LoginView
- Formulario de autenticación
- Validación de campos
- Manejo de errores
- Usuario de prueba incluido

#### HomeView
- Dashboard con navegación inferior
- Estadísticas de propiedades
- Acciones rápidas
- Perfil de usuario

#### PropertyListView
- Lista de propiedades con scroll infinito
- Botón flotante para agregar
- Navegación a detalles

#### PropertyFormView
- Formulario completo de propiedades
- Validación de campos
- Selección de imágenes
- Modo creación/edición

---

## Dependencias Utilizadas

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # State Management
  provider: ^6.1.1
  
  # Navigation
  go_router: ^13.2.0
  
  # Authentication & Security
  crypto: ^3.0.3
  
  # Image handling
  image_picker: ^1.0.7
  
  # Utilities
  uuid: ^4.3.3
  shared_preferences: ^2.2.2
```

### Dependencias de Desarrollo
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## Instalación y Configuración

### Requisitos Previos
- Flutter SDK 3.8.1 o superior
- Dart SDK incluido con Flutter
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd inmogestion
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Verificar configuración**
```bash
flutter doctor
```

4. **Ejecutar la aplicación**
```bash
flutter run
```

### Configuración Inicial

La aplicación se configura automáticamente en el primer arranque:
- Crea la base de datos SQLite
- Inserta usuario administrador por defecto
- Configura las tablas necesarias

**Usuario por defecto:**
- Email: admin@inmogestion.com
- Contraseña: admin123

---

## Funcionalidades Implementadas

### ✅ Autenticación
- [x] Inicio de sesión
- [x] Registro de usuarios
- [x] Encriptación de contraseñas (SHA-256)
- [x] Persistencia de sesión
- [x] Cierre de sesión
- [x] Actualización de perfil

### ✅ Gestión de Propiedades
- [x] Crear nueva propiedad
- [x] Editar propiedad existente
- [x] Eliminar propiedad
- [x] Ver detalles de propiedad
- [x] Listar todas las propiedades
- [x] Filtrar propiedades por usuario

### ✅ Búsqueda y Filtrado
- [x] Búsqueda por texto libre
- [x] Filtro por tipo de propiedad
- [x] Filtro por rango de precios
- [x] Filtro por ciudad
- [x] Combinación de filtros

### ✅ Interfaz de Usuario
- [x] Tema personalizado y consistente
- [x] Navegación intuitiva
- [x] Formularios con validación
- [x] Manejo de errores amigable
- [x] Loading states
- [x] Responsive design

### ✅ Base de Datos
- [x] Esquema SQLite optimizado
- [x] Relaciones entre tablas
- [x] Migraciones automáticas
- [x] Operaciones CRUD completas
- [x] Consultas optimizadas

---

## Manual de Usuario

### Primer Uso

1. **Iniciar la aplicación**
   - Al abrir por primera vez, la app creará la base de datos automáticamente

2. **Iniciar sesión**
   - Usar las credenciales por defecto:
     - Email: admin@inmogestion.com
     - Contraseña: admin123
   - O crear una cuenta nueva

3. **Dashboard principal**
   - Ver estadísticas de propiedades
   - Acceder a acciones rápidas
   - Navegar entre secciones

### Gestión de Propiedades

#### Agregar Nueva Propiedad
1. Tocar el botón "+" en la sección de propiedades
2. Llenar el formulario completo:
   - Título (obligatorio)
   - Descripción
   - Precio (obligatorio)
   - Tipo de propiedad
   - Dirección completa
   - Número de habitaciones/baños
   - Área
   - Imagen (opcional)
3. Tocar "Guardar"

#### Editar Propiedad
1. Ir a la lista de propiedades
2. Tocar una propiedad para ver detalles
3. Tocar el ícono de editar
4. Modificar los campos necesarios
5. Guardar cambios

#### Eliminar Propiedad
1. En los detalles de la propiedad
2. Tocar el ícono de eliminar
3. Confirmar la acción

### Búsqueda de Propiedades

1. Ir a la pestaña "Buscar"
2. Usar los filtros disponibles:
   - Texto libre en título, descripción o dirección
   - Tipo de propiedad (Casa, Apartamento, etc.)
   - Rango de precios
   - Ciudad
3. Los resultados se actualizan automáticamente

### Gestión de Perfil

1. Ir a la pestaña "Perfil"
2. Ver información personal
3. Editar datos:
   - Nombre
   - Teléfono
   - Contraseña
4. Cerrar sesión cuando sea necesario

---

## Solución de Problemas

### Problemas Comunes

**Error de base de datos**
- Reiniciar la aplicación
- Verificar permisos de almacenamiento

**Problemas de autenticación**
- Verificar credenciales
- Usar el usuario por defecto si es necesario

**Rendimiento lento**
- Cerrar otras aplicaciones
- Reiniciar dispositivo si es necesario

### Logs y Debugging

Los errores se muestran en la interfaz con mensajes amigables. Para debugging avanzado, usar:
```bash
flutter logs
```

---

## Conclusión

InmoGestion es una aplicación completa y robusta para la gestión de propiedades inmobiliarias. Implementa las mejores prácticas de desarrollo Flutter y proporciona una experiencia de usuario intuitiva y eficiente.

La arquitectura modular y limpia facilita el mantenimiento y la extensión de funcionalidades futuras. La base de datos SQLite local asegura un rendimiento óptimo y funcionamiento offline.

---

**Desarrollado con ❤️ usando Flutter**

*Fecha de documentación: Junio 2025*
*Versión: 1.0.0* 