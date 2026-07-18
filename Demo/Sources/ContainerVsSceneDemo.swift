//
//  ContainerVsSceneDemo.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI

/// On iPad, a sheet's container is compact-width while its scene stays
/// regular — so `.container` and `.scene` resolution diverge inside the
/// sheet. The sheet also demonstrates that the root anchor's environment
/// flows into presented content.
struct ContainerVsSceneDemo: View {

    @State private var isSheetPresented = false

    var body: some View {
        List {
            Section {
                Text("On iPad, present the sheet: its container is compact-width, but the scene stays regular — the two rows resolve differently in there.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Present sheet") { isSheetPresented = true }
            }
            resolutionRows
        }
        .navigationTitle("Container vs Scene")
        .sheet(isPresented: $isSheetPresented) {
            NavigationStack {
                List { resolutionRows }
                    .navigationTitle("Inside a sheet")
            }
        }
    }

    private var resolutionRows: some View {
        Section("Resolved layout") {
            ResponsiveView {
                LabeledContent("in: .container", value: "phone")
            } tablet: {
                LabeledContent("in: .container", value: "tablet")
            }
            ResponsiveView(in: .scene) {
                LabeledContent("in: .scene", value: "phone")
            } tablet: {
                LabeledContent("in: .scene", value: "tablet")
            }
        }
    }
}
