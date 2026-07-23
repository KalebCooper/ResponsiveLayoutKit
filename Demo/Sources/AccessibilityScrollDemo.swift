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

/// Compressible-floor semantics under `.automatic`: the greedy gradient
/// (aspect-ratio-fitted, like a hero image) shrinks toward its 150pt floor as
/// Dynamic Type grows, and scrolling engages only when even the floored
/// layout can't fit. Without the floor, a greedy view's large ideal height
/// would make the fit test overflow — and scroll — permanently.
struct AccessibilityScrollFloorDemo: View {

    init(dynamicTypeSize: DynamicTypeSize = .large) {
        _dynamicTypeSize = State(initialValue: dynamicTypeSize)
    }

    @State private var dynamicTypeSize: DynamicTypeSize
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
                Text("Compressible floor")
                    .font(.title2.bold())
                Text("Crank Dynamic Type: the gradient compresses first, down to its 150pt floor. Scrolling engages only when even the floored layout overflows — and the toggle survives, because nothing is structurally swapped.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                LinearGradient(
                    colors: [.blue, .teal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .aspectRatio(1.6, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    Label("Floor: 150pt", systemImage: "arrow.down.and.line.horizontal.and.arrow.up")
                        .foregroundStyle(.white)
                }
                .accessibilityScrollFloor(150)
                Toggle("Survives scroll engagement", isOn: $isToggleOn)
                Spacer(minLength: 24)
                Label("Pinned by Spacer", systemImage: "arrow.down.to.line")
            }
            .padding()
            .accessibilityScrollView()
            .dynamicTypeSize(dynamicTypeSize)
        }
        .navigationTitle("Compressible Floor")
    }
}

#Preview("Compressible floor") {
    NavigationStack {
        AccessibilityScrollFloorDemo()
    }
}

#Preview("Compressible floor, AX3") {
    NavigationStack {
        AccessibilityScrollFloorDemo(dynamicTypeSize: .accessibility3)
    }
}

#Preview("Compressible floor, AX5") {
    NavigationStack {
        AccessibilityScrollFloorDemo(dynamicTypeSize: .accessibility5)
    }
}
