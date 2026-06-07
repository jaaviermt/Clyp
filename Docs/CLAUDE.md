# Clyp - Project Instructions

## Project Overview

Clyp is an iOS application built with SwiftUI.

Tagline:

"Movies that match your soul."

The app recommends movies based on the user's emotional state (mood).

Users:

* Select their current mood
* Receive movie recommendations
* Mark movies as watched
* Save favorites
* View mood history
* View personal statistics

---

## Technical Stack

Required:

* SwiftUI
* MVVM
* NavigationStack
* URLSession
* Async/Await
* Codable
* Swift 6
* iOS 17+

Optional:

* SwiftData
* @AppStorage

---

## Architecture

Use strict MVVM.

Folder structure:

Clyp/
├── Models
├── Services
├── ViewModels
├── Views
├── Components
├── Resources
├── Extensions
└── Utilities

---

## Required Documents

Before implementing any feature always follow:

1. docs/DESIGN_SYSTEM.md
2. docs/API.md

These documents are the source of truth.

---

## Development Rules

Never invent colors.

Never invent typography.

Never invent spacing.

Never invent components.

Always follow DESIGN_SYSTEM.md.

Always use reusable components before creating new ones.

Business logic must never live inside Views.

Networking must only exist inside Services.

Views should remain under 250 lines.

Use async/await whenever possible.

Avoid UIKit unless absolutely necessary.

---

## Navigation

SplashView

↓

LoginView

↓

MainTabView

Tabs:

* Discover
* My List
* Profile

Additional screens:

* RecommendationsView
* MovieDetailView
* RegisterView
* ReviewSheet

---

## Reusable Components

Must reuse:

* LogoView
* PrimaryCTAButton
* MoodChip
* MoodCard
* MovieCard
* PosterView
* BottomNav
* RatingStars

Do not duplicate components.

---

## Coding Style

Prefer:

* Small views
* Small view models
* Dependency injection
* Clear naming
* Single responsibility

All code must be production quality and compile without warnings.

