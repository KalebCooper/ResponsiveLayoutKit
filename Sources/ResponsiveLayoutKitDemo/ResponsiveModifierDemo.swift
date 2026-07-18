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
