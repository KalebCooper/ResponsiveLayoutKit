# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `\.responsiveLayout` environment value: the canonically resolved layout
  family as a value (override → scene truth → container size class → phone),
  for feeding computed properties, view arguments, and pure functions without
  the closure APIs. `\.containerResponsiveLayout` is the container-shaped
  companion that deliberately ignores scene truth.
- `responsiveContentWidth(tabletFraction:)`: caps scroll content to a readable
  fraction of the scene width on tablet layouts (default
  `baseTabletLayoutRatio`), full-width on phone — the SwiftUI analogue of
  UIKit's `readableContentGuide`. Applied to a `ScrollView`'s content, the
  scroll surface stays edge-to-edge.
- `accessibilityScrollFloor(_:)`: declares a compressible floor for greedy
  views (aspect-ratio images, maps) inside `accessibilityScrollView(_:)`, so
  they shrink to the floor before the scrolling decision fires instead of
  forcing permanent scrolling via their large ideal height.
- `sceneLayout(mocking:)` + `SceneLayoutMockValues`: publish a synthetic scene
  environment for previews and tests, making every scene-truth read — family, size,
  orientation, safe area — resolve against declared values on any canvas.
- `SceneLayoutEnvironment.isLandscapeAspectRatio`: whether the scene is wider
  than tall — the aspect-ratio answer layout math wants, distinct from
  `interfaceOrientation` under freely resized windows.
- `SceneLayoutReader` is now public: closure-based scene-truth access with
  self-discovery when no anchor exists upstream.
- DocC article "First Frame and Scene Discovery": the `sceneLayout == nil`
  first-frame contract and the prescribed one-expression fallback patterns.
- Demo app coverage for the new APIs: resolved-value readouts, a readable
  content width screen, a compressible-floor screen, and a mocked-scene
  preview.

### Changed

- Claude Code skill (`responsivelayoutkit`) documents the new value-level,
  content-width, floor, mock, and reader APIs, and warns against hand-rolled
  resolution chains. Plugin bumped to 1.1.0.

## [0.2.0] - 2026-07-19

Minor release: tooling, tests, and documentation. No public API changes.

### Added

- DocC documentation catalog: a landing page plus a getting-started article.
- Expanded test coverage: layout-precedence resolution, `LayoutContext` branches, and the `ResponsiveLayout` ratio constants.
- iPad CI destination: iPhone and iPad simulators run as a matrix, pinned to `OS=latest`.
- swift-format lint and DocC docbuild jobs in CI.
- `SECURITY.md`: supported versions and a private vulnerability report channel.
- `Demo/README.md`: XcodeGen setup steps for the demo app.

### Changed

- Documentation wording pass across README, CONTRIBUTING, and CHANGELOG.

### Fixed

- `CONTRIBUTING.md` referenced the removed `ResponsiveLayoutKit-Package` scheme; it now points at the `ResponsiveLayoutKit` scheme.
- `Package.swift` test-target comment pointed at a nonexistent `Demo/README`; corrected to `Demo/README.md`.

## [0.1.2] - 2026-07-18

No public API changes; library sources are identical to 0.1.1.

### Changed

- Claude Code skill (`responsivelayoutkit`) now advertises the **RLK** abbreviation in its discoverable `description` (and body), so an agent is more likely to invoke it when a user refers to the library as RLK. Plugin bumped to 1.0.1.

## [0.1.1] - 2026-07-18

No public API changes; library sources are identical to 0.1.0.

### Changed

- Demo moved from a SwiftPM `.executableTarget` to a standalone Xcode app under `Demo/`, generated from `Demo/project.yml` via XcodeGen. SwiftPM can't build an iOS `.app`, so the old executable target crashed at launch on the simulator (`missing bundleID for main bundle`); the app target runs correctly. It references the package as a local dependency and is never shipped via SwiftPM.

### Added

- Claude Code plugin marketplace (`cooperlabs`) with a `responsivelayoutkit` skill so consumers using Claude Code can install the library's API and identity-semantics guidance.
- Brand assets in `Assets/` (logo, social-preview banner); demo app icon; README header.

### Removed

- `CODE_OF_CONDUCT.md`.

## [0.1.0] - 2026-07-17

### Added

- `LayoutContext`: explicit `.container` (default) vs `.scene` layout resolution.
- `SceneLayoutEnvironment`: per-scene `@Observable` window truth (size classes, size, orientation, safe areas), driven by `UIWindowScene.effectiveGeometry` and window trait observation. One instance per connected scene; multi-window aware.
- `View.sceneLayoutAnchor()` and `EnvironmentValues.sceneLayout` for publishing and reading scene truth.
- `ResponsiveView`: explicit phone/tablet hierarchy swapping with documented identity semantics.
- `View.responsive(in:content:)`: identity-stable, layout-dependent decoration in the `scrollTransition` closure shape, plus `ResponsiveLayout.value(phone:tablet:)`.
- `View.responsiveLayout(_:)`: subtree layout override for previews and tests.
- `View.accessibilityScrollView(_:)`: identity-stable conditional scrolling with `.automatic`, `.threshold`, and `.explicit` modes.
- `ResponsiveLayoutKitDemo` executable target demonstrating every API (not part of any product).
- Test target using Swift Testing.
