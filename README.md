# Senior Flutter Developer Technical Assessment

Task and document management demo built with Flutter. The app includes two feature areas:

- Task Board
- Document Dashboard

The project uses BLoC for feature state, GetIt for dependency injection, and in-memory repositories for local demo data.

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed
- Dart SDK that matches the Flutter installation
- An emulator, simulator, or physical device connected

Check your setup with:

```bash
flutter doctor
```

## Setup

1. Clone the repository.
2. Open the project root in VS Code or your editor.
3. Fetch dependencies:

```bash
flutter pub get
```

If you change dependencies later, run the same command again.

## Run the app

Start the app on your connected device or emulator:

```bash
flutter run
```

If you have multiple devices connected, list them first:

```bash
flutter devices
```

Then run on a specific device:

```bash
flutter run -d <device_id>
```

## Build and Test

Run the test suite:

```bash
flutter test
```

Useful maintenance commands:

```bash
flutter clean
flutter pub get
```

## How the app starts

The entry point is [lib/main.dart](lib/main.dart). It initializes dependency injection and then launches the app shell in [lib/src/app.dart](lib/src/app.dart).

By default, the app currently opens the document dashboard. If you want to switch to the task board for local testing, update the `home` widget in [lib/src/app.dart](lib/src/app.dart).

## Project Structure

Key folders:

- `lib/src/core` - app-wide utilities and dependency injection
- `lib/src/domain` - entities, repository contracts, and use cases
- `lib/src/data` - repository implementations
- `lib/src/presentation` - UI, BLoCs, and feature widgets

Feature areas:

- `lib/src/presentation/task_board` - task board BLoC, drag controller, and widgets
- `lib/src/presentation/document_dashboard` - document dashboard BLoC and widgets

## Notes

- Task data is currently stored in memory, not in a local database.
- Document uploads are simulated locally to demonstrate async status updates.
- Dependency injection is registered in [lib/src/core/di/injection.dart](lib/src/core/di/injection.dart).

## Troubleshooting

If the app does not launch correctly:

1. Run `flutter doctor` and fix any missing platform setup.
2. Run `flutter clean` followed by `flutter pub get`.
3. Make sure an emulator or physical device is connected.
4. Check the console output for dependency or build errors.

## License

This project does not currently include a license file.
