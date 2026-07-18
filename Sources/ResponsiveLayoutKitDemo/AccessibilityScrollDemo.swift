//
//  AccessibilityScrollDemo.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI

/// Threshold-mode accessibility scrolling. Crank the Dynamic Type picker past
/// `.accessibility1`: scrolling engages without rebuilding the content — the
/// toggle keeps its state. The `Spacer`-pinned label shows the full-height
/// shim keeping spacer layouts intact while scrolling is inactive.
struct AccessibilityScrollDemo: View {

    @State private var dynamicTypeSize: DynamicTypeSize = .large
    @State private var isToggleOn = true

    var body: some View {
        VStack(spacing: 0) {
            Picker("Dynamic Type", selection: $dynamicTypeSize) {
                ForEach(DynamicTypeSize.allCases, id: \.self) { size in
                    Text(String(describing: size)).tag(size)
                }
            }
            .padding()

            Divider()

            VStack(spacing: 24) {
                Text("Threshold mode")
                    .font(.title2.bold())
                Text("Content lives in one ScrollView whose scrolling engages past the Dynamic Type or window-height threshold. Identity stays stable — this toggle survives crossings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Toggle("Survives threshold crossings", isOn: $isToggleOn)
                Spacer()
                Label("Pinned by Spacer", systemImage: "arrow.down.to.line")
            }
            .padding()
            .accessibilityScrollView(.threshold())
            .dynamicTypeSize(dynamicTypeSize)
        }
        .navigationTitle("Accessibility Scroll")
    }
}
