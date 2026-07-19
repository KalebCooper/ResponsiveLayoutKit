//
//  AccessibilityScrollView.swift
//  ResponsiveLayoutKit
//

import SwiftUI

/// Window-height thresholds below which threshold-mode scrolling activates.
public enum AccessibilityScrollHeightThreshold: Equatable, Sendable {

  /// A caller-supplied height threshold, in points.
  case custom(CGFloat)

  /// Suits content designed for larger phones and small split-view panes.
  case large

  /// Suits content designed for typical phone heights.
  case regular

  /// The threshold height, in points.
  public var value: CGFloat {
    switch self {
    case .custom(let value): value
    case .large: 750
    case .regular: 650
    }
  }
}

/// Strategy for deciding when content should become scrollable — typically so
/// large Dynamic Type sizes or short windows never clip content.
public enum AccessibilityScrollMode: Equatable, Sendable {

  /// Lets the system decide: scrolling engages only when content exceeds
  /// the available height (via `scrollBounceBehavior(.basedOnSize)`).
  case automatic

  /// Enables scrolling when a caller-measured content height exceeds the
  /// available height. Use when you already know the content's true height.
  case explicit(contentHeight: CGFloat)

  /// Enables scrolling when the Dynamic Type size exceeds a threshold or
  /// the window is shorter than a threshold. Measurement-free — use in
  /// sheets and modals where fitting can't be measured reliably. Dynamic
  /// Type is read from the local environment; window height is scene truth
  /// from ``SceneLayoutEnvironment``.
  case threshold(
    dynamicTypeSize: DynamicTypeSize = .accessibility1,
    windowHeight: AccessibilityScrollHeightThreshold = .regular
  )

  /// Decision logic for ``threshold(dynamicTypeSize:windowHeight:)``,
  /// separated for testability. A `nil` or non-positive window height
  /// (scene not yet discovered) contributes no vote.
  static func thresholdRequiresScrolling(
    dynamicTypeSize: DynamicTypeSize,
    dynamicTypeSizeThreshold: DynamicTypeSize,
    windowHeight: CGFloat?,
    windowHeightThreshold: CGFloat
  ) -> Bool {
    if dynamicTypeSize > dynamicTypeSizeThreshold {
      return true
    }
    guard let windowHeight, windowHeight > 0 else { return false }
    return windowHeight < windowHeightThreshold
  }
}

extension View {

  /// Makes this view scrollable when the strategy given by `mode` decides
  /// its content may not fit vertically.
  ///
  /// Content always lives inside a single `ScrollView` whose scrolling is
  /// enabled or disabled by the strategy, so structural identity is stable:
  /// crossing a Dynamic Type or window-size threshold never rebuilds the
  /// content or resets its `@State`. When scrolling is inactive, content is
  /// given the full available height, so `Spacer`-based layouts behave as
  /// they would outside a scroll view. The container claims the space it's
  /// offered, like any `ScrollView`.
  public func accessibilityScrollView(_ mode: AccessibilityScrollMode = .automatic) -> some View {
    AccessibilityScrollContainer(mode: mode) { self }
  }
}

/// Shared chassis for all ``AccessibilityScrollMode`` strategies: one
/// always-present `ScrollView` with scrolling toggled, never a structural
/// swap between scrolling and non-scrolling subtrees.
private struct AccessibilityScrollContainer<Content: View>: View {

  let mode: AccessibilityScrollMode
  @ViewBuilder let content: () -> Content

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var viewportHeight: CGFloat?

  var body: some View {
    // `mode` is constant per call site, so this switch never flips
    // identity at runtime.
    switch mode {
    case .automatic, .explicit:
      scrollContainer(windowHeight: nil)
    case .threshold:
      SceneLayoutReader { sceneLayout in
        scrollContainer(windowHeight: sceneLayout?.size.height)
      }
    }
  }

  private func isScrollEnabled(windowHeight: CGFloat?) -> Bool {
    switch mode {
    case .automatic:
      // Always enabled; `.basedOnSize` keeps fitting content inert.
      true
    case .explicit(let contentHeight):
      viewportHeight.map { contentHeight > $0 } ?? false
    case .threshold(let dynamicTypeSizeThreshold, let windowHeightThreshold):
      AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: dynamicTypeSize,
        dynamicTypeSizeThreshold: dynamicTypeSizeThreshold,
        windowHeight: windowHeight,
        windowHeightThreshold: windowHeightThreshold.value
      )
    }
  }

  private func scrollContainer(windowHeight: CGFloat?) -> some View {
    ScrollView {
      content()
        .frame(minHeight: viewportHeight)
    }
    .scrollBounceBehavior(.basedOnSize)
    .scrollDisabled(!isScrollEnabled(windowHeight: windowHeight))
    .onGeometryChange(for: CGFloat.self, of: \.size.height) { newValue in
      viewportHeight = newValue
    }
  }
}
