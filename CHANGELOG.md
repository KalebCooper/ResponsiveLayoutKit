# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-07-17

### Added

- `LayoutContext` — explicit `.container` (default) vs `.scene` layout resolution.
- `SceneLayoutEnvironment` — per-scene `@Observable` window truth (size classes, size, orientation, safe areas), driven by `UIWindowScene.effectiveGeometry` and window trait observation. One instance per connected scene; multi-window aware.
- `View.sceneLayoutAnchor()` and `EnvironmentValues.sceneLayout` for publishing and reading scene truth.
- `ResponsiveView` — explicit phone/tablet hierarchy swapping with documented identity semantics.
- `View.responsive(in:content:)` — identity-stable, layout-dependent decoration in the `scrollTransition` closure shape, plus `ResponsiveLayout.value(phone:tablet:)`.
- `View.responsiveLayout(_:)` — subtree layout override for previews and tests.
- `View.accessibilityScrollView(_:)` — identity-stable conditional scrolling with `.automatic`, `.threshold`, and `.explicit` modes.
- `ResponsiveLayoutKitDemo` executable target demonstrating every API (not part of any product).
- Test target using Swift Testing.
