# E-Sarathi+ (Universal Form Engine)

A sophisticated Flutter-based assistant designed to help users fill out complex Indian government forms (PAN, Passport, Aadhaar, etc.) using voice guidance, multi-language support, and automated form scanning.

## Project Overview

- **Core Mission:** Simplify the process of filling out government application forms through a conversational interface, especially for users who might struggle with complex web interfaces or require assistance in regional languages.
- **Main Technologies:**
    - **Flutter:** Mobile framework (Material 3).
    - **InAppWebView:** Used for rendering and interacting with government websites.
    - **Speech-to-Text & Text-to-Speech:** Powered by `speech_to_text` and `flutter_tts` for the conversational interface.
    - **Geolocator & Geocoding:** Used to automatically detect the user's location and adapt the Kannada dialect.
    - **SharedPreferences:** Local persistence for user accounts and a "Digital Vault" of personal details.

## Architecture

- **`VoiceService` (`lib/voice_service.dart`):** The engine for the conversational interface. It handles TTS, STT, and generates context-aware prompts in English, Hindi, and Kannada. It includes logic for regional Kannada dialect detection (Mysore, North Karnataka, Coastal, Hyderabad-Karnataka).
- **`VaultService` (`lib/vault_service.dart`):** Manages local storage of user profiles. It uses a "Vault" concept to securely store common form details (Aadhaar, PAN, Address) to enable auto-filling.
- **`ScanScreen` (`lib/main.dart`):** A critical component that uses JavaScript injection into a hidden WebView to extract form fields, radio buttons, and dropdowns from target websites. It performs "deep scans" by iterating through dropdown options and tabs to discover conditional fields.
- **`ReviewScreen` (`lib/main.dart`):** Allows users to review and edit extracted data. It uses fuzzy label matching to pre-populate fields from the Digital Vault.
- **`VoiceQAScreen` (`lib/voice_qa_screen.dart`):** The interactive UI where the `VoiceService` guides the user through the form-filling process question by question.

## Key Features

1.  **Automated Form Discovery:** Programmatically scans complex government websites to identify required input fields.
2.  **Multilingual Voice Assistant:** Supports English, Hindi, and Kannada with natural-sounding speech and dialect-specific phrasing.
3.  **Dialect-Aware Assistance:** Automatically adapts Kannada prompts based on the user's GPS location.
4.  **Digital Vault:** Securely stores personal information locally to minimize repetitive data entry across different government services.
5.  **Smart Pre-population:** Intelligently maps website form labels to stored vault data.

## Building and Running

### Prerequisites
- Flutter SDK (v3.10.8 or higher)
- Android Studio / VS Code with Flutter extension
- An Android/iOS device or emulator (GPS and Microphone access required)

### Commands
- **Install dependencies:** `flutter pub get`
- **Run the app:** `flutter run`
- **Build APK:** `flutter build apk`
- **Run tests:** `flutter test`

## Development Conventions

- **State Management:** Uses standard `StatefulWidget` and `setState` for UI logic; services are implemented as singleton-like classes or static utility classes.
- **UI Style:** Material 3 with a consistent dark theme (`_primaryDark`, `_accent`, etc.).
- **Localization:** Handled within `VoiceService` using `enum VoiceLanguage` and custom logic rather than standard ARB files, to facilitate dynamic conversational prompts.
- **JavaScript Injection:** Web interaction logic is encapsulated in JS strings within `ScanScreen`. Ensure any changes to target website structures are reflected in the `_extractorJS` script.

## TODO / Future Enhancements
- [ ] Add more government application presets in `UrlInputScreen`.
- [ ] Implement actual form submission logic (currently focused on extraction and review).
- [ ] Expand dialect support for other languages (e.g., Hindi regional variations).
