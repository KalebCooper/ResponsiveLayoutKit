//
//  ResponsiveModifierDemo.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI

/// The `.responsive { content, layout in }` closure form: layout-dependent
/// decoration with stable structural identity — the counter survives
/// size-class threshold crossings.
struct ResponsiveModifierDemo: View {

    @State private var counter = 0

    var body: some View {
        VStack(spacing: 16) {
            Stepper("Counter: \(counter)", value: $counter)
            Text("Cross a size-class threshold (rotate, or resize in Stage Manager): the counter survives, because the closure form changes parameters — padding, tint, width — not view structure.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .responsive { content, layout in
            content
                .padding(layout.value(phone: 16, tablet: 40))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(layout.value(phone: Color.blue, tablet: Color.green).opacity(0.15))
                )
                .frame(maxWidth: layout.value(phone: CGFloat.infinity, tablet: 480))
        }
        .padding()
        .navigationTitle("Responsive Modifier")
    }
}

/// `.responsiveContentWidth()` caps scroll content to a readable fraction of
/// the scene width on tablet layouts — phone stays full-width. Applied to the
/// content inside the ScrollView, never the ScrollView, so gutter pans still
/// scroll.
struct ResponsiveContentWidthDemo: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Readable content width")
                    .font(.title2.bold())
                Text("On an iPad (or any regular-width scene), this column is capped to \(Int(ResponsiveLayout.baseTabletLayoutRatio * 100))% of the scene width and centered; the scroll surface behind it stays edge-to-edge. On iPhone it spans the full width. Resize in Stage Manager or Split View: the cap tracks the window, not the display.")
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.12))
                        .frame(height: 64)
                        .overlay(Text("Row \(index + 1)"))
                }
            }
            .padding()
            .responsiveContentWidth()
        }
        .navigationTitle("Content Width")
    }
}

#Preview("Content width, mocked tablet") {
    NavigationStack {
        ResponsiveContentWidthDemo()
    }
    .sceneLayout(
        mocking: SceneLayoutMockValues(
            size: CGSize(width: 1210, height: 856),
            horizontalSizeClass: .regular
        )
    )
}
