//
//  SceneLayoutReader.swift
//  ResponsiveLayoutKit
//

import SwiftUI

/// Provides its content closure with the scene's ``SceneLayoutEnvironment``,
/// self-discovering the window scene when no anchor exists upstream.
///
/// The closure receives the inherited environment when a
/// `View/sceneLayoutAnchor()` exists upstream, otherwise one discovered
/// locally through a hidden probe. Either way the value is `nil` for the
/// first layout pass while discovery completes, so declare the fallback
/// inline where the value is used:
///
/// ```swift
/// SceneLayoutReader { sceneLayout in
///     SidebarColumn(width: (sceneLayout?.size.width ?? proposedWidth) * 0.33)
/// }
/// ```
///
/// See <doc:SceneDiscovery> for the first-frame contract and recommended
/// fallback patterns.
public struct SceneLayoutReader<Content: View>: View {

  @ViewBuilder let content: (SceneLayoutEnvironment?) -> Content

  @State private var discovered: SceneLayoutEnvironment?
  @Environment(\.sceneLayout) private var inherited

  public init(@ViewBuilder content: @escaping (SceneLayoutEnvironment?) -> Content) {
    self.content = content
  }

  public var body: some View {
    content(inherited ?? discovered)
      .background {
        if inherited == nil {
          SceneLayoutProbe { discovered = $0 }
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .allowsHitTesting(false)
        }
      }
  }
}
