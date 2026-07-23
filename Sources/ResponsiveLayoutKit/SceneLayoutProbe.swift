//
//  SceneLayoutProbe.swift
//  ResponsiveLayoutKit
//

import SwiftUI
import UIKit

/// Hidden UIKit view that discovers the `UIWindowScene` its SwiftUI position
/// belongs to and resolves the scene's shared ``SceneLayoutEnvironment`` from
/// the registry. Works from any context — sheets, additional windows, and
/// UIKit-presented hosting controllers — because discovery walks the actual
/// window, not the SwiftUI environment.
struct SceneLayoutProbe: UIViewRepresentable {

  let onResolve: @MainActor (SceneLayoutEnvironment) -> Void

  func makeUIView(context: Context) -> ProbeView {
    ProbeView(onResolve: onResolve)
  }

  func updateUIView(_ uiView: ProbeView, context: Context) {
    uiView.onResolve = onResolve
  }

  final class ProbeView: UIView {

    var onResolve: @MainActor (SceneLayoutEnvironment) -> Void

    init(onResolve: @escaping @MainActor (SceneLayoutEnvironment) -> Void) {
      self.onResolve = onResolve
      super.init(frame: .zero)
      isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) is not supported")
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      guard let window, let windowScene = window.windowScene else { return }
      let environment = SceneLayoutRegistry.shared.environment(for: windowScene)
      environment.attach(window: window)
      let resolve = onResolve
      // Defer the state write out of the current view update.
      Task { @MainActor in
        resolve(environment)
      }
    }
  }
}
