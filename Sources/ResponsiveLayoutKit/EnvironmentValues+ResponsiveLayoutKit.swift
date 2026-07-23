//
//  EnvironmentValues+ResponsiveLayoutKit.swift
//  ResponsiveLayoutKit
//

import SwiftUI

extension EnvironmentValues {

  /// The layout family resolved against this view's *container*: an explicit
  /// override from `View/responsiveLayout(_:)` wins, then the container's
  /// horizontal size class, then ``ResponsiveLayout/phone``.
  ///
  /// Deliberately ignores scene truth — inside a compact-width sheet on iPad
  /// this reads ``ResponsiveLayout/phone`` while ``responsiveLayout`` reads
  /// ``ResponsiveLayout/tablet``. Use it when a decision should follow the
  /// space this view actually occupies (see ``LayoutContext/container``).
  public var containerResponsiveLayout: ResponsiveLayout {
    responsiveLayoutOverride ?? ResponsiveLayout(horizontalSizeClass: horizontalSizeClass)
  }

  /// The canonically resolved layout family, as a value: an explicit override
  /// from `View/responsiveLayout(_:)` wins, then scene truth published by
  /// `View/sceneLayoutAnchor()`, then the container's horizontal size class,
  /// then ``ResponsiveLayout/phone``.
  ///
  /// Read it when the layout family should feed computed properties, view
  /// arguments, or pure functions rather than decorate a view:
  ///
  /// ```swift
  /// @Environment(\.responsiveLayout) private var layout
  ///
  /// var sheetEdge: SheetEdge {
  ///     layout.value(phone: .bottom, tablet: .leading)
  /// }
  /// ```
  ///
  /// Scene truth is read from the environment only, so install
  /// `View/sceneLayoutAnchor()` at the scene root. Without one — or for the
  /// first frame before discovery completes — resolution falls back to the
  /// container size class, the same order `View/responsive(in:content:)`
  /// uses with ``LayoutContext/scene``.
  public var responsiveLayout: ResponsiveLayout {
    resolvedResponsiveLayout(
      override: responsiveLayoutOverride,
      sceneLayout: sceneResponsiveLayout,
      horizontalSizeClass: horizontalSizeClass
    )
  }

  /// Forces every responsive API in the subtree to a specific layout,
  /// overriding both container and scene resolution. Set via
  /// `View/responsiveLayout(_:)`; `nil` means no override.
  @Entry public var responsiveLayoutOverride: ResponsiveLayout? = nil

  /// The scene-level layout environment published by the nearest
  /// `View/sceneLayoutAnchor()` upstream, or `nil` when no anchor exists.
  /// APIs that need scene truth fall back to local discovery when `nil`.
  @Entry public var sceneLayout: SceneLayoutEnvironment? = nil

  /// A plain-value snapshot of the scene's layout family, written by
  /// `View/sceneLayoutAnchor()` and `View/sceneLayout(mocking:)` alongside
  /// ``sceneLayout``. Kept as a value so the nonisolated ``responsiveLayout``
  /// getter never touches the `@MainActor` observable.
  @Entry var sceneResponsiveLayout: ResponsiveLayout? = nil
}
