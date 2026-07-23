//
//  SceneLayoutMock.swift
//  ResponsiveLayoutKit
//

import SwiftUI
import UIKit

/// A synthetic set of scene-layout values for previews and tests.
///
/// Feed an instance to `View/sceneLayout(mocking:)` to make every scene-truth
/// read — family, size, orientation, and safe area — resolve against declared
/// values instead of a live `UIWindowScene`. Only ``size`` and
/// ``horizontalSizeClass`` are required; the rest default to sensible
/// portrait-window values.
public struct SceneLayoutMockValues: Equatable, Sendable {

  /// The mocked scene-wide horizontal size class.
  public var horizontalSizeClass: UserInterfaceSizeClass

  /// The mocked interface orientation.
  public var interfaceOrientation: UIInterfaceOrientation

  /// The mocked safe-area insets of the scene's window.
  public var safeAreaInsets: EdgeInsets

  /// The mocked size of the scene's coordinate space, in points.
  public var size: CGSize

  /// The mocked scene-wide vertical size class.
  public var verticalSizeClass: UserInterfaceSizeClass

  public init(
    size: CGSize,
    horizontalSizeClass: UserInterfaceSizeClass,
    verticalSizeClass: UserInterfaceSizeClass = .regular,
    interfaceOrientation: UIInterfaceOrientation = .portrait,
    safeAreaInsets: EdgeInsets = EdgeInsets()
  ) {
    self.horizontalSizeClass = horizontalSizeClass
    self.interfaceOrientation = interfaceOrientation
    self.safeAreaInsets = safeAreaInsets
    self.size = size
    self.verticalSizeClass = verticalSizeClass
  }
}

extension View {

  /// Publishes a synthetic ``SceneLayoutEnvironment`` carrying the given
  /// values, so every scene-truth read in this subtree — layout family,
  /// scene size, orientation, safe area — resolves against them instead of
  /// a live window scene.
  ///
  /// Intended for previews and tests. One modifier replaces the
  /// `View/responsiveLayout(_:)` + `View/sceneLayoutAnchor()` pairing and
  /// keeps size-reading code truthful on any preview canvas:
  ///
  /// ```swift
  /// #Preview("Tablet, landscape window") {
  ///     MyScreen()
  ///         .sceneLayout(
  ///             mocking: SceneLayoutMockValues(
  ///                 size: CGSize(width: 1210, height: 856),
  ///                 horizontalSizeClass: .regular
  ///             )
  ///         )
  /// }
  /// ```
  ///
  /// The mock is plain environment injection: it sets
  /// `EnvironmentValues/sceneLayout` for descendants and composes like any
  /// other environment write — wrap it, conditionalize it, or build your own
  /// preview helpers on top. It does not affect ancestors, and a
  /// `View/responsiveLayout(_:)` override still wins family resolution.
  public func sceneLayout(mocking values: SceneLayoutMockValues) -> some View {
    modifier(SceneLayoutMockModifier(values: values))
  }
}

private struct SceneLayoutMockModifier: ViewModifier {

  let values: SceneLayoutMockValues

  @State private var environment: SceneLayoutEnvironment

  init(values: SceneLayoutMockValues) {
    self.values = values
    _environment = State(initialValue: SceneLayoutEnvironment(mockValues: values))
  }

  func body(content: Content) -> some View {
    content
      .environment(\.sceneLayout, environment)
      // Derived from the observable — not from `values` — so both environment
      // keys update in the same pass when `apply(_:)` lands, and reading
      // `responsiveLayout` registers Observation tracking for that re-render.
      .environment(\.sceneResponsiveLayout, environment.responsiveLayout)
      .onChange(of: values) { _, newValues in
        environment.apply(newValues)
      }
  }
}
