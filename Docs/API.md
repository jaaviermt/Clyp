# Clyp API

Base URL:

Provided dynamically by backend using zrok.

Format:

<BASE_URL>/API_Clyp/api

Example:

https://xxxxx/API_Clyp/api

---

# Models

## User

```swift
struct User: Codable {
    let id_user: Int?
    let name: String
    let email: String
    let password: String
    let created_at: String?
}
```

## Genre

```swift
struct Genre: Codable {
    let id_genre: Int?
    let name: String
}
```

## Mood

```swift
struct Mood: Codable {
    let id_mood: Int?
    let name: String
    let description: String?
}
```

## Movie

```swift
struct Movie: Codable {
    let id_movie: Int?
    let title: String
    let description: String?
    let year: Int?
    let image_url: String?
    let id_genre: Int
    let id_mood: Int
}
```

## MoodCheckin

```swift
struct MoodCheckin: Codable {
    let id_checkin: Int?
    let id_user: Int
    let id_mood: Int
    let checkin_time: String?
}
```

## WatchedMovie

```swift
struct WatchedMovie: Codable {
    let id: Int?
    let id_user: Int
    let id_movie: Int
    let watched_at: String?
}
```

---

# Endpoints

## Mood

GET

/mood/getAll

POST

/mood/save

---

## Movie

GET

/movie/getAll

POST

/movie/save

---

## User

GET

/user/getAll

POST

/user/save

---

## Checkin

GET

/checkin/getAll

POST

/checkin/save

Body:

{
"id_user": 1,
"id_mood": 3
}

---

## Watched

GET

/watched/getAll

POST

/watched/save

Body:

{
"id_user": 1,
"id_movie": 5
}

---

# Networking Rules

Use:

* URLSession
* Async/Await
* Codable

Create:

* APIService
* Endpoint enum
* NetworkError enum

All networking code belongs inside Services.

