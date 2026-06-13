# JobBoard

A small iOS app for browsing, searching and viewing job postings. Built with SwiftUI, MVVM and `async/await`.

## Setup

Requirements:

- Xcode 16 or newer
- iOS 17+ deployment target (the app uses the `@Observable` macro and `ContentUnavailableView`)

To run:

1. Clone the repository.
2. Open `JobBoard.xcodeproj` in Xcode.
3. Select the `JobBoard` scheme and an iOS Simulator (e.g. iPhone 16).
4. Press <kbd>⌘R</kbd> to build and run.
5. Press <kbd>⌘U</kbd> to run the test suite.

There is no networking setup or API key required — the app is fed by a bundled JSON file (`JobBoard/Resources/jobs.json`).

## Architecture

MVVM with a thin composition root for dependency injection.

```
JobBoard/
├── App/
│   └── AppDependencies.swift        // composition root
├── Models/
│   └── Job.swift                    // Job, SalaryRange, formatting
├── Services/
│   ├── JobService.swift             // protocol + error type
│   └── LocalJSONJobService.swift    // bundled-JSON implementation
├── Resources/
│   └── jobs.json                    // mock job feed
├── Common/
│   └── ViewState.swift              // idle / loading / loaded / empty / failed
├── Features/
│   ├── JobList/
│   │   ├── JobListViewModel.swift
│   │   ├── JobListView.swift
│   │   └── JobRowView.swift
│   └── JobDetails/
│       └── JobDetailsView.swift
└── JobBoardApp.swift                // @main entry
```

### Layering

- **Models** — plain `Codable` value types. Zero framework dependencies.
- **Services** — `JobService` is a protocol; `LocalJSONJobService` is the production implementation that reads the bundled JSON (with a configurable artificial delay so loading states are visible during development). Swapping to a real REST API later means writing a `RemoteJobService` and changing one line in `AppDependencies.live()`.
- **ViewModels** — `JobListViewModel` is `@MainActor` and uses the `@Observable` macro. It owns a `ViewState<[Job]>` and exposes a `searchText` binding. Filtering is implemented as a pure static function so it's trivial to unit-test in isolation.
- **Views** — SwiftUI views are dumb. They switch on `viewModel.state` and render one of four branches (`loading`, `empty`, `failed`, `loaded`). The list uses `NavigationStack` + `navigationDestination(for:)` for type-safe navigation into `JobDetailsView`.

### Dependency injection

A single `AppDependencies` struct constructs and exposes all collaborators. The `@main` entry creates `AppDependencies.live()` and threads the `JobService` into the root view model. In tests, view models are constructed with a `MockJobService` directly — no global container, no service locator.

### State handling

The four required states map onto the `ViewState` enum:

| State    | UI                                                |
|----------|---------------------------------------------------|
| loading  | Centered `ProgressView`                            |
| empty    | `ContentUnavailableView` (different copy depending on whether the user has a search query) |
| failed   | Error illustration + message + **Try again** button |
| loaded   | `List` of `JobRowView` cells with navigation links |

### Search

Search is handled with SwiftUI's `.searchable`. The view model treats whitespace-only queries as empty and matches case-insensitively against both `title` and `company`. The filter is debounced naturally by SwiftUI's text input cadence; for a real REST-backed list I'd add an explicit `Task.sleep`-based debounce before hitting the network.

## Testing

The test target uses Apple's **Swift Testing** framework (not XCTest).

- `JobListViewModelTests` — 13 tests covering load success / failure / empty, search by title, search by company, case-insensitivity, whitespace queries, clearing the query, refresh semantics, and the pure filter function.
- `LocalJSONJobServiceTests` — 5 tests covering successful decoding, missing-resource error, invalid-JSON error, and salary formatting (USD year, EUR hour).
- `MockJobService` — test double conforming to `JobService`, with a swappable behavior and a call counter.

To run only the unit tests from the command line:

```bash
xcodebuild test \
  -scheme JobBoard \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:JobBoardTests \
  -enableCodeCoverage YES
```

### Code coverage

Code coverage is enabled in the `JobBoard` scheme and scoped to the `JobBoard.app` target so the simulator runtime doesn't pollute the numbers. Latest run:

| File                           | Coverage |
|--------------------------------|----------|
| `JobBoard.app` **overall**     | **96.33% (446/463)** |
| `JobListViewModel.swift`       | 98.15%   |
| `LocalJSONJobService.swift`    | 96.67%   |
| `JobService.swift` (error)     | 100%     |
| `Job.swift` / `SalaryRange`    | 84.62%   |
| `ViewState.swift`              | 100%     |
| `JobListView.swift`            | 92.59%   |
| `JobDetailsView.swift`         | 97.97%   |
| `JobRowView.swift`             | 100%     |
| `AppDependencies.swift`        | 100%     |
| `JobBoardApp.swift`            | 100%     |

To regenerate the report after a test run:

```bash
xcrun xccov view --report --only-targets /tmp/JobBoardCoverage.xcresult
```

The view-side coverage comes from `ViewRenderingTests`, which uses `ImageRenderer.cgImage` to force SwiftUI to evaluate each view body in every state (loading, empty, failed, loaded, plus the details screen). The image is discarded — only the body-evaluation side effect matters.

## Assumptions

A handful of things I decided rather than asked:

1. **Mock data over a public API.** A live job-board API would force you to register, get credentials, and deal with rate limiting just to run the app. The bundled JSON keeps the assignment self-contained and makes the loading/empty/error states deterministic. The service layer is still abstracted behind a protocol, so swapping in a real backend is a small change.
2. **iOS 17+ minimum.** This unlocks `@Observable`, `ContentUnavailableView`, and `NavigationStack` + `navigationDestination(for:)`, which together produce noticeably cleaner code than the iOS 16 equivalents.
3. **`@Observable` over `ObservableObject`.** The new macro replaces the `@Published` boilerplate and works seamlessly with `@State` for view-owned view models.
4. **No persistence.** The brief didn't ask for "saved jobs" or offline support. Adding it later would mean a `SavedJobsStore` and either SwiftData or a small file-backed cache.
5. **Salary formatting is locale-aware.** `SalaryRange.formatted(locale:)` accepts a locale so the production app respects the user's region while tests pin to a known locale (`en_US`, `en_IE`) for deterministic assertions.
6. **A small artificial delay** is built into `LocalJSONJobService` so the loading state is actually visible while developing. Tests pass `simulatedDelay: .zero`.
7. **Multiplatform safety.** A few iOS-only SwiftUI modifiers are wrapped in `#if os(iOS)` because the Xcode template targets macOS as well as iOS. The app itself is iOS-first.

## What I'd add next

In rough priority order:

- A real `RemoteJobService` backed by `URLSession` + a small `APIClient`, with retry/backoff for transient failures.
- Pagination in the list (`InfiniteScrollView` or `task(id:)`-driven fetch).
- "Saved jobs" persistence via SwiftData.
- Snapshot tests for the three non-loaded states.
- A handful of XCUITests covering search → details → back navigation.
