//
//  SceneLayoutDemo.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI
import UIKit

/// Live readout of scene-level truth versus container-local truth. Resize the
/// window in Stage Manager or rotate the device to watch values update.
struct SceneLayoutDemo: View {

    @Environment(\.containerResponsiveLayout) private var containerLayout
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.responsiveLayout) private var resolvedLayout
    @Environment(\.sceneLayout) private var sceneLayout
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        List {
            Section("Scene (window truth)") {
                if let sceneLayout {
                    LabeledContent("Layout", value: name(for: sceneLayout.responsiveLayout))
                    LabeledContent("Horizontal", value: name(for: sceneLayout.horizontalSizeClass))
                    LabeledContent("Vertical", value: name(for: sceneLayout.verticalSizeClass))
                    LabeledContent(
                        "Size",
                        value: "\(Int(sceneLayout.size.width)) × \(Int(sceneLayout.size.height))"
                    )
                    LabeledContent("Orientation", value: name(for: sceneLayout.interfaceOrientation))
                    LabeledContent(
                        "Landscape aspect",
                        value: sceneLayout.isLandscapeAspectRatio ? "yes" : "no"
                    )
                } else {
                    Text("Discovering scene…")
                }
            }
            Section("Container (local truth)") {
                LabeledContent("Horizontal", value: name(for: horizontalSizeClass))
                LabeledContent("Vertical", value: name(for: verticalSizeClass))
            }
            Section("Resolved values (\\.responsiveLayout)") {
                LabeledContent("Canonical", value: name(for: resolvedLayout))
                LabeledContent("Container-only", value: name(for: containerLayout))
            }
            Section {
                Text("Resize the window in Stage Manager or rotate the device; scene values update live via the anchor installed at the app root.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Scene Layout")
    }

    private func name(for layout: ResponsiveLayout) -> String {
        layout == .tablet ? "tablet" : "phone"
    }

    private func name(for orientation: UIInterfaceOrientation) -> String {
        switch orientation {
        case .landscapeLeft: "landscape left"
        case .landscapeRight: "landscape right"
        case .portrait: "portrait"
        case .portraitUpsideDown: "portrait upside down"
        default: "unknown"
        }
    }

    private func name(for sizeClass: UserInterfaceSizeClass?) -> String {
        switch sizeClass {
        case .compact: "compact"
        case .regular: "regular"
        default: "unknown"
        }
    }
}

#Preview("Mocked tablet scene") {
    NavigationStack {
        SceneLayoutDemo()
    }
    .sceneLayout(
        mocking: SceneLayoutMockValues(
            size: CGSize(width: 1210, height: 856),
            horizontalSizeClass: .regular,
            interfaceOrientation: .landscapeLeft
        )
    )
}
