# Product Guide

## Vision
A dual-track recorder app designed for individuals and couples seeking a minimalist, visually engaging way to track significant life events and personal habits. The app combines sentimental tracking (anniversaries) with disciplined self-improvement (streaks), all wrapped in a sleek, glassmorphic UI.

## Initial Concept
This is a dual-track recorder app developed using Flutter and Riverpod. It comprises two independent modules: 1. Static date-day calculation (for tracking relationship anniversaries); 2. Dynamic streak and reset check-in system. The UI adopts IOS-like (Glassmorphism), with data stored locally (Hive or Shared Preferences).

## Strategic Roadmap (MVP Breakdown)
The development will be structured into granular tracks, each representing a complete unit of work:
1.  **Project Foundation**: Setup Flutter, Riverpod, Hive, and basic Glassmorphism UI components.
2.  **Anniversary Module**: Implement static date calculation and local storage for relationship milestones.
3.  **Streak Module**: Implement dynamic streak logic, check-in mechanism, and reset functionality.
4.  **Visual Polish**: Finalize themes, animations, and Android-specific optimizations.

## Target Audience
- **General Users**: Individuals needing simple day counting and habit tracking.
- **Couples & Individuals**: People tracking relationship milestones and personal goals.

## Core Features
1.  **Anniversary Tracker**:
    -   Static date-day calculation.
    -   Relationship tracker with milestone notifications.
2.  **Streak Module**:
    -   Dynamic streak counter with manual reset.
    -   Habit tracking and discipline reinforcement.
3.  **Visual Customization**:
    -   iOS-like Glassmorphism design language.
    -   Customizable themes and visual settings.

## Technical Constraints & Preferences
-   **Framework**: Flutter (with Riverpod for state management).
-   **Platform**: Android (Initial Release).
-   **Local Storage**: Hive (Lightweight, fast NoSQL database).
