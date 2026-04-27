# MisPelis – Proyecto Final · Desarrollo Avanzado de Apps

Aplicación móvil desarrollada en **Flutter** que permite a un usuario llevar un
**registro personal de las películas que ha visto**, calificarlas, comentarlas y
explorar un catálogo en línea para descubrir nuevas. Combina almacenamiento
local con consumo de una API pública.

## Integrantes del equipo

- Andrea Venegas
- Sergio Lara
- Emiliano Lopez
- Alejandro Pardinez
- German Ugalde

---

## 1. Resumen del Proyecto

### Descripción breve
**MisPelis** resuelve el problema de no recordar qué películas se han visto ni
qué tan recomendables fueron. La app permite iniciar sesión, registrar películas
con su calificación (estrellas), agregar comentarios personales y consultar un
catálogo en línea desde el cual también se puede marcar una película como
"vista" para añadirla a la colección personal.

### Público objetivo
Cualquier persona aficionada al cine que quiera mantener un historial ordenado
de las películas que ha visto y reflexionar sobre ellas con una calificación y
comentario. Estudiantes, cinéfilos casuales y reseñistas amateurs.

### Principales funcionalidades
1. **Inicio de sesión** con validación de correo y contraseña.
2. **Sesión persistente** ("Recordarme") con `SharedPreferences`.
3. **Registro local de películas** vistas, con título, género, año,
   calificación (1-5 estrellas) y comentario, persistido en **Hive**.
4. **Búsqueda** en la colección personal por título o género.
5. **Eliminación** deslizando (Dismissible) con feedback animado.
6. **Catálogo de películas** consumido desde una API pública, con vista en
   `GridView`, modal de detalle con `Hero` y opción de "marcar como vista".
7. **Pantalla de usuarios demo** consumiendo `JSONPlaceholder`.
8. **Animaciones**: entrada del login (`FadeTransition` + `SlideTransition`),
   botón animado (`AnimatedContainer`), estrellas con `AnimatedSwitcher`,
   estado vacío con `AnimationController` en bucle y animaciones `Hero` entre
   listas y detalle.
9. **Cierre de sesión** que limpia la preferencia.

---

## 2. Arquitectura de la Aplicación

### Estructura de carpetas

```
lib/
├── main.dart                 # Inicializa Hive + define rutas con onGenerateRoute
├── login_page.dart           # Pantalla de login (StatefulWidget + animaciones)
├── home_page.dart            # Dashboard con GridView de opciones y estadísticas
├── models/
│   ├── pelicula.dart         # Modelo del catálogo (API)
│   ├── pelicula_vista.dart   # Modelo persistido en Hive + TypeAdapter manual
│   └── usuario.dart          # Modelo de usuario (API)
├── pages/
│   ├── peliculas_page.dart       # Catálogo de la API en GridView (Stack/Hero)
│   ├── usuarios_page.dart        # Lista de usuarios desde JSONPlaceholder
│   ├── mis_peliculas_page.dart   # Colección local (Hive + ValueListenableBuilder)
│   └── agregar_pelicula_page.dart# Formulario validado para registrar una película
└── services/
    ├── api_service.dart           # Cliente HTTP (paquete http)
    ├── peliculas_repository.dart  # Repositorio sobre la box de Hive
    └── preferencias_service.dart  # Wrapper de SharedPreferences
android/, ios/, web/, …          # Plataformas nativas (config Android lista para Play)
```

La arquitectura sigue una separación por capas:

- **UI** ([lib/](lib/), [lib/pages/](lib/pages/)): widgets de pantalla.
- **Modelos** ([lib/models/](lib/models/)): clases de datos (incluye TypeAdapter Hive).
- **Servicios** ([lib/services/](lib/services/)): API, persistencia local y preferencias.

### Flujo de Navegación

```
                    ┌───────────────────┐
                    │   LoginPage  /    │
                    │ (valida + sesión) │
                    └─────────┬─────────┘
                              │ Navigator.pushReplacementNamed('/home', {correo})
                              ▼
                    ┌───────────────────┐
                    │   HomePage /home  │◄────────────┐
                    │   (Grid de 4)     │             │ pop
                    └─┬───┬───┬───────┬─┘             │
       /mis-peliculas │   │   │       │ /usuarios     │
                      │   │   │       └──────────────►│
                      ▼   │   │ /peliculas            │
   ┌───────────────────┐  │   ▼                       │
   │ MisPeliculasPage  │  │  ┌──────────────────┐     │
   │ (Hive + ListView) │  │  │  PeliculasPage   │─────┤
   └─────────┬─────────┘  │  │  (Grid + Hero)   │     │
             │ FAB        │  └────────┬─────────┘     │
             ▼            │           │ "Vi esta"     │
   ┌───────────────────┐  │           │ args          │
   │AgregarPeliculaPage│◄─┘           │               │
   │ (form + Hive add) │◄─────────────┘               │
   └─────────┬─────────┘                              │
             └──── pop ─────────────────────────────►─┘
```

