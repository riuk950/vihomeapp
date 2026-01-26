# VIHOME Flutter Project

## Project Overview

`vihome` is a mobile application for iOS and Android that will function as a real estate platform for the sale and lease of properties. The application is built using Flutter and follows the principles of Clean Architecture to ensure that it is scalable, maintainable, and testable.

**Main technologies:**

*   **Framework:** Flutter
*   **Programming language:** Dart
*   **Architecture:** Clean Architecture
*   **Navigation:** go\_router
*   **State management:** Provider
*   **Dependency Injection:** get\_it
*   **Backend:** Supabase

## Building and Running

To run the application, you need to have Flutter installed on your system. You can find instructions on how to install Flutter in the [official documentation](https://flutter.dev/docs/get-started/install).

Once you have Flutter installed, you can run the application using the following command:

```bash
flutter run
```

The application has different flavors for development and production. You can run a specific flavor using the following commands:

*   **Development:** `flutter run --flavor dev --target lib/env/main.dev.dart`
*   **Production:** `flutter run --flavor prod --target lib/env/main.prod.dart`

## Development Conventions

The project follows the principles of Clean Architecture, which means that the code is organized into three layers:

*   **Domain:** Contains the business logic of the application.
*   **Data:** Responsible for obtaining data from different sources (remote or local).
*   **Presentation:** Responsible for displaying the user interface.

The project uses `go_router` for navigation, `provider` for state management, and `get_it` for dependency injection.

## Project Structure

The project has the following directory structure:

*   `lib/`: Contains the source code of the application.
    *   `app/`: Contains the main application widget.
    *   `core/`: Contains the core components of the application, such as the router, the theme, and the dependency injection container.
    *   `data/`: Contains the data layer of the application.
    *   `domain/`: Contains the domain layer of the application.
    *   `env/`: Contains the different environments of the application.
    *   `infrastructure/`: Contains the infrastructure services, such as Supabase.
    *   `presentation/`: Contains the presentation layer of the application.
*   `test/`: Contains the tests of the application.
