# Clyp

> **Movies that match your soul.**

Clyp es una app de iOS que recomienda películas según el **estado de ánimo** del usuario. Eliges cómo te sientes, Clyp te sugiere qué ver, y vas construyendo tu historial emocional, tu lista de vistas, tus favoritos y tus reseñas.

---

## Características

- **Recomendaciones por mood** — elige tu ánimo (Happy, Sad, Excited, Romantic, Tense, Nostalgic) y recibe películas que encajan.
- **Check-ins de ánimo** — registra cómo te sientes; edita o borra entradas y revisa tu historial.
- **My List** — marca películas como **vistas** y guarda **favoritos**.
- **Reseñas y rating** — califica (1–5 ⭐) y escribe reseñas; calificar marca la peli como vista automáticamente.
- **Perfil y estadísticas** — edita tu perfil y consulta tus reseñas.
- **Gestión de catálogo (CRUD)** — administra películas, moods y géneros desde la app (crear / editar / borrar).
- **Modo sin conexión optimista** — la UI responde al instante y sincroniza con la API en cuanto está disponible.

---

## Arquitectura

App **SwiftUI** con **MVVM estricto**, Swift 6 y `async/await`. La lógica de negocio vive fuera de las vistas y el networking solo existe en `Services/`.

```
Clyp/
├── Models          // Codable: User, Movie, Mood, Genre, Review, MoodCheckin, Favorite, WatchedMovie
├── Services         // Capa de red y persistencia
│   ├── APIService.swift          // cliente URLSession
│   ├── Endpoint.swift            // definición de todas las rutas
│   ├── NetworkError.swift
│   ├── RemoteSync.swift          // puente API ↔ caché local
│   ├── LocalStorageService.swift // caché local del usuario en sesión
│   └── AppData.swift             // catálogo en memoria (observable)
├── ViewModels       // Auth, Mood, Movie, MoodCheckin, Catalog
├── Views            // Discover, MyList, Profile, Catalog/, detalle, login, etc.
├── Components       // LogoView, PrimaryCTAButton, MoodChip, MovieCard, RatingStars…
├── Resources        // Design system: colores, tipografía, spacing, radius, animaciones
├── Extensions
└── Utilities        // validación de auth, mock data
```

### Flujo de navegación

```
SplashView → LoginView → MainTabView (Discover · My List · Profile)
```

Pantallas adicionales: Recommendations, MovieDetail, Register, ReviewSheet, Catalog (gestión).

---

## Backend

La app consume una API REST desplegada en Render:

```
https://api-clyp.onrender.com/api
```

CRUD completo sobre 6 entidades: **User**, **Review**, **MoodCheckin**, **Movie**, **Mood** y **Genre** (además de Favorite y Watched). El contrato y los ajustes acordados con el equipo de backend están documentados en `Docs/`.

> **Cold start:** Render (plan free) puede tardar ~30–60 s en responder la primera petición tras un periodo de inactividad. No es un bug.

---

## Cómo ejecutar

**Requisitos:** Xcode 16+, iOS 17+, Swift 6.

1. Clona el repositorio.
2. Abre `Clyp.xcodeproj` en Xcode.
3. Selecciona un simulador (o tu dispositivo) y pulsa **Run** (⌘R).

No requiere dependencias externas ni configuración de claves.

---

## Stack técnico

SwiftUI · MVVM · NavigationStack · URLSession · async/await · Codable · Swift 6 · iOS 17+

---

