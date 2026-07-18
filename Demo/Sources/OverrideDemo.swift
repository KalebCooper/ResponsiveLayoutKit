//
//  OverrideDemo.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI

/// `responsiveLayout(_:)` forces a subtree to one layout, overriding both
/// container and scene resolution — the hook previews and snapshot tests use.
struct OverrideDemo: View {

    @State private var override: ResponsiveLayout?

    var body: some View {
        List {
            Section("responsiveLayout(_:)") {
                Picker("Override", selection: $override) {
                    Text("None").tag(ResponsiveLayout?.none)
                    Text("Phone").tag(ResponsiveLayout?.some(.phone))
                    Text("Tablet").tag(ResponsiveLayout?.some(.tablet))
                }
                .pickerStyle(.segmented)
            }
            Section("Result") {
                ResponsiveView {
                    Label("Phone layout", systemImage: "iphone")
                } tablet: {
                    Label("Tablet layout", systemImage: "ipad.landscape")
                }
                .responsiveLayout(override)
            }
        }
        .navigationTitle("Override")
    }
}
