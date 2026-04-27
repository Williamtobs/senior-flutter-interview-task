# Architecture Overview

This document explains the architecture choices in this codebase, with references to concrete implementation decisions.

## Scope

The app currently contains two feature areas:

- Task Board
- Document Dashboard

The app entry point wires dependencies in startup and launches one of the feature screens.

## State Management

### 1) Chosen Approach and Why

This project uses a hybrid state strategy:

- BLoC for feature and business state
- Provider/ChangeNotifier for short-lived, gesture-driven UI state in drag-and-drop

Concrete implementation:

- Task feature business state: [TaskBloc](lib/src/presentation/task_board/bloc/task_bloc.dart)
- Document feature business state: [DocumentBloc](lib/src/presentation/document_dashboard/bloc/document_bloc.dart)
- Drag gesture state: [DragController](lib/src/presentation/task_board/controller/drag_controller.dart)

Why this combination was selected:

- The task board and document dashboard both need event-driven state transitions and async workflows, which BLoC handles clearly.
- Drag position, hover column, and target index are high-frequency transient UI values; keeping them in ChangeNotifier avoids turning pointer updates into BLoC events.
- This keeps business state transitions readable while allowing smooth drag interactions.

Trade-offs considered:

- Pros:
  - Predictable event-to-state flow for core features.
  - Clear boundary between domain state and ephemeral pointer state.
- Cons:
  - Two state mechanisms in one feature add learning overhead.
  - Document stream subscription lifecycle is currently simple and could need hardening as complexity grows.

### 2) Shared vs Isolated State Between Features

The two features are isolated at state level.

- Task Board state is managed by TaskBloc + DragController.
- Document Dashboard state is managed by DocumentBloc.
- No cross-feature shared state object or cross-feature event dependency exists.

What drove this:

- Distinct domain entities and workflows:
  - [Task](lib/src/domain/task/entities/task.dart)
  - [Document](lib/src/domain/document/entities/document.dart)
- Feature screens instantiate their own BLoCs locally via BlocProvider:
  - [TaskBoardScreen](lib/src/presentation/task_board/view/task_board_screen.dart)
  - [DocumentDashboardPage](lib/src/presentation/document_dashboard/view/document_screen.dart)

## Dependency Injection

### 1) DI Structure and Registration Scope

Dependency injection is centralized in GetIt.

- Composition root: [injection.dart](lib/src/core/di/injection.dart)
- Startup path:
  - [main.dart](lib/main.dart) calls init()
  - [app.dart](lib/src/app.dart) selects the active screen

Current registration strategy:

- Factory scope:
  - TaskBloc
  - DocumentBloc
- Lazy singleton scope:
  - Use cases: CreateTask, UpdateTask, DeleteTask, MoveTask
  - Repositories: TaskRepository, DocumentRepository

Why these scopes:

- BLoCs should be created per UI context/request rather than global singletons.
- Repositories and use cases are effectively stateless service objects (or hold app-wide in-memory data), so lazy singletons reduce unnecessary instantiation.

### 2) Shared Services Without Feature Coupling

There is no explicit shared network/auth/local-storage service abstraction yet.

Current decoupling still works because:

- Features depend on their own repository interfaces from domain.
- Wiring is done centrally in DI, not by feature-to-feature imports.
- Data implementations are separate per feature:
  - [TaskRepositoryImpl](lib/src/data/task/repositories/task_repository_impl.dart)
  - [DocumentRepositoryImpl](lib/src/data/document/repositories/document_repository_impl.dart)

When shared infrastructure is introduced (for example HTTP client, auth, persistent DB), the same DI root is the intended seam for sharing those services safely without feature coupling.

## Data Layer

### 1) Local Database Choice and Alternatives

Current implementation uses in-memory storage, not a local database.

- Task data: in-memory list in [TaskRepositoryImpl](lib/src/data/task/repositories/task_repository_impl.dart)
- Document data: in-memory map + simulated async status updates in [DocumentRepositoryImpl](lib/src/data/document/repositories/document_repository_impl.dart)

Why this was reasonable for the current scope:

- Fast iteration for feature behavior and interview/demo requirements.
- No migration or persistence complexity while validating state flows.

Alternatives considered for production evolution:

- Isar: fast object storage, strong Flutter developer experience.
- Drift: typed SQL and relational querying.
- Hive: lightweight key-value/object persistence.
- sqflite: direct SQLite control.

### 2) Repository Pattern and Data Flow

The repository pattern is implemented with domain interfaces and data-layer implementations.

Task flow:

1. UI dispatches task events (create/move).
2. TaskBloc handles events and calls repository operations.
3. TaskBloc groups tasks by status and emits TaskState.
4. UI listens with BlocBuilder and rebuilds task columns/lists.

Primary references:

- [task_event.dart](lib/src/presentation/task_board/bloc/task_event.dart)
- [TaskBloc](lib/src/presentation/task_board/bloc/task_bloc.dart)
- [TaskRepository](lib/src/domain/task/repositories/task_repositories.dart)
- [TaskRepositoryImpl](lib/src/data/task/repositories/task_repository_impl.dart)

Document flow:

1. UI dispatches UploadDocumentEvent.
2. DocumentBloc calls uploadDocument and emits updated list.
3. DocumentBloc subscribes to watchDocumentStatus stream and dispatches DocumentStatusUpdated.
4. UI rebuilds cards based on latest status/progress.

Primary references:

- [upload_button.dart](lib/src/presentation/document_dashboard/widgets/upload_button.dart)
- [DocumentBloc](lib/src/presentation/document_dashboard/bloc/document_bloc.dart)
- [DocumentRepository](lib/src/domain/document/repositories/document_repositories.dart)
- [DocumentRepositoryImpl](lib/src/data/document/repositories/document_repository_impl.dart)