Se utilizan **rutas nombradas** declaradas en `onGenerateRoute` de
[lib/main.dart](lib/main.dart), **`Navigator.pushNamed`** para avanzar,
**`Navigator.pop`** para regresar, y se pasan **datos entre pantallas** vía
`arguments` (correo del usuario al `Home`, y datos de la película precargados
al formulario).

---

## 3. Diseño de la Interfaz de Usuario (UI)

### Widgets clave utilizados

| Widget                       | Propósito en la app                                                   |
|------------------------------|-----------------------------------------------------------------------|
| `Form` + `TextFormField`     | Login y formulario de registrar película (validación de campos).      |
| `Container` + `BoxDecoration`| Tarjeta de bienvenida con gradiente en Home.                          |
| `Row`, `Column`, `Padding`   | Layouts y espaciado de toda la UI.                                    |
| `Image.network` + `Icon`     | Pósters de películas e iconografía Material.                          |
| `ListView.builder`           | Lista de "Mis películas" y de Usuarios.                               |
| `GridView.count` / `.builder`| Opciones del Home y catálogo en mosaico.                              |
| `Stack` + `Positioned`       | Logo del login y overlays sobre los pósters del catálogo.             |
| `Hero`                       | Transición animada del póster entre el grid y el detalle.             |
| `Dismissible`                | Eliminar películas deslizando.                                        |
| `ValueListenableBuilder`     | UI reactiva al box de Hive (sin necesidad de `setState`).             |
| `FutureBuilder`              | Estado de carga / error / éxito en el consumo de API.                 |
| `DropdownButtonFormField`    | Selección de género en el formulario.                                 |
| `AnimatedContainer`          | Botón "Entrar" se transforma a círculo durante la carga.              |
| `AnimatedSwitcher`           | Estrellas de calificación que cambian con animación.                  |
| `FadeTransition`/`SlideTransition` | Entrada animada al abrir el login.                              |

### Esquema de pantallas

1. **Login** – Logo circular con gradiente (Stack), formulario con dos campos
   validados, checkbox "Recordar mi sesión" y botón animado.
2. **Home** – Tarjeta de bienvenida con gradiente, 2 estadísticas (total y
   promedio), GridView con 4 opciones (Mis películas, Agregar, Catálogo,
   Usuarios) y botón de cerrar sesión en el AppBar.
3. **Mis películas** – Buscador en la parte superior, lista de tarjetas con
   póster + estrellas; FAB "Agregar"; estado vacío animado.
4. **Agregar película** – Formulario con título, género (dropdown), año
   (numérico), 5 estrellas tappables animadas y comentario opcional.
5. **Catálogo (API)** – GridView 2 columnas, cada tile con `Hero` + degradado
   inferior + botón "Vi esta"; modal de detalle al tocar.
6. **Usuarios (API)** – Lista simple con datos de JSONPlaceholder.

---

## 4. Consumo de API

### API utilizadas

| Nombre              | URL base                                          | Uso                       |
|---------------------|---------------------------------------------------|---------------------------|
| **DevsApiHub Movies** | `https://devsapihub.com/api-movies`             | Catálogo de películas.    |
| **JSONPlaceholder** | `https://jsonplaceholder.typicode.com/users`      | Demo de usuarios.         |

