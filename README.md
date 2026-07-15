# GitHub Repos App

A minimal Flutter (Material 3) app that fetches a GitHub user's public
repositories via the GitHub REST API and lets you open each project's
GitHub Pages site in an in-app WebView (falling back to the GitHub repo
page if the site isn't available).

No Firebase, no backend, no authentication required.

## Change the GitHub username

Edit **one** line in `lib/core/constants.dart`:

```dart
static const String githubUsername = 'octocat';
```

## Features

- Fetches all public, non-fork repositories on startup (paginated).
- Material 3 cards showing repo name, description, language, and stars.
- "Open Project" button opens `https://USERNAME.github.io/REPO_NAME/`
  in an in-app WebView.
- If that page fails to load, automatically falls back to the GitHub
  repository page (`https://github.com/USERNAME/REPO_NAME`).
- "Open in browser" action in the WebView app bar to launch the page
  externally at any time.
- Pull-to-refresh on the repository list.
- Loading, empty, and error states with a retry action.

## Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   (stable channel).
2. From the project root:

   ```bash
   flutter pub get
   ```

3. Run on a connected device or emulator:

   ```bash
   flutter run
   ```

## Building a release APK

```bash
flutter build apk --release
```

The APK will be generated at:

```
build/app/outputs/flutter-apk/app-release.apk
```

> Note: this project ships with the debug signing config wired into the
> release build type so `flutter build apk` works immediately. Before
> publishing to the Play Store, configure your own signing key in
> `android/app/build.gradle`.

## Project structure

```
lib/
  core/constants.dart        Single source of truth for the GitHub username
  models/repository.dart     Repository model parsed from the GitHub API
  services/github_service.dart  GitHub REST API client with error handling
  screens/home_screen.dart   Repository list: loading/error/empty states, pull-to-refresh
  screens/webview_screen.dart  In-app WebView with fallback + external browser
  widgets/repo_card.dart     Material 3 card UI
  main.dart                  App entry point and theming
android/                     Standard Flutter Android project (APK-ready)
```

## Packages used

All are stable, actively maintained packages:

- [`http`](https://pub.dev/packages/http) — GitHub REST API calls
- [`webview_flutter`](https://pub.dev/packages/webview_flutter) — in-app WebView
- [`url_launcher`](https://pub.dev/packages/url_launcher) — opening links externally
