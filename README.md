#  InmoGestión – Aplicación de Gestión de Inmuebles

**InmoGestión** es una aplicación móvil desarrollada en [Flutter](https://flutter.dev/ ) diseñada para facilitar la gestión local de un catálogo de inmuebles. Permite a los usuarios autenticarse, crear, listar, buscar, editar y eliminar registros de propiedades, además de asociar y visualizar imágenes de cada inmueble. Todo el contenido se almacena localmente mediante una base de datos SQLite, garantizando funcionalidad sin conexión a un servico externo.

---
## Características Principales

-  **Autenticación local**: Registro e inicio de sesión con persistencia de sesión.
-  **CRUD completo**: Crear, leer, actualizar y eliminar inmuebles.
-  **Almacenamiento local**: Uso de SQLite (`sqflite`) para persistencia de datos.
-  **Manejo de estado**: Implementado con `Provider`.
-  **Carga de imágenes**: Desde la galería del dispositivo y tambien puedes tomar fotos!.
-  **Diseño responsivo**: Interfaz limpia y adaptable a distintos dispositivos móviles.
-  **Validaciones en formularios**: Para evitar errores de entrada.

---

## Arquitectura Modular

La aplicación está estructurada bajo una arquitectura clara y escalable, la mayoria de los archivos estan en ingles por preferencias propias
---

##  Se uso:

| Herramienta             | Propósito                             |
|------------------------|----------------------------------------|
| Flutter                | Desarrollo principal de la app             |
| Provider               | Manejo de estado global                |
| sqflite                | Base de datos local                    |
| path_provider          | Rutas seguras en el dispositivo        |
| shared_preferences     | Persistencia de sesión                 |
| image_picker           | Selección de imágenes                  |

---

## 📥 Cómo Ejecutar el Proyecto

1. **Clona el repo:**
   y sigue la linea de comandos que te dejo aca abajo

```bash
git clone https://github.com/tu-usuario/inmogestion.git 
cd inmogestion

flutter pub get
flutter run
flutter build apk
