# Clyp — Backend Requirements

Este documento describe **todo lo que el backend tiene que entregar** para que la app móvil funcione end-to-end. La app está siendo construida con datos mock y un único interruptor (`MockData.useMockData`) que la conecta al API real.

**Plan de encendido**:

1. Backend levanta el servicio y entrega URL del zrok.
2. Frontend pega la URL en `APIService.setBaseURL(...)` y cambia `useMockData = false`.
3. Todo el flujo debe funcionar sin más cambios de código.

Para que ese paso 3 sea verdad, este doc tiene que cumplirse al pie de la letra.

---

## 1. Despliegue

| Requisito        | Valor / regla                                  |
|------------------|------------------------------------------------|
| Protocolo        | **HTTPS obligatorio**. iOS bloquea HTTP plano por App Transport Security. zrok HTTPS funciona. |
| Formato base URL | `<BASE_URL>/API_Clyp/api` (igual que API.md)   |
| Content-Type     | `application/json` en request y response       |
| Charset          | UTF-8                                          |

---

## 2. Login — **endpoint nuevo, falta en API.md**

API.md no define cómo hacer login. La app lo necesita. Propuesta concreta:

### `POST /user/login`

**Body**:
```json
{
  "email": "user@example.com",
  "password": "..."
}
```

**Respuesta 200** (usuario autenticado):
```json
{
  "id_user": 1,
  "name": "Javier",
  "email": "user@example.com",
  "created_at": "2026-06-01T12:34:56Z"
}
```

**Respuesta 401** (credenciales inválidas):
```json
{
  "error": "Invalid credentials"
}
```

### Sobre sesión

Por ahora la app guarda **`id_user` localmente** (UserDefaults) y lo incluye en el body de los POSTs subsecuentes (`/checkin/save`, `/watched/save`). No usamos JWT todavía.

Cuando quieras endurecer auth, añadir JWT es aditivo: el backend devuelve `token` en la respuesta de login/register y la app lo manda en `Authorization: Bearer ...`. La forma de los JSON no cambia.

### Reglas de seguridad mínimas

- **Hashear el password en el servidor** (bcrypt, argon2 — no plain text en la BD).
- **Nunca devolver el campo `password`** en ninguna respuesta. Ni en login, ni en register, ni en `/user/getAll`.

---

## 3. Endpoints existentes — clarificaciones por recurso

### 3.1 Mood

**`GET /mood/getAll`** → `[Mood]`

⚠️ **Crítico**: la app mapea moods a **colores e iconos por el campo `name`**. Los nombres canónicos exactos son:

| name        | Color asignado | Icono asset       |
|-------------|----------------|-------------------|
| `Happy`     | sunbeam        | `MoodIcons/Happy` |
| `Sad`       | indigoFrame    | `MoodIcons/Sad`   |
| `Excited`   | euphoria       | `MoodIcons/Excited` |
| `Romantic`  | heartbeat      | `MoodIcons/Romantic` |
| `Tense`     | voltPurple     | `MoodIcons/Tense` |
| `Nostalgic` | clypOrange     | `MoodIcons/Nostalgic` |

Si devuelves otros nombres (ej. "Feliz", "happy", "HAPPY"), la app cae a `clypOrange` + SF Symbol genérico. No rompe pero pierde branding. **Mantener mayúscula inicial y case exacto del lado del servidor.**

**`POST /mood/save`** — la app no lo usa. Se asume catálogo administrado desde backend.

---

### 3.2 Movie

**`GET /movie/getAll`** → `[Movie]`

- `id_genre` y `id_mood` deben apuntar a registros válidos del catálogo.
- `image_url`: si trae URL debe ser **HTTPS**. Puede ser `null` (la app cae a un poster template).

**`POST /movie/save`** — catálogo administrado, la app no lo llama.

---

### 3.3 User

**`POST /user/save`** — registro de usuario.

Body que envía la app:
```json
{
  "id_user": null,
  "name": "Javier",
  "email": "user@example.com",
  "password": "secret123",
  "created_at": null
}
```

⚠️ El backend **debe aceptar `id_user: null` y `created_at: null`** y generarlos al insertar. La app no omite los campos null (decisión de JSONEncoder por defecto).

**Respuesta 201** (mismo shape que login):
```json
{
  "id_user": 7,
  "name": "Javier",
  "email": "user@example.com",
  "created_at": "2026-06-07T14:30:00Z"
}
```

Si el email ya existe → **`409 Conflict`** con `{"error": "Email already registered"}`.

