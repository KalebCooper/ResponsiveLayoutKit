# First Frame and Scene Discovery

Understand when scene truth becomes available, what happens on the first frame, and how to write one consistent fallback.

## Overview

Scene truth is discovered through a hidden UIKit probe that must land in a window before it can identify its `UIWindowScene`. That happens during the first layout pass, and the resulting state write is deferred out of that pass, so **``SwiftUICore/EnvironmentValues/sceneLayout`` is `nil` for the first rendered frame — always**, even directly under a ``SwiftUICore/View/sceneLayoutAnchor()``. From the second frame on, the anchored value is reliably present and updates live.

This is a contract, not a bug to work around: design every scene-size read to tolerate one `nil` frame.

### The layout family already falls back correctly

Family resolution never needs a hand-written fallback. Every RLK resolver — ``SwiftUICore/View/responsive(in:content:)``, ``ResponsiveView``, and the ``SwiftUICore/EnvironmentValues/responsiveLayout`` environment value — applies the same order:

1. An explicit ``SwiftUICore/View/responsiveLayout(_:)`` override.
2. Scene truth, once discovered.
3. The container's horizontal size class.
4. ``ResponsiveLayout/phone``.

For the first frame, step 3 answers — the container size class is available immediately and usually matches the scene. Do not re-implement this chain; read the resolved value.

### Size reads declare their fallback inline

Only code reading ``SceneLayoutEnvironment/size`` (or orientation, or safe area) needs a first-frame story, and the right fallback is a per-call-site judgment — a proposed width, no cap at all, or an assumed portrait. Write it as one expression where the value is used, so the intent is visible:

```swift
// A width cap that is simply absent until the scene is known:
let cap = sceneLayout.map { $0.size.width * 0.66 } ?? .infinity

// A sidebar width that uses the container's proposal for one frame:
let width = (sceneLayout?.size.width ?? proposedWidth) * fraction
```

``SceneLayoutReader`` packages the read-with-self-discovery half of this pattern: it hands its closure the inherited environment when an anchor exists upstream and discovers one locally otherwise, so the closure only supplies the fallback:

```swift
SceneLayoutReader { sceneLayout in
    SidebarColumn(width: (sceneLayout?.size.width ?? proposedWidth) * 0.33)
}
```

### Previews and tests skip discovery entirely

``SwiftUICore/View/sceneLayout(mocking:)`` publishes a synthetic environment that is present from the very first frame, with a declared size, size classes, orientation, and safe area — so previews exercise the discovered state deterministically, on any canvas:

```swift
#Preview("Tablet, landscape window") {
    MyScreen()
        .sceneLayout(
            mocking: SceneLayoutMockValues(
                size: CGSize(width: 1210, height: 856),
                horizontalSizeClass: .regular
            )
        )
}
```

To exercise the *pre-discovery* frame in a preview, render without an anchor or mock and confirm the layout is acceptable — it is the state every user sees for one frame.

## Topics

### Scene truth

- ``SwiftUICore/View/sceneLayoutAnchor()``
- ``SwiftUICore/EnvironmentValues/sceneLayout``
- ``SceneLayoutReader``
- ``SwiftUICore/View/sceneLayout(mocking:)``
