---
name: responsivelayoutkit
description: Use when building SwiftUI apps (iOS 26+) with ResponsiveLayoutKit — a.k.a. RLK — that adapt layout to phone vs tablet / size class, or need window-scene truth instead of container-local size classes — sidebar-vs-tab-bar, column counts, sheets on iPad that must know the scene is regular-width, readable content width capping, or accessibility-driven conditional scrolling. Triggers on the ResponsiveLayoutKit (RLK) library and its symbols: ResponsiveView, the .responsive, .responsiveLayout, .responsiveContentWidth, .accessibilityScrollView, and .accessibilityScrollFloor view modifiers, .sceneLayoutAnchor and the sceneLayout / responsiveLayout / containerResponsiveLayout environment values, .sceneLayout(mocking:), and the ResponsiveLayout, LayoutContext, SceneLayoutEnvironment, SceneLayoutReader, SceneLayoutMockValues, AccessibilityScrollMode, and AccessibilityScrollHeightThreshold types. Also use when a user refers to the library as RLK, when deciding between container-local and scene-wide size-class resolution, when the layout family should feed computed properties or pure functions as a value, when mocking scene size in previews/tests, or when a layout change is unexpectedly resetting @State.
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
| **Layout family as a value** — computed properties, view arguments, pure functions | `@Environment(\.responsiveLayout)` (canonical) / `@Environment(\.containerResponsiveLayout)` (container-only) |
| Cap scroll content to a readable width on tablet | `.responsiveContentWidth(tabletFraction:)` on the ScrollView's *content* |
| Force a layout in previews/tests/containers | `.responsiveLayout(_:)` |
| Mock the whole scene (family AND size/orientation/safe area) in previews/tests | `.sceneLayout(mocking: SceneLayoutMockValues(…))` |
| Read raw scene truth (size, orientation, safe area) | `@Environment(\.sceneLayout)` + `.sceneLayoutAnchor()`, or `SceneLayoutReader { … }` (self-discovering) |
| Scroll only when content may not fit (Dynamic Type / short window) | `.accessibilityScrollView(_:)` |
| Let a greedy view (image/Map) compress before scrolling engages | `.accessibilityScrollFloor(_:)` on the greedy child |

**Prefer `.responsive` over `ResponsiveView`** unless the subtrees are structurally different — `.responsive` preserves state. Do not branch on `layout` *inside* the `.responsive` closure to return different view types; that reintroduces an identity swap. Change parameters, not structure.

**Never hand-roll the resolution chain** (`override ?? sceneLayout?.responsiveLayout ?? .phone` in app code is a bug — it skips the container step). Read `@Environment(\.responsiveLayout)`; RLK owns the order.

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

### `\.responsiveLayout` + `\.containerResponsiveLayout` — the resolved family as a value
```swift
@Environment(\.responsiveLayout) var layout: ResponsiveLayout            // override → scene → container → phone
@Environment(\.containerResponsiveLayout) var local: ResponsiveLayout    // override → container → phone
```
For family-as-data: computed properties, `onChange` triggers, view arguments, pure functions. No closure, no subtree swap, honors `.responsiveLayout(_:)` overrides.
```swift
private var sheetEdge: SheetEdge { layout.value(phone: .bottom, tablet: .leading) }
.toolbarTitleDisplayMode(layout.value(phone: .inlineLarge, tablet: .large))
```
`\.responsiveLayout` reads scene truth from the environment only — install `.sceneLayoutAnchor()` at the scene root; without one (or first frame) it falls back to the container size class. `\.containerResponsiveLayout` deliberately ignores scene truth: in a compact iPad sheet it reads `.phone` while `\.responsiveLayout` reads `.tablet`.

