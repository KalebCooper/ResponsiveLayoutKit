---
name: responsivelayoutkit
description: Use when building SwiftUI apps (iOS 26+) with ResponsiveLayoutKit — a.k.a. RLK — that adapt layout to phone vs tablet / size class, or need window-scene truth instead of container-local size classes — sidebar-vs-tab-bar, column counts, sheets on iPad that must know the scene is regular-width, or accessibility-driven conditional scrolling. Triggers on the ResponsiveLayoutKit (RLK) library and its symbols: ResponsiveView, the .responsive and .responsiveLayout view modifiers, .sceneLayoutAnchor and the sceneLayout environment value, .accessibilityScrollView, and the ResponsiveLayout, LayoutContext, SceneLayoutEnvironment, AccessibilityScrollMode, and AccessibilityScrollHeightThreshold types. Also use when a user refers to the library as RLK, when deciding between container-local and scene-wide size-class resolution, or when a layout change is unexpectedly resetting @State.
---

# ResponsiveLayoutKit

ResponsiveLayoutKit — **RLK** for short — is SwiftUI responsive layout for **iOS 26+** (Swift 6.2+). `import ResponsiveLayoutKit`. Adapts UI to `phone` vs `tablet` layout families, and lets each decision resolve against the **local container** or the **window scene**.

## Core principle: identity behavior is visible in the API's shape

- **Modifier-shaped APIs are identity-stable.** `.responsive { }`, `.responsiveLayout()`, `.accessibilityScrollView()`, `.sceneLayoutAnchor()` never rebuild the subtree across a layout change — they pass layout as a *value* into one closure. `@State`, scroll positions, and running tasks survive.
- **`ResponsiveView { } tablet: { }` swaps subtrees.** Its two-builder shape declares that phone and tablet are distinct hierarchies with distinct identity. Crossing a size-class threshold tears down one and builds the other, **resetting any `@State` inside**. That is correct only when the two structures genuinely differ.

State that must survive a `ResponsiveView` swap belongs **above** the `ResponsiveView` or in an observable model.

## Choosing an API

| Need | Use |
|---|---|
| Tweak one hierarchy's params (padding, style, width) per layout | `.responsive { content, layout in … }` |
| Two genuinely different hierarchies (tab bar vs split view) | `ResponsiveView { } tablet: { }` |
| Force a layout in previews/tests/containers | `.responsiveLayout(_:)` |
| Read raw scene truth (size, orientation, safe area) | `@Environment(\.sceneLayout)` + `.sceneLayoutAnchor()` |
| Scroll only when content may not fit (Dynamic Type / short window) | `.accessibilityScrollView(_:)` |

**Prefer `.responsive` over `ResponsiveView`** unless the subtrees are structurally different — `.responsive` preserves state. Do not branch on `layout` *inside* the `.responsive` closure to return different view types; that reintroduces an identity swap. Change parameters, not structure.

## Container vs scene resolution

`LayoutContext` (default `.container` everywhere it appears):

- `.container` — how much room *this view* has. Backed by SwiftUI's native `\.horizontalSizeClass`. Zero setup. A sheet/popover/split column on iPad reports **compact** width here.
- `.scene` — what environment the *window* is in, ignoring the local container. That same iPad sheet reads **regular**. Use for structural decisions: sidebar-vs-tab-bar, column counts.

Resolution order for every responsive API: **`responsiveLayoutOverride` (if set) → scene truth (`.scene`) or container size class (`.container`) → phone fallback**.

`.scene` self-discovers its window even with no anchor, but falls back to the container size class for the **first layout pass** while discovery completes (one frame). Install `.sceneLayoutAnchor()` once at each scene root so every descendant — including sheets — resolves from a single probe and skips that first-frame fallback.

## API reference

### `.responsive` — identity-stable, per-layout decoration
```swift
func responsive<Content: View>(
    in context: LayoutContext = .container,
    @ViewBuilder content: @escaping (Self, ResponsiveLayout) -> Content
) -> some View
```
Same closure shape as `scrollTransition`/`visualEffect` — `(theView, layout)`:
```swift
ContentList()
    .responsive { content, layout in
        content
            .listStyle(layout == .tablet ? .insetGrouped : .plain)
            .padding(layout.value(phone: 8, tablet: 24))
    }
```

### `ResponsiveView` — explicit hierarchy swap
```swift
init(
    in context: LayoutContext = .container,
    @ViewBuilder phone: @escaping () -> PhoneContent,
    @ViewBuilder tablet: @escaping () -> TabletContent
)
```
```swift
ResponsiveView {
    PhoneTabBar()
} tablet: {
    TabletSplitView()
}

// Resolve against the window instead of the container:
ResponsiveView(in: .scene) {
    CompactChrome()
} tablet: {
    RegularChrome()
}
```