Note on "network to UI":

- There is no real network client yet; DocumentRepositoryImpl simulates websocket + polling behavior to model asynchronous backend updates.

## Project Structure for Team Collaboration

### 1) Recommended Team-Ready Structure (4+ Developers)

The current structure is layered with feature separation inside each layer:

- data/task and data/document
- domain/task and domain/document
- presentation/task_board and presentation/document_dashboard

For a larger team working concurrently, evolve to feature-first modules with internal layers:

- features/task_board/presentation
- features/task_board/domain
- features/task_board/data
- features/document_dashboard/presentation
- features/document_dashboard/domain
- features/document_dashboard/data
- core/shared for cross-cutting infrastructure

Benefits:

- Fewer merge conflicts across teams.
- Clear ownership by feature squad.
- Easier scaling while preserving clean architecture boundaries.

### 2) Key Architecture Seams and Boundaries

A new developer should understand these seams first:

- UI to state seam:
  - Event and state contracts in each feature BLoC package.
- State to domain/data seam:
  - BLoCs depend on repository interfaces, not concrete implementations.
- Domain to data seam:
  - Interface in domain, implementation in data.
- Composition seam:
  - Service wiring in [injection.dart](lib/src/core/di/injection.dart).
- Task drag seam:
  - Gesture/hover state in DragController versus business updates in TaskBloc.

These seams are what keep the two features independent while still enabling shared infrastructure through DI.

## Offline Functionality

### 1) Queuing Document Uploads (Offline Strategy)

When the device is offline, uploads are not attempted immediately. Instead, they are placed into a persistent upload queue.

Queue Design:

- Stored locally using a database (e.g., Isar or Hive in production)
- Each entry contains:
    - File path
    - Metadata (type, timestamp)
    - Upload state (pending, uploading, failed)
    - Retry count

Priority Model:

- FIFO (First-In-First-Out) for fairness
- Priority override for:
    - User-triggered retries
    - Time-sensitive documents (if applicable)

Retry Logic:

- Exponential backoff strategy:
    - 1s → 2s → 4s → 8s → capped
- Retry triggered when:
    - Connectivity is restored
    - App resumes from background
- Max retry threshold to prevent infinite loops

Partial Upload Recovery:

- For large files:
    - Use chunked uploads (in production)
    - Resume from last successful chunk
- Store upload progress locally to avoid restarting from zero

### 2) Task Sync Conflict Resolution

Conflicts may occur when:

- A user modifies a task offline
- Another user modifies the same task online

Strategy: Last Write Wins + Conflict Awareness

- Each task includes:
    - updatedAt timestamp
    - version or revision number

Resolution Flow

1. On reconnect, local changes are pushed
2. Server compares versions:
    - If no conflict → accept update
    - If conflict → resolve using:
        - Latest timestamp (default)
        - OR server-defined priority rules

User Visibility (important)

- In critical cases:
    - Mark task as “conflicted”
    - Allow user to manually resolve (future enhancement)

### 3) Connectivity Degradation Strategy

Features that Work Offline

- Viewing existing tasks
- Reordering tasks locally
- Creating/editing tasks (queued for sync)
- Adding documents to upload queue

Features that Require Connectivity

- Real-time document verification updates
- Final document status confirmation (verified/rejected)
- Syncing tasks across users/devices

Graceful Degradation

- UI reflects offline state (e.g., “Pending Sync”)
- Actions are not blocked, but deferred
- Background sync automatically resolves state when connectivity returns

## Security

### 1) Encryption Strategy (At Rest & In Transit)

In Transit

- All communication secured via HTTPS (TLS 1.2+)
- Certificate pinning recommended for production

At Rest

- Sensitive data (documents, metadata) encrypted using:
    - AES-256 encryption standard

Flutter Libraries / Primitives

- cryptography package for encryption
- flutter_secure_storage for secure key storage
- Platform-native encryption APIs where applicable

### 2) Secure Key Management (Android & iOS)

Encryption keys are never stored in plain text.

Platform-Specific Storage

- Android → Android Keystore
- iOS → Keychain

Approach

- Generate a unique symmetric key per device
- Store key securely using flutter_secure_storage
- Use this key to encrypt/decrypt files locally

Additional Safeguards

- Keys are:
    - Non-exportable
    - Hardware-backed where available
- Optional key rotation strategy for long-term security

### 3) Audit Trail (Compliance-Oriented Design)

To support compliance requirements, all critical actions are logged.

Events Tracked

- Document upload
- Status changes (processing → verified/rejected)
- Access/view events (optional based on requirement)
- Retry attempts and failures

Audit Log Structure

Each entry includes:

- Document ID
- Action type
- Timestamp
- User ID (if available)
- Device ID (optional)
- Previous → new state

Storage Strategy

- Local logging (temporary, for offline support)
- Synced to backend when online
- Backend acts as the source of truth

Integrity Considerations

- Logs should be:
    - Append-only
    - Immutable once written
- Optionally signed or hashed for tamper detection

## Current Limitations and Next-Step Hardening

Known limitations in current architecture:

- No persistent local database yet.
- No real API/network abstraction yet.
- Document stream subscription management is minimal.
- Domain/document/usecases package is present but currently unused.

Recommended next hardening steps:

1. Introduce datasource abstractions (remote/local) behind repositories.
2. Add persistence (for example Isar or Drift) and migration strategy.
3. Add subscription lifecycle management in DocumentBloc.
4. Add contract tests for repositories and bloc tests for event/state transitions.

## Summary

This codebase intentionally prioritizes clean feature isolation, fast iteration, and explicit event-driven state flows. The architecture already has clear seams for scaling into production-level shared infrastructure and persistence without tightly coupling Task Board and Document Dashboard.