### Funcionamiento
La capa de red está centralizada en
[lib/services/api_service.dart](lib/services/api_service.dart). Se usa el
paquete [`http`](https://pub.dev/packages/http) con peticiones `GET`. Cada
respuesta JSON se decodifica con `dart:convert` y se mapea a los modelos
`Pelicula` o `Usuario` mediante `factory fromJson`.

- **Estado de carga**: `CircularProgressIndicator` mientras se espera.
- **Estado de error**: pantalla específica con `Icons.cloud_off`, mensaje y
  botón **Reintentar** que reconstruye el `FutureBuilder` actualizando un
  `Future` en `setState`.
- **RefreshIndicator**: se puede deslizar hacia abajo para recargar el
  catálogo.

---

## 5. Persistencia de Datos y Animaciones

### Persistencia con Hive
- Se inicializa con `Hive.initFlutter()` y se registra el adaptador manual
  `PeliculaVistaAdapter` (`typeId = 1`).
- La caja `peliculas_vistas` almacena todos los registros tipados como
  [PeliculaVista](lib/models/pelicula_vista.dart).
- La capa de UI consume Hive a través del repositorio
  [PeliculasRepository](lib/services/peliculas_repository.dart), que expone
  operaciones `agregar`, `eliminar`, `obtenerTodas` y `escuchar()` (devuelve un
  `ValueListenable<Box<PeliculaVista>>` para refrescar la UI automáticamente
  con `ValueListenableBuilder`).

### Persistencia con SharedPreferences
Encapsulada en
[PreferenciasService](lib/services/preferencias_service.dart). Guarda:
- `correo_sesion` – correo del último login.
- `recordarme` – si el usuario marcó persistir su sesión.
- `tema_oscuro` – preferencia visual (preparada para uso futuro).

En `main()` se consulta la sesión guardada para decidir si mostrar el login o
saltar directo al Home. El botón de cierre de sesión la limpia y regresa al
login.

### Animaciones
| Pantalla               | Tipo de animación                                                     |
|------------------------|-----------------------------------------------------------------------|
| Login                  | `FadeTransition` + `SlideTransition` al entrar; `AnimatedContainer` en el botón "Entrar" que se contrae a círculo durante la carga. |
| Mis películas (vacío)  | `AnimationController` en bucle + `ScaleTransition` para el icono.     |
| Mis películas (lista)  | `AnimatedSwitcher` en cada estrella al seleccionar.                   |
| Agregar película       | `AnimatedContainer` en cada estrella del rating.                      |
| Catálogo               | `Hero` para la transición del póster al modal de detalle.             |

---

## 6. Cumplimiento de los Requisitos Técnicos

| Requisito                                  | Implementación                                                                  |
|--------------------------------------------|---------------------------------------------------------------------------------|
| Fundamentos de Dart                        | Variables/constantes (`final`, `const`), tipos, listas (géneros), `for`/`map`, `if/else`, funciones async. |
| UI con widgets básicos                     | `Text`, `Container`, `Row`, `Column`, `Image`, `Icon`, `padding`, `margin`, `alignment`. |
| StatefulWidget + setState                  | `LoginPage`, `MisPeliculasPage`, `AgregarPeliculaPage`, `PeliculasPage`.        |
| Navegación entre ≥3 pantallas              | 6 pantallas con rutas nombradas y datos por `arguments`.                        |
| Interfaces complejas (ListView, GridView, Stack, formularios) | `GridView` en Home y catálogo, `ListView` en mis películas/usuarios, `Stack` en login y catálogo, `Form` en login y agregar. |
| Consumo de API                             | `api_service.dart` con `http`, manejo de carga/error/retry.                     |
| Hive + SharedPreferences                   | Repositorio Hive con TypeAdapter manual + `PreferenciasService`.                |
| Animaciones                                | `AnimatedContainer`, `AnimationController`, `Hero`, `AnimatedSwitcher`, `Fade/SlideTransition`. |

---

## 7. Cómo ejecutar el proyecto

```bash
flutter pub get
flutter run                   # debug en dispositivo conectado
flutter build apk --release   # APK firmado para distribución
```

> La guía de **publicación en Google Play** (firma, keystore, App Bundle y
> subida a Play Console) está documentada por separado en
> [docs/PUBLICACION_GOOGLE_PLAY.md](docs/PUBLICACION_GOOGLE_PLAY.md).

---

## 8. Retos técnicos y soluciones

- **Hive sin code-gen**: se evitó `build_runner` implementando manualmente
  `PeliculaVistaAdapter`, lo que reduce dependencias y simplifica el setup.
- **Sesión persistente vs. ruta inicial**: `main()` lee SharedPreferences
  *antes* de `runApp` para decidir entre `'/'` y `'/home'`.
- **Pasar datos del catálogo al formulario**: se usa el `arguments` de la ruta
  con un `Map<String, dynamic>` precargado y se aplican en `didChangeDependencies`.
- **UI reactiva al cambio en Hive**: en lugar de `setState` manual se usa
  `box.listenable()` + `ValueListenableBuilder`.

---

## 9. Próximos pasos / mejoras

- Sincronización en la nube (Firebase) para compartir colecciones.
- Modo oscuro (la preferencia ya está guardada).
- Recomendaciones basadas en géneros más vistos.
- Pantalla de estadísticas con gráficas.
- Internacionalización (i18n) ES / EN.
