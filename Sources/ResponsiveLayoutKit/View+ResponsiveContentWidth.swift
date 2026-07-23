//
//  View+ResponsiveContentWidth.swift
//  ResponsiveLayoutKit
//

import SwiftUI

extension View {

  /// Constrains this view to a readable fraction of the scene's width on
  /// tablet layouts, centered. Phone layouts are uncapped: the content
  /// expands to the full proposed width, so views that would otherwise hug
  /// their content become full-width.
  ///
  /// Apply to the content *inside* a `ScrollView` — never to the
  /// `ScrollView` itself — so the scroll surface stays edge-to-edge and pans
  /// that start in the side gutters still scroll:
  ///
  /// ```swift
  /// ScrollView {
  ///     SettingsContent()
  ///         .responsiveContentWidth()
  /// }
  /// ```
  ///
  /// The cap deliberately reads the *scene* width:
  ///
  /// - Not `containerRelativeFrame`: on the cross axis of a vertical
  ///   `ScrollView` the container resolves against the content's own width,
  ///   so fractions below 1 feed back and collapse the content toward zero.
  /// - Not the display width: in Split View or Stage Manager the scene is
  ///   the app's window, so panes inset relative to their own width.
  ///
  /// Uncapped on phone layouts and, for the first frame, before scene
  /// discovery completes. This is the SwiftUI analogue of UIKit's
  /// `readableContentGuide`.
  ///
  /// - Parameter tabletFraction: The fraction of the scene width the content
  ///   may occupy on tablet layouts. Defaults to
  ///   ``ResponsiveLayout/baseTabletLayoutRatio``.
  public func responsiveContentWidth(
    tabletFraction: CGFloat = ResponsiveLayout.baseTabletLayoutRatio
  ) -> some View {
    modifier(ResponsiveContentWidthModifier(tabletFraction: tabletFraction))
  }
}

/// Computes the width cap for `View/responsiveContentWidth(tabletFraction:)`:
/// `.infinity` (no cap) unless the layout is tablet and the scene width is
/// known and positive. The cap never goes below zero, so a negative fraction
/// can't produce an invalid frame. Separated as a pure function so the policy
/// is unit-testable.
func resolvedContentMaxWidth(
  layout: ResponsiveLayout,
  sceneWidth: CGFloat?,
  tabletFraction: CGFloat
) -> CGFloat {
  guard layout == .tablet, let sceneWidth, sceneWidth > 0 else {
    return .infinity
  }
  return max(sceneWidth * tabletFraction, 0)
}

private struct ResponsiveContentWidthModifier: ViewModifier {

  let tabletFraction: CGFloat

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.responsiveLayoutOverride) private var override

  func body(content: Content) -> some View {
    SceneLayoutReader { sceneLayout in
      content
        .frame(maxWidth: maxWidth(sceneLayout: sceneLayout))
        .frame(maxWidth: .infinity)
    }
  }

  private func maxWidth(sceneLayout: SceneLayoutEnvironment?) -> CGFloat {
    resolvedContentMaxWidth(
      layout: resolvedResponsiveLayout(
        override: override,
        sceneLayout: sceneLayout?.responsiveLayout,
        horizontalSizeClass: horizontalSizeClass
      ),
      sceneWidth: sceneLayout?.size.width,
      tabletFraction: tabletFraction
    )
  }
}
