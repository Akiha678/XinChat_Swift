<div align="center">
  <img src="docs/images/xinchat_logo.png" width="120" alt="XinChat Logo" />

  # XinChat Swift

  A messaging app learning project built with Swift, UIKit, and MVVM.

  English · [简体中文](README.md)
</div>

## Overview

XinChat is an open-source iOS messaging app under active development. It demonstrates project organization commonly used in production applications: MVVM for screen state, repositories for data-source isolation, dependency injection for module composition, and centralized networking and reusable UI components.

The current version includes account login, a conversation list, chat detail, remote contacts, an add-friend flow, and profile screens. It can be used as a starting point for a UIKit messaging app or as a practical architecture reference.

> If you find this project helpful, consider giving it a Star. Feedback and improvement suggestions are always welcome.

## Features

- Three-tab interface: Messages, Contacts, and Profile
- Username/password login, persisted session state, and logout
- Realtime conversation refresh, latest-message ordering, persisted unread counts, and tab badges
- Chat bubbles, history loading, and server-backed message sending
- Remote contact loading, pull-to-refresh, and error retry
- Username search and friend-request submission with duplicate prevention
- Incoming-request inbox, pending count, and accept/reject actions
- Chat navigation from conversations or contacts with the bottom tab bar hidden
- Light and dark mode support
- Centralized theme tokens, a reusable avatar component, and a custom AppBar

## Technology

| Category | Technology | Purpose |
| --- | --- | --- |
| Language | Swift | Application and UI development |
| UI | UIKit | Business screens and navigation |
| Lifecycle | SwiftUI | App entry point and UIKit bridge |
| Layout | SnapKit 5.7.1 | Programmatic Auto Layout |
| Networking | Alamofire 5.12.0 | HTTP requests, validation, and decoding |
| Realtime | URLSessionWebSocketTask | Push events, heartbeat, and reconnection |
| Secure storage | Keychain Services | Login access token |
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
- `AppRootViewController` switches between Login and the main tab bar based on session state.
- `ViewController` handles layout, user interaction, and state rendering only.
- `ViewModel` prepares screen data and converts request progress into UI state.
- `Repository` isolates remote APIs, local databases, and caches.
- `NetworkClient` centralizes request construction, status validation, decoding, and error mapping.
- `AppBarView` centralizes titles, back navigation, trailing actions, and separators for detail screens.

## Project Structure

```text
XinChat/
├── App/
│   ├── AppContainer.swift                 # Dependency injection and root composition
│   ├── AppRootViewController.swift        # Login/main-flow coordination
│   └── AppSession.swift                   # Current user session
├── Common/
│   ├── Theme/AppTheme.swift               # Colors and visual tokens
│   └── UI/
│       ├── AppBarView.swift               # Reusable top navigation component
│       └── AvatarView.swift               # Reusable avatar component
├── Core/Network/
│   ├── APIEndpoint.swift                  # Endpoint abstraction and API definitions
│   ├── NetworkClient.swift                # Alamofire wrapper
│   └── NetworkError.swift                 # Network error mapping
├── Core/Realtime/                          # WebSocket connection and events
├── Core/Security/                          # Keychain token storage
├── Domain/
│   ├── Models/                            # Authentication and chat models
│   └── Repositories/                      # Authentication and chat repositories
├── Presentation/
│   ├── Login/                             # Username/password login
│   ├── Root/                              # Main tab bar and navigation stacks
│   ├── ConversationList/                  # Conversation list module
│   ├── Chat/                              # Chat detail module
│   ├── Contacts/                          # Contacts module
│   ├── AddFriend/                         # User search and friend requests
│   ├── FriendRequests/                    # Incoming requests and accept/reject actions
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

The client is connected to the companion Spring Boot service. `AppEnvironment.serverBaseURL` configures its base URL centrally and injects it into `NetworkClient`:

- `POST /auth/login` authenticates a username and password.
- `GET /friends` and `GET /users/search?username=` provide friends and username search.
- `POST /friend-requests` submits a friend request.
- `GET /friend-requests/incoming` lists incoming pending requests.
- `POST /friend-requests/{id}/accept|reject` accepts or rejects a request.
- `GET /conversations` and `POST /conversations/direct` list and create conversations.
- `GET/POST /conversations/{id}/messages` reads and sends messages.
- `POST /conversations/{id}/read` advances the authenticated user's read cursor.
- `WS /ws/chat` delivers Bearer-authenticated realtime message events.

Friend requests, friendships, conversations, and messages are persisted in MySQL. After login, public user details are stored in `AppSession`, while the access token is stored only in Keychain. Every authenticated REST and WebSocket request uses that Bearer token; the server derives the current user from it and never trusts a client-supplied current-user ID. Passwords are never stored by the client.

The complete friend flow is:

1. Open Contacts after signing in and tap the add button.
2. Search by username. The server excludes the current user, existing friends, and users with pending requests.
3. Send a request. The recipient sees the pending count on the New Friends row.
4. The recipient accepts or rejects the request from the inbox. Accepted users then appear in both contact lists.
5. A direct conversation can be created only after friendship is established; pending or rejected requests cannot bypass this rule.

Accepting a friend request creates or reuses the direct conversation in the same transaction and emits `friendship.accepted` to both users. On `message.created`, the client reconciles the server conversation snapshot, keeping preview text, ordering, timestamps, and persisted unread counts correct after reconnects. Opening a chat advances its read cursor and emits `conversation.read` to synchronize unread state across the current user's online devices.

Backend migrations provide three test accounts:

| Username | Password |
| --- | --- |
| `admin1` | `123456` |
| `admin2` | `123456` |
| `admin3` | `123456` |

`admin1` and `admin2` are already friends and can be used for direct message testing. `admin3` has no preconfigured friends, so use it with either existing account to test sending, accepting, or rejecting a friend request before creating a chat. New messages appear through WebSocket while the receiver remains on the chat screen; reopening the conversation is no longer required.

Messages are persisted through REST and received through WebSocket. The client implements a 20-second heartbeat, exponential reconnection capped at 30 seconds, message-ID deduplication, and REST reconciliation after reconnecting so events missed during a short outage are recovered.

Start the companion `xinchat` Spring Boot backend before running the app. A physical device cannot reach the development machine through `127.0.0.1`; set `AppEnvironment.serverBaseURL` to the machine's LAN address.

When switching environments:

1. Inject an environment-specific `baseURL` into `NetworkClient`.
2. Add endpoints and parameters to `ChatAPI`.
3. Map response DTOs to domain models inside the repository.
4. Keep cross-cutting concerns such as authentication, retries, logging, and certificate validation in the networking layer instead of individual screens.

Do not store tokens, passwords, or private service URLs in source code. Use `.xcconfig` files or CI environment variables for environment configuration.

## Current Scope and Roadmap

Friends, conversations, and messages are persisted in MySQL with WebSocket realtime delivery. Possible next steps include:

- Registration, JWT authentication, and token refresh
- Background WebSocket handling and APNs offline notifications
- SQLite/Core Data message persistence
- Pagination, offline synchronization, and read receipts
- Image, audio, and file message types
- Unit tests, UI tests, and continuous integration

## Contributing

Issues and pull requests are welcome. Please preserve the existing layer boundaries when adding features, and include tests and meaningful comments for important business logic.

## License

This project is available under the [MIT License](LICENSE).