### `.responsiveContentWidth(tabletFraction:)` — readable content width
```swift
func responsiveContentWidth(tabletFraction: CGFloat = ResponsiveLayout.baseTabletLayoutRatio) -> some View
```
Caps content to a fraction of the *scene* width on tablet, centered; full-width on phone and before scene discovery. UIKit `readableContentGuide` analogue.
```swift
ScrollView {
    SettingsContent().responsiveContentWidth()   // content, NOT the ScrollView
}
```
Three rules baked in: (1) apply to the ScrollView's **content**, never the ScrollView, so gutter pans still scroll; (2) it reads **scene** width, not display width — Split View/Stage Manager panes inset relative to their own window; (3) never reimplement with `containerRelativeFrame(.horizontal)` — on a vertical ScrollView's cross axis the container resolves against the content's own width, so fractions < 1 feed back and collapse content toward zero.

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
isLandscapeAspectRatio: Bool                   // size.width > size.height — NOT 1:1 with interfaceOrientation
```
Reuses an upstream anchor's instance if one exists; multiple anchors in one scene resolve to the same instance. For layout math, prefer `isLandscapeAspectRatio` over `interfaceOrientation` — a freely resized window (Stage Manager/Split View) can be landscape-shaped in any orientation, and the orientation enum drags in `.unknown`/`.portraitUpsideDown`.

### `SceneLayoutReader` — closure-based scene truth, self-discovering
```swift
SceneLayoutReader { sceneLayout in                 // SceneLayoutEnvironment?
    SidebarColumn(width: (sceneLayout?.size.width ?? proposedWidth) * 0.33)
}
```
Uses the inherited anchor when one exists upstream; otherwise discovers the scene locally through a hidden probe. Either way `nil` for the first layout pass — declare the fallback inline (the value in `?? …` is per-call-site judgment: a proposed width, `.infinity` for "no cap," an assumed portrait).

### `.sceneLayout(mocking:)` + `SceneLayoutMockValues` — previews and tests
```swift
struct SceneLayoutMockValues: Equatable {
    init(size: CGSize,
         horizontalSizeClass: UserInterfaceSizeClass,
         verticalSizeClass: UserInterfaceSizeClass = .regular,
         interfaceOrientation: UIInterfaceOrientation = .portrait,
         safeAreaInsets: EdgeInsets = EdgeInsets())
}
func sceneLayout(mocking values: SceneLayoutMockValues) -> some View
```
Publishes a synthetic scene so **every** scene-truth read — family, size, orientation, safe area — resolves against declared values, present from the very first frame:
```swift
#Preview("Tablet, landscape window") {
    MyScreen().sceneLayout(mocking: SceneLayoutMockValues(
        size: CGSize(width: 1210, height: 856), horizontalSizeClass: .regular))
}
```
Replaces the old `.responsiveLayout(.tablet)` + `.sceneLayoutAnchor()` preview pairing (which left size reads resolving against the live canvas). Plain environment injection — composable, no hidden machinery; a `.responsiveLayout(_:)` override still wins family resolution.

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

### `.accessibilityScrollFloor(_:)` — compressible floor for greedy views
```swift
func accessibilityScrollFloor(_ height: CGFloat) -> some View   // = frame(minHeight: h, idealHeight: h)
```
A greedy child — an aspect-ratio image, a `Map` — reports a large width-derived *ideal* height, so `.automatic`'s fit test overflows permanently and scrolling always engages, even when the view could compress and everything would fit. The floor pins the child's ideal to `height`, so the fit test measures the compressed layout, and sets `minHeight` so it never shrinks below the floor. No max — it still grows to natural size when space allows.
```swift
VStack {
    headerSection
    Image(.hero).resizable().aspectRatio(1.6, contentMode: .fit)
        .accessibilityScrollFloor(150)   // compress to 150pt before scrolling engages
}
.accessibilityScrollView()
```
Semantics: content compresses the floored children first; scrolling engages only when even the floored layout overflows (floored children then render at the floor). Designed for `.automatic`; harmless under the other modes.

## Common mistakes

- **Expecting `ResponsiveView` to preserve `@State` across a rotate/resize.** It won't — that's the swap semantics. Use `.responsive` for state-preserving decoration, or lift the state above the `ResponsiveView`.
- **Branching on `layout` inside `.responsive` to return different structures.** Reintroduces identity churn. Vary parameters (`layout.value(phone:tablet:)`), not view types.
- **Using `.container` when you meant the window.** Inside a sheet/popover/column on iPad, `.container` is compact. For "what is my *window*," pass `in: .scene`.
- **Reading `\.sceneLayout` without an anchor and expecting a value immediately.** It's `nil` until discovery completes; guard with `if let`. Apply `.sceneLayoutAnchor()` at the scene root to make it reliably available and avoid the first-frame container fallback for `.scene` resolution.
- **Assuming `.threshold` scrolling reacts to window height with no scene.** Height only votes once the scene is discovered; without it only the Dynamic Type test applies.
- **Hand-rolling layout resolution** (`override ?? sceneLayout?.responsiveLayout ?? .phone`). Skips the container-size-class step and forks RLK's canonical order. Read `@Environment(\.responsiveLayout)` instead.
- **`containerRelativeFrame` for content-width capping in a vertical ScrollView.** Cross-axis feedback collapses content toward zero width. Use `.responsiveContentWidth()` (scene-width-based).
- **A greedy view under `.automatic` scrolling permanently.** An aspect-ratio image/Map's large ideal height makes the fit test always overflow. Give it `.accessibilityScrollFloor(_:)`.
- **Pairing `.responsiveLayout(.tablet)` with `.sceneLayoutAnchor()` in previews to fake a tablet.** Size-reading code still sees the live (phone-sized) canvas. Use `.sceneLayout(mocking:)` — one modifier, family AND size.
- **Deriving landscape from `interfaceOrientation` for layout math.** Freely resized windows break the equivalence. Use `SceneLayoutEnvironment.isLandscapeAspectRatio`.
- **Wrong platform.** iOS 26+ only (uses `UIWindowScene.effectiveGeometry`, `@Entry`, `@Observable`, `onGeometryChange`).
