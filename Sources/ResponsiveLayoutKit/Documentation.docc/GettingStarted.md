# Getting Started

Adapt a SwiftUI view to phone and tablet layouts, then reach for scene truth and accessibility scrolling as needed.

## Overview

Add the package, `import ResponsiveLayoutKit`, and adapt any view. The APIs below are ordered from the one you reach for most often to the specialized ones. All of them require iOS 26.0+ and Swift 6.2+.

### Adapt one view per layout

Use ``SwiftUICore/View/responsive(in:content:)`` when a single hierarchy only needs different parameters per layout — padding, list style, column width. The closure receives the view and the resolved ``ResponsiveLayout`` as a value, the same shape as `scrollTransition` and `visualEffect`:

```swift
import ResponsiveLayoutKit

ContentList()
    .responsive { content, layout in
        content
            .listStyle(layout == .tablet ? .insetGrouped : .plain)
            .padding(layout.value(phone: 8, tablet: 24))
    }
```

Crossing a size-class threshold (rotating, or resizing in Stage Manager) changes parameters rather than view structure, so `@State`, scroll positions, and running tasks all survive. Use ``ResponsiveLayout/value(phone:tablet:)`` to pick a per-layout value inline.

### Swap whole hierarchies

When phone and tablet are genuinely different structures — a tab bar versus a split view — use ``ResponsiveView``. Its two-builder shape declares that it swaps subtrees:

```swift
ResponsiveView {
    PhoneTabBar()
} tablet: {
    TabletSplitView()
}
```

Crossing a layout threshold tears down one subtree and builds the other, resetting any `@State` inside. Keep state that must survive the swap above the ``ResponsiveView`` or in an observable model.

### Resolve against the window scene

By default a decision resolves against the local container. To resolve against the window instead, pass ``LayoutContext/scene``. In a compact-width sheet on iPad, ``LayoutContext/container`` reads phone while ``LayoutContext/scene`` reads tablet:

```swift
ResponsiveView(in: .scene) {
    CompactChrome()
} tablet: {
    RegularChrome()
}
```

Install ``SwiftUICore/View/sceneLayoutAnchor()`` once near each scene root so every descendant, including sheets, resolves scene truth from a single probe:

```swift
WindowGroup {
    RootView()
        .sceneLayoutAnchor()
}
```

Views using ``LayoutContext/scene`` self-discover their window even with no anchor, though the first layout pass falls back to the container size class until discovery completes. Read scene truth directly through the ``SwiftUICore/EnvironmentValues/sceneLayout`` environment value:

```swift
@Environment(\.sceneLayout) private var sceneLayout
// sceneLayout?.horizontalSizeClass, .size, .interfaceOrientation, .safeAreaInsets, .responsiveLayout
```

The value is `nil` until discovery completes, so guard it with `if let`. See ``SceneLayoutEnvironment`` for the full set of scene-wide values.

### Force a layout in previews and tests

``SwiftUICore/View/responsiveLayout(_:)`` overrides both container and scene resolution for the whole subtree — useful for previews, snapshot tests, or containers that should always behave one way. Pass `nil` to remove an override set upstream:

```swift
MyScreen()
    .responsiveLayout(.tablet)
```

### Scroll only when content may not fit

``SwiftUICore/View/accessibilityScrollView(_:)`` makes a view scrollable when large Dynamic Type or a short window means its content might clip. Content always lives in a single always-present `ScrollView` whose scrolling toggles on and off, so it is never a structural swap and a mid-session Dynamic Type change never resets `@State`:

```swift
SettingsForm()
    .accessibilityScrollView(.threshold())   // scrolls past .accessibility1 Dynamic Type or short windows
Dashboard()
    .accessibilityScrollView(.automatic)     // scrolls only when content overflows
```

Choose the strategy with ``AccessibilityScrollMode``, and tune the window-height cutoff with ``AccessibilityScrollHeightThreshold``.
