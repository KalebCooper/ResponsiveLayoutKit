//
//  View+SceneLayout.swift
//  ResponsiveLayoutKit
//

import SwiftUI

public extension View {

    /// Discovers this view's window scene and publishes its shared
    /// ``SceneLayoutEnvironment`` into the environment for all descendants.
    ///
    /// Apply once near the root of each scene (or any subtree — a sheet, a
    /// UIKit-hosted view) that reads `EnvironmentValues/sceneLayout` or uses
    /// ``LayoutContext/scene``:
    ///
    /// ```swift
    /// WindowGroup {
    ///     RootView()
    ///         .sceneLayoutAnchor()
    /// }
    /// ```
    ///
    /// Anchoring is optional for ``ResponsiveView`` — it self-discovers when
    /// no anchor exists — but an explicit anchor makes scene truth available
    /// to descendants through a single probe. Multiple anchors in one scene
    /// resolve to the same per-scene instance. If an anchor already exists
    /// upstream, this modifier reuses its instance instead of probing again.
    func sceneLayoutAnchor() -> some View {
        modifier(SceneLayoutAnchorModifier())
    }
}

private struct SceneLayoutAnchorModifier: ViewModifier {

    @State private var discovered: SceneLayoutEnvironment?
    @Environment(\.sceneLayout) private var inherited

    func body(content: Content) -> some View {
        content
            .background {
                if inherited == nil {
                    SceneLayoutProbe { discovered = $0 }
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                }
            }
            .environment(\.sceneLayout, inherited ?? discovered)
    }
}
