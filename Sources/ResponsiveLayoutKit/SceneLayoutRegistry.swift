//
//  SceneLayoutRegistry.swift
//  ResponsiveLayoutKit
//

import UIKit

/// Process-wide map of `UIWindowScene` → ``SceneLayoutEnvironment``.
///
/// The registry itself holds no layout state — it only hands out the one
/// instance per connected scene, so multiple windows (iPadOS Stage Manager,
/// visionOS, Catalyst) each get their own scene truth. Entries for
/// disconnected scenes are pruned lazily on access.
@MainActor
final class SceneLayoutRegistry {

    static let shared = SceneLayoutRegistry()

    private var environments: [ObjectIdentifier: SceneLayoutEnvironment] = [:]

    private init() {}

    func environment(for windowScene: UIWindowScene) -> SceneLayoutEnvironment {
        pruneDisconnectedScenes()
        let key = ObjectIdentifier(windowScene)
        if let existing = environments[key] {
            return existing
        }
        let environment = SceneLayoutEnvironment(windowScene: windowScene)
        environments[key] = environment
        return environment
    }

    private func pruneDisconnectedScenes() {
        environments = environments.filter(\.value.isSceneConnected)
    }
}