**`GET /user/getAll`** — la app **no lo usa**. Si lo expones, ten en cuenta que devolver todos los users con passwords (incluso hasheados) es un leak. Mejor restringirlo a admin o eliminarlo.

---

### 3.4 Checkin (registro de mood)

**`POST /checkin/save`**

Body actual del API.md (la app lo respeta literal):
```json
{
  "id_user": 1,
  "id_mood": 3
}
```

**Respuesta 200/201**: el checkin completo con `id_checkin` y `checkin_time` generados:
```json
{
  "id_checkin": 42,
  "id_user": 1,
  "id_mood": 3,
  "checkin_time": "2026-06-07T14:30:00Z"
}
```

**`GET /checkin/getAll`** ⚠️ **necesita filtro por usuario**

Hoy el endpoint devuelve checkins de todos los usuarios. La app necesita solo los del usuario activo para mostrar **historial de moods en Profile**.

**Propuesta**: aceptar query param `id_user`:
```
GET /checkin/getAll?id_user=1
```
Devuelve solo los checkins de ese user, **ordenados por `checkin_time` descendente** (más reciente primero).

---

### 3.5 Watched (películas vistas)

**`POST /watched/save`**

Body actual del API.md (la app lo respeta literal):
```json
{
  "id_user": 1,
  "id_movie": 5
}
```

**Respuesta 200/201**:
```json
{
  "id": 18,
  "id_user": 1,
  "id_movie": 5,
  "watched_at": "2026-06-07T14:30:00Z"
}
```

⚠️ **Dedupe server-side requerido**: si el mismo `id_user` marca dos veces la misma `id_movie`, **no crear dos registros**. Opciones aceptables:

- `200` idempotente devolviendo el registro existente, o
- `409 Conflict` con el registro existente en el body.

La app evita el doble-tap del lado del cliente (CTA queda disabled tras marcar), pero la defensa server-side previene basura en la BD.

**`GET /watched/getAll`** ⚠️ **necesita filtro por usuario** — mismo problema que checkin.

**Propuesta**:
```
GET /watched/getAll?id_user=1
```

---

## 4. Naming, tipos y fechas

### 4.1 snake_case obligatorio

La app decodifica los campos **tal cual** (sin CodingKeys de traducción). Los nombres exactos son:

| Modelo      | Campos                                                                 |
|-------------|------------------------------------------------------------------------|
| User        | `id_user`, `name`, `email`, `password`, `created_at`                   |
| Genre       | `id_genre`, `name`                                                     |
| Mood        | `id_mood`, `name`, `description`                                       |
| Movie       | `id_movie`, `title`, `description`, `year`, `image_url`, `id_genre`, `id_mood` |
| MoodCheckin | `id_checkin`, `id_user`, `id_mood`, `checkin_time`                     |
| WatchedMovie| `id`, `id_user`, `id_movie`, `watched_at`                              |

Cambiar a camelCase (ej. `idUser`, `imageUrl`) **rompe la decodificación** y la app crashea con `NetworkError.decoding`.

### 4.2 Tipos exactos

| Tipo Swift | JSON             | Notas                                            |
|------------|------------------|--------------------------------------------------|
| `Int?`     | `number` o `null`| IDs y `year`. Nunca devolver string `"1"`.       |
| `Int` (no optional) | `number` siempre | `id_user`/`id_mood`/`id_movie`/`id_genre` en cuerpos de POST son no-opcionales en la app. |
| `String`   | `string`         | Nunca null para campos no-opcionales (`name`, `email`, `title`). |
| `String?`  | `string` o `null`| `description`, `image_url`, fechas, `created_at` |

### 4.3 Fechas

`created_at`, `checkin_time`, `watched_at` son `String?` en la app. **Mándalas en ISO 8601 UTC**:

```
"2026-06-07T14:30:00Z"
```

La app aún no las parsea, solo las muestra. Pero cuando lo haga (historial en Profile), parseamos con `ISO8601DateFormatter` y debe funcionar de una.

---

## 5. Catálogo mínimo que debe existir al encender

Para que la app no se vea vacía el primer día:

### 5.1 Moods — los 6 obligatorios

```sql
INSERT INTO mood (id_mood, name, description) VALUES
  (1, 'Happy',     'Feel-good vibes.'),
  (2, 'Sad',       'Slow-burn drama.'),
  (3, 'Excited',   'High-energy adventures.'),
  (4, 'Romantic',  'Love and longing.'),
  (5, 'Tense',     'Edge-of-seat thrillers.'),
  (6, 'Nostalgic', 'Memory lane.');
```

Los `id_mood` no tienen que ser literalmente 1–6, **pero los `name` sí deben ser exactos** (case-sensitive).