### `ResponsiveLayout` — the layout family
```swift
enum ResponsiveLayout: Equatable, Sendable { case phone, tablet }
init(horizontalSizeClass: UserInterfaceSizeClass?) // nil & .compact → .phone; .regular → .tablet
func value<Value>(phone: Value, tablet: Value) -> Value   // .tablet → tablet, else phone
static let baseTabletLayoutRatio: CGFloat    = 0.66  // primary tablet pane width fraction
static let compactTabletLayoutRatio: CGFloat = 0.33  // secondary tablet pane width fraction
```

### `.responsiveLayout(_:)` — force a layout
```swift
func responsiveLayout(_ layout: ResponsiveLayout?) -> some View
```
Overrides both container and scene resolution for the whole subtree. `nil` removes an override set upstream. Backed by `EnvironmentValues.responsiveLayoutOverride`.
```swift
MyScreen().responsiveLayout(.tablet)   // previews, snapshot tests, forced containers
```

### `.sceneLayoutAnchor()` + `\.sceneLayout` — scene truth
```swift
func sceneLayoutAnchor() -> some View                       // publish scene truth to descendants
@Environment(\.sceneLayout) var sceneLayout: SceneLayoutEnvironment?   // read it (nil until discovered)
```
```swift
WindowGroup {
    RootView().sceneLayoutAnchor()   // apply once near each scene root
}
```
`SceneLayoutEnvironment` (`@MainActor @Observable`, one instance **per connected window scene** — multi-window / Stage Manager aware):
```swift
horizontalSizeClass: UserInterfaceSizeClass   // scene-wide, read from the window
verticalSizeClass:   UserInterfaceSizeClass
size:                CGSize                    // scene coordinate-space size, points
interfaceOrientation: UIInterfaceOrientation
safeAreaInsets:      EdgeInsets
responsiveLayout:    ResponsiveLayout          // implied by horizontalSizeClass
```
Reuses an upstream anchor's instance if one exists; multiple anchors in one scene resolve to the same instance.

### `.accessibilityScrollView(_:)` — identity-stable conditional scrolling
```swift
func accessibilityScrollView(_ mode: AccessibilityScrollMode = .automatic) -> some View
```
Content always lives in **one** always-present `ScrollView` whose scrolling is toggled — never a structural swap, so a mid-session Dynamic Type change won't wipe a half-filled form. When scrolling is inactive, content gets the full available height, so `Spacer`-based layouts keep their shape.
```swift
enum AccessibilityScrollMode {
    case automatic                                  // scrolls only when content overflows (.basedOnSize)
    case explicit(contentHeight: CGFloat)           // scrolls when your measured height > viewport
    case threshold(                                 // measurement-free; ideal for sheets/modals
        dynamicTypeSize: DynamicTypeSize = .accessibility1,
        windowHeight: AccessibilityScrollHeightThreshold = .regular
    )
}
enum AccessibilityScrollHeightThreshold {   // .value in points
    case regular      // 650
    case large        // 750
    case custom(CGFloat)
}
```
`.threshold` engages scrolling when `dynamicTypeSize > threshold` **OR** window height `< threshold.value`. Dynamic Type is read from the local environment; window height is scene truth (needs the scene; an undiscovered/`0` height casts no scrolling vote). Comparison is strict `>` — Dynamic Type exactly *at* the threshold does **not** scroll.
```swift
SettingsForm().accessibilityScrollView(.threshold())   // default: > .accessibility1 or < 650pt
Dashboard().accessibilityScrollView(.automatic)        // overflow-only
```

## Common mistakes

- **Expecting `ResponsiveView` to preserve `@State` across a rotate/resize.** It won't — that's the swap semantics. Use `.responsive` for state-preserving decoration, or lift the state above the `ResponsiveView`.
- **Branching on `layout` inside `.responsive` to return different structures.** Reintroduces identity churn. Vary parameters (`layout.value(phone:tablet:)`), not view types.
- **Using `.container` when you meant the window.** Inside a sheet/popover/column on iPad, `.container` is compact. For "what is my *window*," pass `in: .scene`.
- **Reading `\.sceneLayout` without an anchor and expecting a value immediately.** It's `nil` until discovery completes; guard with `if let`. Apply `.sceneLayoutAnchor()` at the scene root to make it reliably available and avoid the first-frame container fallback for `.scene` resolution.
- **Assuming `.threshold` scrolling reacts to window height with no scene.** Height only votes once the scene is discovered; without it only the Dynamic Type test applies.
- **Wrong platform.** iOS 26+ only (uses `UIWindowScene.effectiveGeometry`, `@Entry`, `@Observable`, `onGeometryChange`).
