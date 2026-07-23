//
//  DemoApp.swift
//  ResponsiveLayoutKitDemo
//

import ResponsiveLayoutKit
import SwiftUI

@main
struct ResponsiveLayoutKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoRootView()
                .sceneLayoutAnchor()
        }
    }
}

struct DemoRootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Layout resolution") {
                    NavigationLink("Scene layout readout") { SceneLayoutDemo() }
                    NavigationLink("Container vs scene") { ContainerVsSceneDemo() }
                    NavigationLink("Layout override") { OverrideDemo() }
                }
                Section("Responsive content") {
                    NavigationLink("Responsive modifier") { ResponsiveModifierDemo() }
                    NavigationLink("ResponsiveView hierarchies") { ResponsiveViewDemo() }
                    NavigationLink("Readable content width") { ResponsiveContentWidthDemo() }
                }
                Section("Accessibility scrolling") {
                    NavigationLink("Accessibility scroll view") { AccessibilityScrollDemo() }
                    NavigationLink("Compressible floor") { AccessibilityScrollFloorDemo() }
                }
            }
            .navigationTitle("ResponsiveLayoutKit")
        }
    }
}