### 5.2 Movies — mínimo 3 por mood

Para que `RecommendationsView` no muestre el empty state en ningún mood. Cada película con `id_mood` válido y `id_genre` válido.

### 5.3 Genres — necesarios si exponen el endpoint

API.md define `Genre` pero **no define endpoint para listarlos**. Si quieres mostrar género en la app, ver gap #7.1.

---

## 6. Manejo de errores

### Status codes

La app interpreta:
- `2xx` → success, decodifica el body.
- `4xx` / `5xx` → `NetworkError.statusCode(code)` → muestra "Server returned status code 500." al usuario.

### Shape de error sugerido

```json
{
  "error": "Mensaje legible (ej. 'Invalid credentials', 'Email already registered')"
}
```

La app aún no parsea el body de error (solo mira el código), pero usar este shape facilita que en una iteración chica lo mostremos al usuario.

---

## 7. Gaps de API.md que vale la pena cerrar

Estos puntos faltan en el doc actual y bloquean features completas:

### 7.1 Endpoint de géneros

Necesario si queremos mostrar género en `MovieCard` o `MovieDetailView`.

```
GET /genre/getAll → [Genre]
```

### 7.2 Endpoint de favoritos (opcional)

Hoy la app guarda favoritos solo en local (`UserDefaults`). Si quieres que persistan cross-device:

```
POST /favorite/save
Body: { "id_user": 1, "id_movie": 5 }
GET  /favorite/getAll?id_user=1
```

Mismas reglas de dedupe que watched.

### 7.3 Rating (opcional)

API.md no contempla calificación. Si quieres rating por usuario, dos caminos:

- Agregar campo `rating: Int?` (1–5) a `WatchedMovie` y permitir actualizarlo vía `/watched/save`.
- Endpoint separado `/rating/save` con `{id_user, id_movie, rating}`.

Decisión pendiente entre frontend y backend.

---

## 8. Checklist final antes de entregar la URL

Cuando puedas marcar todo esto, mandas la URL del zrok y la app funciona de una.

### Infra
- [ ] Servicio corriendo bajo HTTPS
- [ ] Base URL responde a `<host>/API_Clyp/api/mood/getAll` con 200 y array JSON

### Auth
- [ ] `POST /user/login` implementado y devuelve el shape de §2
- [ ] `POST /user/save` acepta nulls en `id_user` y `created_at`
- [ ] Passwords hasheados en BD
- [ ] Ningún endpoint devuelve `password` en la respuesta

### Catálogo
- [ ] Los 6 moods canónicos insertados con `name` exacto (case sensitive)
- [ ] Mínimo 3 movies por mood
- [ ] `image_url` (si se llena) en HTTPS

### Filtros y dedupe
- [ ] `GET /checkin/getAll?id_user=N` acepta el filtro
- [ ] `GET /watched/getAll?id_user=N` acepta el filtro
- [ ] `POST /watched/save` es idempotente

### Formato
- [ ] Todos los campos en snake_case exacto
- [ ] Fechas en ISO 8601 UTC (`YYYY-MM-DDTHH:MM:SSZ`)
- [ ] IDs siempre como `number`, nunca como `string`

### Errores
- [ ] 4xx/5xx devuelven JSON con campo `error`

---

## 9. Cómo el frontend valida que el contrato se cumple

Cuando entreguen URL:

1. Pegar URL en debug screen → `APIService.setBaseURL("https://xxxxx.share.zrok.io/API_Clyp/api")`.
2. `MockData.useMockData = false`.
3. Recorrer el flujo: Register → Discover (carga moods) → mood → Continue (POST checkin) → Recommendations (filtra movies por mood) → MovieDetail → Mark as Watched (POST watched) → tab MyList (GET watched filtered) → tab Profile (count + last mood) → logout.

Si cualquier paso falla, miramos el log de `NetworkError` y vemos en qué endpoint pasó. La idea es que **no haya cambios de código** entre mock y real — solo pegar URL y cambiar el flag.

---

**Resumen ejecutivo de cambios al API.md:**

1. Agregar `POST /user/login` (no existe hoy).
2. `GET /checkin/getAll` y `GET /watched/getAll` deben aceptar `?id_user=`.
3. `POST /watched/save` debe ser idempotente.
4. Nunca devolver `password` en respuestas.
5. Catálogo inicial con los 6 moods canónicos + 3+ movies por mood.
6. ISO 8601 UTC en fechas.
7. (Opcional) `GET /genre/getAll`, `/favorite/*`, rating.

Eso es lo que separa "API encendida" de "app funcionando".
