# Contributing to ResponsiveLayoutKit

Thanks for your interest in contributing!

## Getting started

1. Fork and clone the repository.
2. Open the package directory in Xcode 26 or later.
3. Build the `ResponsiveLayoutKit` scheme; run tests with the `ResponsiveLayoutKit-Package` scheme (⌘U) on an iOS 26+ simulator.
4. The `ResponsiveLayoutKitDemo` scheme runs a demo app exercising every API — useful for manually verifying behavior on iPad (Stage Manager resizing, sheets, Dynamic Type).

## Guidelines

- **Identity contract:** modifier-shaped APIs must remain structurally identity-stable across layout changes; only APIs whose shape visibly declares alternative subtrees (like `ResponsiveView`) may swap. Changes that violate this will be declined.
- **Public API:** every public symbol needs a DocC comment, including identity semantics where relevant.
- **Tests:** extract decision logic into pure, testable functions (see `AccessibilityScrollMode.thresholdRequiresScrolling`) and cover it with Swift Testing.
- **Style:** match the existing code. Declarations are ordered alphabetically within their groupings unless initialization order or a logical dependency dictates otherwise.
- **Scope:** the package is intentionally small. Open an issue to discuss additions before investing in a large PR.

## Pull requests

- Target `main`.
- Keep PRs focused — one concern per PR.
- Update `CHANGELOG.md` under **Unreleased**.
- CI must pass (build + tests on an iOS simulator).

## Reporting issues

Use the issue templates. For layout bugs, include device/simulator, window configuration (full screen, Stage Manager size, sheet, etc.), size classes involved, and a minimal reproduction if possible.
