//
//  SceneLayoutEnvironment.swift
//  ResponsiveLayoutKit
//

import Observation
import SwiftUI
import UIKit

/// Observable, scene-level layout truth for a single `UIWindowScene`.
///
/// One instance exists per connected scene (see `SceneLayoutRegistry`), so
/// every view in a window — including sheets, popovers, and UIKit-presented
/// hosting controllers — resolves to the same instance and sees the same
/// scene-wide values. Unlike the container-local
/// `EnvironmentValues.horizontalSizeClass`, these values describe the window:
/// a view inside a compact-width sheet on iPad still reads `.regular` here.
///
/// Obtain an instance via `View/sceneLayoutAnchor()` and
/// `EnvironmentValues/sceneLayout`, or implicitly through
/// ``ResponsiveView`` with ``LayoutContext/scene``.
@MainActor
@Observable
public final class SceneLayoutEnvironment {

  /// The scene's horizontal size class, read from the window.
  public private(set) var horizontalSizeClass: UserInterfaceSizeClass = .compact

  /// The scene's current interface orientation.
  public private(set) var interfaceOrientation: UIInterfaceOrientation = .portrait

  /// The safe-area insets of the scene's tracked window.
  public private(set) var safeAreaInsets: EdgeInsets = EdgeInsets()

  /// The size of the scene's coordinate space, in points.
  public private(set) var size: CGSize = .zero

  /// The scene's vertical size class, read from the window.
  public private(set) var verticalSizeClass: UserInterfaceSizeClass = .regular

  /// Whether the scene is wider than it is tall.
  ///
  /// This is the aspect-ratio answer layout math usually wants, and it is not
  /// one-to-one with ``interfaceOrientation`` — a freely resized window
  /// (Stage Manager, Split View) can have a landscape aspect ratio in any
  /// interface orientation. Prefer this for size-driven decisions; use
  /// ``interfaceOrientation`` only when the actual device orientation
  /// matters.
  public var isLandscapeAspectRatio: Bool {
    size.width > size.height
  }

  /// The layout family implied by the scene's horizontal size class.
  public var responsiveLayout: ResponsiveLayout {
    ResponsiveLayout(horizontalSizeClass: horizontalSizeClass)
  }

  @ObservationIgnored private var geometryObservation: NSKeyValueObservation?
  @ObservationIgnored private var traitRegistration: (any UITraitChangeRegistration)?
  @ObservationIgnored private weak var trackedWindow: UIWindow?
  @ObservationIgnored private weak var windowScene: UIWindowScene?

  init(windowScene: UIWindowScene) {
    self.windowScene = windowScene
    geometryObservation = windowScene.observe(\.effectiveGeometry, options: [.new]) {
      [weak self] _, _ in
      MainActor.assumeIsolated {
        self?.refresh()
      }
    }
    refresh()
  }

  /// Creates a detached instance carrying synthetic values, not backed by any
  /// `UIWindowScene`. Backs `View/sceneLayout(mocking:)` for previews and
  /// tests; never registered with `SceneLayoutRegistry`.
  init(mockValues: SceneLayoutMockValues) {
    apply(mockValues)
  }

  /// Replaces the published values that differ from the given synthetic
  /// values, so unchanged values fire no Observation invalidations.
  func apply(_ mockValues: SceneLayoutMockValues) {
    if horizontalSizeClass != mockValues.horizontalSizeClass {
      horizontalSizeClass = mockValues.horizontalSizeClass
    }
    if interfaceOrientation != mockValues.interfaceOrientation {
      interfaceOrientation = mockValues.interfaceOrientation
    }
    if safeAreaInsets != mockValues.safeAreaInsets {
      safeAreaInsets = mockValues.safeAreaInsets
    }
    if size != mockValues.size {
      size = mockValues.size
    }
    if verticalSizeClass != mockValues.verticalSizeClass {
      verticalSizeClass = mockValues.verticalSizeClass
    }
  }

  /// Whether the backing scene is still connected. Used by the registry to
  /// prune entries for scenes the system has torn down.
  var isSceneConnected: Bool {
    windowScene != nil
  }

  /// Begins tracking a window for trait changes and safe-area updates.
  /// Called by the discovery probe whenever a view resolves this scene;
  /// idempotent for an already-tracked window.
  func attach(window: UIWindow) {
    guard window !== trackedWindow else {
      refresh()
      return
    }
    if let trackedWindow, let traitRegistration {
      trackedWindow.unregisterForTraitChanges(traitRegistration)
    }
    trackedWindow = window
    traitRegistration = window.registerForTraitChanges(
      [UITraitHorizontalSizeClass.self, UITraitVerticalSizeClass.self]
    ) { [weak self] (_: UIWindow, _: UITraitCollection) in
      MainActor.assumeIsolated {
        self?.refresh()
      }
    }
    refresh()
  }

  private func refresh() {
    guard let windowScene else { return }
    interfaceOrientation = windowScene.effectiveGeometry.interfaceOrientation
    size = windowScene.effectiveGeometry.coordinateSpace.bounds.size

    guard let window = trackedWindow ?? windowScene.keyWindow else { return }
    let traits = window.traitCollection
    horizontalSizeClass = UserInterfaceSizeClass(traits.horizontalSizeClass) ?? horizontalSizeClass
    verticalSizeClass = UserInterfaceSizeClass(traits.verticalSizeClass) ?? verticalSizeClass

    let insets = window.safeAreaInsets
    safeAreaInsets = EdgeInsets(
      top: insets.top,
      leading: insets.left,
      bottom: insets.bottom,
      trailing: insets.right
    )
  }
}
