<div align="center">
  <img src="docs/images/xinchat_logo.png" width="120" alt="XinChat Logo" />

  # XinChat Swift

  A messaging app learning project built with Swift, UIKit, and MVVM.

  English · [简体中文](README.md)
</div>

## Overview

XinChat is an open-source iOS messaging app under active development. It demonstrates project organization commonly used in production applications: MVVM for screen state, repositories for data-source isolation, dependency injection for module composition, and centralized networking and reusable UI components.

The current version includes a conversation list, chat detail, remote contacts, and profile screens. It can be used as a starting point for a UIKit messaging app or as a practical architecture reference.

> If you find this project helpful, consider giving it a Star. Feedback and improvement suggestions are always welcome.

## Features

- Three-tab interface: Messages, Contacts, and Profile
- Conversation previews, timestamps, and unread badges
- Chat bubbles, text input, and local send interaction
- Remote contact loading, pull-to-refresh, and error retry
- Chat navigation from conversations or contacts with the bottom tab bar hidden
- Light and dark mode support
- Centralized theme tokens and a reusable avatar component

## Technology

| Category | Technology | Purpose |
| --- | --- | --- |
| Language | Swift | Application and UI development |
| UI | UIKit | Business screens and navigation |
| Lifecycle | SwiftUI | App entry point and UIKit bridge |
| Layout | SnapKit 5.7.1 | Programmatic Auto Layout |
| Networking | Alamofire 5.12.0 | HTTP requests, validation, and decoding |
| Architecture | MVVM + Repository | State management and data isolation |
| Dependencies | Swift Package Manager | Third-party package management |

## Architecture

Dependencies point from the presentation layer toward abstractions. View controllers never depend on Alamofire directly:

```text
ViewController / Cell
        │
        ▼
    ViewModel
        │
        ▼
Repository Protocol
        │
        ▼
 NetworkClient Protocol
        │
        ▼
    Alamofire
```

- `AppContainer` owns shared services and acts as the composition root.
- `ViewController` handles layout, user interaction, and state rendering only.
- `ViewModel` prepares screen data and converts request progress into UI state.
- `Repository` isolates remote APIs, local databases, and caches.
- `NetworkClient` centralizes request construction, status validation, decoding, and error mapping.

## Project Structure

```text
XinChat/
├── App/
│   └── AppContainer.swift                 # Dependency injection and root composition
├── Common/
│   ├── Theme/AppTheme.swift               # Colors and visual tokens
│   └── UI/AvatarView.swift                # Reusable avatar component
├── Core/Network/
│   ├── APIEndpoint.swift                  # Endpoint abstraction and API definitions
│   ├── NetworkClient.swift                # Alamofire wrapper
│   └── NetworkError.swift                 # Network error mapping
├── Domain/
│   ├── Models/ChatModels.swift            # Domain models
│   └── Repositories/ChatRepository.swift  # Repository protocol and implementation
├── Presentation/
│   ├── Root/                              # Main tab bar and navigation stacks
│   ├── ConversationList/                  # Conversation list module
│   ├── Chat/                              # Chat detail module
│   ├── Contacts/                          # Contacts module
│   └── Profile/                           # Profile module
├── ContentView.swift                      # SwiftUI/UIKit bridge
└── XinChatApp.swift                       # Application entry point
```

## Requirements

- macOS with Xcode 26.0 or later
- iOS 26.0 or later
- Swift Package Manager access to GitHub

The current deployment target is iOS 26.0. To support an earlier OS, update the target in Xcode and verify the availability of APIs used by the project.

## Getting Started

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd XinChat
   ```

2. Open `XinChat.xcodeproj` in Xcode.
3. Wait for Swift Package Manager to resolve SnapKit and Alamofire.
4. Select a simulator or a signed device and run the `XinChat` scheme.

Unsigned command-line build example:

```bash
xcodebuild \
  -project XinChat.xcodeproj \
  -scheme XinChat \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Networking

The Contacts screen currently uses [JSONPlaceholder](https://jsonplaceholder.typicode.com/users) as a public demo endpoint.

When connecting a production service:

1. Inject an environment-specific `baseURL` into `NetworkClient`.
2. Add endpoints and parameters to `ChatAPI`.
3. Map response DTOs to domain models inside the repository.
4. Keep cross-cutting concerns such as authentication, retries, logging, and certificate validation in the networking layer instead of individual screens.

Do not store tokens, passwords, or private service URLs in source code. Use `.xcconfig` files or CI environment variables for environment configuration.

## Current Scope and Roadmap

Chat messages and conversations currently use in-memory demo data. Persistence and real-time messaging are not implemented yet. Possible next steps include:

- Sign-in, registration, and token refresh
- WebSocket connection and real-time message delivery
- SQLite/Core Data message persistence
- Pagination, offline synchronization, and read receipts
- Image, audio, and file message types
- Unit tests, UI tests, and continuous integration

## Contributing

Issues and pull requests are welcome. Please preserve the existing layer boundaries when adding features, and include tests and meaningful comments for important business logic.

## License

This project is available under the [MIT License](LICENSE).
