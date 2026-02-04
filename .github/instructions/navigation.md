# Navigation Guide

This project uses `go_router` for navigation management, integrated with `riverpod` for state-based redirection (Authentication).

## Setup

The router is defined as a Riverpod provider in `lib/core/router/router.dart`.
It watches the authentication state to handle redirects securely.

## Redirect Rules (Auth Guard)

- If the user is **not authenticated** (`user == null`), they are redirected to `/login`.
- If the user is **authenticated** and tries to access `/login`, they are redirected to `/` (Home).
- `initialLocation` is set to `/`.

## Helper Commands

When adding new routes, consider using code generation if applicable, or simply add `GoRoute` entries to the `routes` list.

### Basic Route Definition

```dart
GoRoute(
  path: 'settings',
  builder: (context, state) => const SettingsPage(),
),
```

### Stacked Routes (Nested Navigation)

Use the `routes` parameter of a parent `GoRoute` to define sub-routes that appear "on top" of the parent or are related to it.

```dart
GoRoute(
  path: '/',
  builder: (context, state) => const RecipeListPage(),
  routes: [
    GoRoute(
      path: 'add',
      builder: (context, state) => const AddRecipePage(),
    ),
  ],
),
```

## Navigation

To navigate between pages, use the `GoRouterHelper` extensions provided by `go_router`.

```dart
// Basic navigation
context.go('/add');

// Push to stack (allows back button)
context.push('/settings');

// Replace
context.pushReplacement('/login');
```
