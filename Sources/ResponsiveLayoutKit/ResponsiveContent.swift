//
//  ResponsiveContent.swift
//  ResponsiveLayoutKit
//

import SwiftUI

/// Resolves the current ``ResponsiveLayout`` for a ``LayoutContext`` and
/// builds content from it — with stable structural identity.
///
/// The layout is passed as a *value* into a single content closure rather
/// than switched over in a `ViewBuilder`, so crossing a size-class threshold
/// (for example, resizing in Stage Manager) changes parameters, not view
/// structure: `@State`, scroll positions, and running tasks in the content
/// survive. Callers that branch on the layout inside their own closure
/// (like ``ResponsiveView``) opt into identity swaps deliberately.
struct ResponsiveContent<Content: View>: View {

    let context: LayoutContext
    @ViewBuilder let content: (ResponsiveLayout) -> Content

    var body: some View {
        // `context` is constant per call site, so this switch never flips
        // identity at runtime.
        switch context {
        case .container:
            content(resolvedLayout(with: nil))
        case .scene:
            SceneLayoutReader { sceneLayout in
                content(resolvedLayout(with: sceneLayout))
            }
        }
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.responsiveLayoutOverride) private var override

    private func resolvedLayout(with sceneLayout: SceneLayoutEnvironment?) -> ResponsiveLayout {
        override
            ?? sceneLayout?.responsiveLayout
            ?? ResponsiveLayout(horizontalSizeClass: horizontalSizeClass)
    }
}
