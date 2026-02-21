# Specification: Project Foundation

## Goal
Establish the core technical and visual foundation for the Dual-Track Recorder app. This includes initializing the Flutter project, setting up state management (Riverpod), local storage (Hive), and implementing the reusable Glassmorphism UI components that will define the app's aesthetic.

## Scope
-   **Project Initialization**: Create new Flutter project, setup Git (already done, but ensure ignore files).
-   **Dependencies**: Install Riverpod, Hive, Hive Flutter, etc.
-   **Architecture**: Set up folder structure (features, core, etc.).
-   **UI Library**: Create a reusable `GlassContainer` widget and define the `Soft & Airy` theme.
-   **Routing**: Basic navigation setup.

## Requirements
1.  **Flutter Environment**: App must run on Android Emulator.
2.  **State Management**: Riverpod must be configured (ProviderScope).
3.  **Local Storage**: Hive must be initialized in `main.dart`.
4.  **Theming**:
    -   Font: Roboto/Inter.
    -   Colors: Pastel gradients.
5.  **Components**:
    -   `GlassContainer`: Accepts child, blur amount, opacity.

## Non-Goals
-   Implementing the actual Anniversary logic (Track 2).
-   Implementing the Streak logic (Track 3).
