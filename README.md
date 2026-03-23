# Mail Previewer Web

Mail Previewer Web is a Flutter Web experiment for opening, previewing, and locally archiving Outlook `.msg` files in the browser.

The app is intentionally narrow in scope. It focuses on a clean desktop-first workflow:

- upload one or more `.msg` files
- parse lightweight message details for preview
- persist the raw file bytes locally in the browser
- keep a lightweight archived summary for later browsing

## Current Scope

The current MVP centers on a single screen with:

- a top bar with the app title and search
- a left panel for upload and archived message history
- a right panel for read-only message preview
- local browser persistence so archived items survive refreshes in the same browser profile

Out of scope for this project unless explicitly added later:

- backend APIs
- cloud sync
- authentication
- shared/team workspaces
- tagging, folders, or advanced search indexing
- compose, reply, or editing workflows

## How It Works

### Upload and archive flow

When a user selects or drags in a `.msg` file, the app:

1. reads the file bytes in the browser
2. parses a lightweight summary
3. creates an archive item with metadata and raw bytes
4. stores that archive item in IndexedDB
5. updates the archive list and selects the newest imported message

### Parsing

The archive pipeline is built around a small parser abstraction.

- `lib/features/archive/services/msg_parser.dart` defines the parser contract.
- `lib/features/archive/services/mock_msg_parser.dart` provides the original mock implementation used during early UI/storage work.
- `lib/features/archive/services/real_msg_parser_web.dart` is the active web implementation.
- `web/msg_parser_adapter.js` bridges Flutter Web to the bundled JavaScript parser.
- `web/vendor/dotmsg.umd.js` provides the underlying `.msg` parsing library used in the browser.

The current web parser extracts lightweight preview fields such as:

- subject
- sender name and email
- recipients
- sent date
- attachment names
- body text or stripped HTML body fallback

This keeps the app aligned with the MVP archive/preview workflow rather than full-fidelity mail reconstruction.

### Persistence

All persistence is browser-compatible and local only.

- `lib/features/archive/services/archive_persistence_store_web.dart` stores archive items and UI metadata in IndexedDB through `idb_shim`.
- Raw `.msg` bytes are stored alongside parsed summary data.
- The selected message id is persisted.
- The archive is restored on startup from the same browser profile.

There is no server-side storage in the current product.

## Data Model

The app is built around an archive item concept that includes:

- `id`
- raw file bytes
- file name
- file size
- subject
- sender name
- sender email
- sent date/time label
- recipients label
- attachment names
- body preview
- body paragraphs
- archived timestamp

See:

- [msg_archive_item.dart](/Users/ahmetoktay/mail_previewer_web/lib/features/archive/models/msg_archive_item.dart)
- [parsed_msg_summary.dart](/Users/ahmetoktay/mail_previewer_web/lib/features/archive/models/parsed_msg_summary.dart)

## Project Structure

The codebase stays intentionally small and feature-local:

```text
lib/
  app/
    app.dart
    theme/
  features/
    archive/
      models/
      presentation/
      services/
      state/
web/
  index.html
  msg_parser_adapter.js
  vendor/
```

Key files:

- [lib/app/app.dart](/Users/ahmetoktay/mail_previewer_web/lib/app/app.dart): app entry widget and theme hookup
- [lib/features/archive/presentation/pages/archive_page.dart](/Users/ahmetoktay/mail_previewer_web/lib/features/archive/presentation/pages/archive_page.dart): single-screen archive shell
- [lib/features/archive/state/archive_controller.dart](/Users/ahmetoktay/mail_previewer_web/lib/features/archive/state/archive_controller.dart): local state and archive interactions
- [lib/features/archive/services/archive_storage_service.dart](/Users/ahmetoktay/mail_previewer_web/lib/features/archive/services/archive_storage_service.dart): archive creation, sorting, persistence coordination
- [web/msg_parser_adapter.js](/Users/ahmetoktay/mail_previewer_web/web/msg_parser_adapter.js): JavaScript bridge for `.msg` parsing on web

## Design Direction

This project follows the design system in [DESIGN.md](/Users/ahmetoktay/mail_previewer_web/DESIGN.md).

The UI direction is:

- calm, premium, minimal
- desktop-first
- single-screen
- tonal surface layering instead of hard divider lines
- strong typography hierarchy with Manrope and Inter

The HTML file [code.html](/Users/ahmetoktay/mail_previewer_web/code.html) exists only as a visual reference for layout and spacing. It is not meant to be translated directly into Flutter widgets.

## Getting Started

### Prerequisites

- Flutter SDK compatible with `sdk: ^3.8.1`
- Chrome or another modern browser for Flutter Web

Optional, depending on your setup:

- `fvm` if you use the provided deploy script
- Firebase CLI if you want to deploy hosting from this repo

### Install dependencies

```bash
flutter pub get
```

### Run locally

```bash
flutter run -d chrome
```

### Build for web

```bash
flutter build web
```

## Deployment

The repo includes Firebase Hosting configuration in [firebase.json](/Users/ahmetoktay/mail_previewer_web/firebase.json).

There is also a helper script:

```bash
./deploy.sh
```

The script currently runs:

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter build web
firebase deploy --only hosting
```

Use it only if your local environment is already configured for `fvm` and Firebase deployment.

## Development Notes

- This is a Flutter Web project first.
- Local persistence must remain browser-compatible.
- Keep architecture minimal and feature-local.
- Avoid heavy state-management libraries unless there is an explicit reason to introduce one.
- Preserve the single-screen archive-and-preview product shape.

## Known Boundaries

- Archive data is local to the browser profile and machine where it was imported.
- IndexedDB storage limits are browser-dependent.
- The parser is optimized for lightweight preview data, not full Outlook feature parity.
- There is currently no export, sync, or cross-device archive support.

## Future Work

Likely future work, if requested, would stay close to the existing archive flow:

- improving parser coverage for more `.msg` variants
- refining message body extraction and formatting
- expanding metadata extraction while keeping the same single-screen UX

The app should remain focused on local preview and archive behavior rather than expanding into a broader email product.
