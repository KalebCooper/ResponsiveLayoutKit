# ``ResponsiveLayoutKit``

Size-class-driven responsive layout for SwiftUI, resolved against the local container or the window scene.

## Overview

ResponsiveLayoutKit adapts a SwiftUI interface to `phone`- and `tablet`-class layouts on iOS 26+. Write the UI once and supply layout differences only where they matter, letting each decision react to the space a view occupies or to the window scene it lives in.

Every responsive API resolves a ``ResponsiveLayout`` in the same order: an explicit override wins first, then scene or container truth, then a phone fallback.

- ``ResponsiveLayout/phone`` — a compact, single-column layout.
- ``ResponsiveLayout/tablet`` — an expanded, regular-width layout.

### The container-vs-scene model

SwiftUI's `\.horizontalSizeClass` is container-local: inside a sheet on iPad it reports `.compact` even though the window is regular-width. That is usually what you want, but sometimes you need the scene's truth instead. ``LayoutContext`` names both sources with one vocabulary:

| ``LayoutContext`` | Answers | Backed by |
| --- | --- | --- |
| ``LayoutContext/container`` (default) | "How much room does this view have?" | SwiftUI's native size classes, zero setup |
| ``LayoutContext/scene`` | "What environment is my window in?" | Per-scene observation of `UIWindowScene` |

Each connected scene owns its own ``SceneLayoutEnvironment``, so iPadOS Stage Manager windows of different sizes each resolve correctly. Nothing is shared through a singleton. A view inside a compact-width sheet on iPad still reads the scene's regular width through ``LayoutContext/scene``.

### The identity-stability rule

The kit follows one rule: **identity behavior is visible in an API's shape.**

- Everything modifier-shaped — ``SwiftUICore/View/responsive(in:content:)``, ``SwiftUICore/View/responsiveLayout(_:)``, ``SwiftUICore/View/accessibilityScrollView(_:)``, ``SwiftUICore/View/sceneLayoutAnchor()`` — is identity-stable across layout changes. The layout arrives as a value in a single closure, so crossing a size-class threshold (for example, resizing in Stage Manager) changes parameters, not view structure. `@State`, scroll positions, and running tasks survive the transition.
- ``ResponsiveView`` is the one API that swaps subtrees, and its two-builder shape declares it. Phone and tablet content are distinct hierarchies with distinct structural identity; crossing a threshold tears down one and builds the other, resetting any `@State` inside. Keep state that must survive the switch above the ``ResponsiveView`` or in an observable model.

## Topics

### Essentials

- <doc:GettingStarted>

### Adapting layout

- ``SwiftUICore/View/responsive(in:content:)``
- ``ResponsiveView``
- ``SwiftUICore/View/responsiveLayout(_:)``

### The layout model

- ``ResponsiveLayout``
- ``LayoutContext``

### Scene truth

- ``SwiftUICore/View/sceneLayoutAnchor()``
- ``SwiftUICore/EnvironmentValues/sceneLayout``
- ``SceneLayoutEnvironment``

### Accessibility scrolling

- ``SwiftUICore/View/accessibilityScrollView(_:)``
- ``AccessibilityScrollMode``
- ``AccessibilityScrollHeightThreshold``
