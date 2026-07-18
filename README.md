# ResponsiveLayoutKit

Size-class-driven responsive layout for SwiftUI — write your UI once, provide phone- or tablet-specific layouts only where they differ, and choose whether each decision reacts to the **local container** or the **window scene**.

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange)
![iOS 26+](https://img.shields.io/badge/iOS-26%2B-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)

## Why

SwiftUI's built-in `\.horizontalSizeClass` is *container-local*: inside a sheet on iPad it reports `.compact`, even though the window is regular-width. That's usually what you want — but sometimes you need the **scene's** truth: what environment is my *window* in, regardless of the sheet, column, or popover I happen to be rendered in?

ResponsiveLayoutKit models both explicitly with one vocabulary:

| `LayoutContext` | Answers | Backed by |
|---|---|---|
| `.container` *(default)* | "How much room does **this view** have?" | SwiftUI's native size classes — zero setup |
| `.scene` | "What environment is my **window** in?" | Per-scene observation of `UIWindowScene` |

Multi-scene aware by design: every window gets its own scene truth, so iPadOS Stage Manager windows with different sizes each resolve correctly. No singletons.

## Requirements

- iOS 26.0+
- Swift 6.2+ / Xcode 26+

## Installation

Add via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/KalebCooper/ResponsiveLayoutKit.git", from: "0.1.0")
]
```

Or in Xcode: **File ▸ Add Package Dependencies…** and paste the repository URL.

## Quick start

### Adapt one view per layout — identity-stable

```swift
import ResponsiveLayoutKit

ContentList()
    .responsive { content, layout in
        content
            .listStyle(layout == .tablet ? .insetGrouped : .plain)
            .padding(layout.value(phone: 8, tablet: 24))
    }
```

The closure receives the resolved `ResponsiveLayout` as a value — the same shape as `scrollTransition` and `visualEffect`. Crossing a size-class threshold (rotating, resizing in Stage Manager) changes *parameters*, not view structure: `@State`, scroll positions, and running tasks survive.

### Swap whole hierarchies — explicitly

```swift
ResponsiveView {
    PhoneTabBar()
} tablet: {
    TabletSplitView()
}
```

`ResponsiveView` is the one API that swaps subtrees on a layout change (and its two-builder shape says so). Keep state that must survive the swap above it or in an observable model.

### Resolve against the window, not the container

```swift
// In a compact-width sheet on iPad: .container → phone, .scene → tablet.
ResponsiveView(in: .scene) {
    CompactChrome()
} tablet: {
    RegularChrome()
}
```

Install an anchor once per scene root so every descendant — including sheets — resolves from a single probe:

```swift
WindowGroup {
    RootView()
        .sceneLayoutAnchor()
}
```

Views using `.scene` self-discover when no anchor exists, at the cost of a first-frame container fallback. Read scene truth directly anywhere:

```swift
@Environment(\.sceneLayout) private var sceneLayout
// sceneLayout?.horizontalSizeClass, .size, .interfaceOrientation, .safeAreaInsets, .responsiveLayout
```

### Force a layout — previews and tests

```swift
MyScreen()
    .responsiveLayout(.tablet)
```

### Accessibility-driven scrolling

```swift
SettingsForm()
    .accessibilityScrollView(.threshold())   // scrolls past .accessibility1 Dynamic Type or short windows
Dashboard()
    .accessibilityScrollView(.automatic)     // scrolls only when content overflows
```

Content lives in a single always-present `ScrollView` whose scrolling toggles — never a structural swap. A Dynamic Type change mid-session won't wipe a half-filled form's state, and `Spacer`-based layouts keep their shape while scrolling is inactive.

## View identity guarantees

The kit follows one rule: **identity behavior is visible in an API's shape.**

- Everything modifier-shaped — `.responsive { }`, `.responsiveLayout()`, `.accessibilityScrollView()`, `.sceneLayoutAnchor()` — is guaranteed identity-stable across layout changes.
- The one API that swaps subtrees, `ResponsiveView { } tablet: { }`, declares it by taking two builders.

## Demo app

The package includes a `ResponsiveLayoutKitDemo` executable target demonstrating every API live (scene readouts, container-vs-scene in a sheet, identity survival, accessibility scrolling). Open the package in Xcode, select the **ResponsiveLayoutKitDemo** scheme, and run on an iPad simulator. It is not part of any product — consumers of the library never build it.

## Documentation

All public symbols carry DocC comments. Build docs locally with **Product ▸ Build Documentation** in Xcode.

## License

MIT — see [LICENSE](LICENSE).
