//
//  EnvironmentValues+ResponsiveLayoutKit.swift
//  ResponsiveLayoutKit
//

import SwiftUI

public extension EnvironmentValues {

    /// Forces every responsive API in the subtree to a specific layout,
    /// overriding both container and scene resolution. Set via
    /// `View/responsiveLayout(_:)`; `nil` means no override.
    @Entry var responsiveLayoutOverride: ResponsiveLayout? = nil

    /// The scene-level layout environment published by the nearest
    /// `View/sceneLayoutAnchor()` upstream, or `nil` when no anchor exists.
    /// APIs that need scene truth fall back to local discovery when `nil`.
    @Entry var sceneLayout: SceneLayoutEnvironment? = nil
}
