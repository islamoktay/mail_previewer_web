# AGENTS.md

## Project
This repository is a Flutter Web experiment for opening, previewing, and locally archiving Outlook `.msg` files.

Current product scope is intentionally narrow:
- upload `.msg` files
- preview parsed message content
- archive the raw `.msg` bytes locally in the browser
- store a lightweight parsed summary for later display

Do not add features outside this scope unless explicitly requested.

## Platform constraints
- This is a Flutter Web project first.
- Prefer desktop-first browser UX.
- Do not add mobile-first navigation patterns unless explicitly requested.
- Do not rely on `dart:io` file-system persistence for web.
- Local persistence must be browser-compatible.

## Architecture
Keep the architecture minimal and pragmatic.
- Prefer small focused files.
- Prefer feature-local organization.
- Do not introduce heavy architecture layers unless explicitly requested.
- Do not introduce BLoC, Riverpod, Redux, or other state-management libraries unless explicitly requested.
- Use simple local state/controller patterns.

## Parsing strategy
Do not implement real `.msg` parsing first.
Start with a mock parser and mock parsed summaries so the UI and storage flow can be completed first.

Current parser phase:
- mock parser only
- output lightweight parsed summary fields
- real `.msg` parsing comes later

## Storage strategy
For now, store only:
- raw `.msg` file bytes
- lightweight parsed summary
- archive metadata needed for list and preview

Do not add:
- cloud sync
- authentication
- backend APIs
- team/shared workspaces
- tagging systems
- folders
- advanced search indexing
- edit/compose/reply workflows

## UI expectations
Preserve the current product direction:
- single main screen
- top bar with title and search
- left panel for upload + archived messages
- right panel for read-only preview
- clean, modern, minimal desktop web UI

Do not redesign into a multi-page dashboard unless explicitly requested.

## Coding style
- Write clear, readable, maintainable Dart code.
- Prefer simple solutions over clever ones.
- Keep widgets reasonably small.
- Use good names and avoid unnecessary abstraction.
- Minimize package dependencies.
- Add comments only where they improve understanding.

## Workflow
When implementing a task:
1. Read the existing related files first.
2. Make the smallest reasonable change that satisfies the request.
3. Avoid speculative refactors.
4. Preserve current behavior unless the task asks to change it.
5. If something is ambiguous, choose the simplest option consistent with this file.

## Output expectations
When asked to implement:
- explain briefly what files were changed
- keep changes scoped to the requested task
- do not add tests unless explicitly requested
- do not add CI/CD, lint workflows, or deployment setup unless explicitly requested

## Current MVP data shape
The app should be built around an archive item concept containing:
- id
- raw file bytes
- file name
- file size
- subject
- sender name
- sender email
- sent date/time
- recipients
- attachment names
- body preview
- archived timestamp

Keep this flexible, but do not overengineer it.

## Design System (Strict)

This project follows a high-end editorial design system defined in DESIGN.md.

Core principles:

### 1. No-Line Rule
- Do NOT use solid borders to separate sections.
- Use background color differences instead.
- If absolutely necessary, use outline-variant at 10–20% opacity only.

### 2. Surface Layering
Use tonal hierarchy instead of borders:
- surface (base)
- surface-container-low (sections)
- surface-container-lowest (cards)

### 3. Spacing
- Prefer generous spacing.
- Do not compress UI to fit more content.
- Use whitespace as a structural element.

### 4. Typography
- Headlines: Manrope
- Body: Inter
- Maintain strong hierarchy

### 5. Components
- No divider lines in lists
- Cards instead of boxed sections
- Subtle hover states only

### 6. Visual Tone
- Calm, premium, minimal
- Avoid "generic SaaS" look
- No harsh contrasts
- No pure black (#000000)

When generating UI:
- prioritize elegance over density
- prioritize clarity over features
- match existing layout and spacing patterns

If unsure → follow existing code style instead of inventing new patterns

## HTML Reference (code.html)

The file `code.html` is a visual reference for layout, spacing, and hierarchy.

Rules:
- Do NOT convert HTML directly to Flutter
- Do NOT replicate Tailwind classes or structure
- Use it only to understand:
  - layout proportions (40% / 60%)
  - spacing scale
  - component hierarchy
  - visual grouping
  - interaction patterns

Flutter implementation must:
- be idiomatic Flutter
- use proper widget composition
- remain clean and maintainable

If there is a conflict:
- DESIGN.md rules override HTML