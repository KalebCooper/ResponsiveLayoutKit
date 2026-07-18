//
//  ResponsiveViewDemo.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI

struct DemoCounterCard: View {

    let title: String

    @State private var counter = 0

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
            Stepper("Counter: \(counter)", value: $counter)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.quaternary))
    }
}

/// `ResponsiveView` swaps between genuinely different hierarchies. Crossing a
/// threshold rebuilds the subtree, so the counters reset — intended semantics
/// when phone and tablet structures differ.
struct ResponsiveViewDemo: View {

    var body: some View {
        VStack(spacing: 16) {
            ResponsiveView {
                DemoCounterCard(title: "Phone hierarchy")
            } tablet: {
                HStack(spacing: 16) {
                    DemoCounterCard(title: "Tablet pane 1")
                    DemoCounterCard(title: "Tablet pane 2")
                }
            }
            Text("Phone and tablet are distinct subtrees here: crossing a threshold swaps hierarchies and resets the counters. Keep state that must survive above the ResponsiveView or in an observable model.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("ResponsiveView")
    }
}
