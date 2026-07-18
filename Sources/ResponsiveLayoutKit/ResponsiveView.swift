//
//  ResponsiveView.swift
//  ResponsiveLayoutKit
//

import SwiftUI

/// Renders phone or tablet content based on the resolved ``ResponsiveLayout``.
///
/// Resolution order:
/// 1. An explicit override from `View/responsiveLayout(_:)`, if present.
/// 2. The requested ``LayoutContext`` — container-local size class (default)
///    or scene-wide truth. With ``LayoutContext/scene`` and no
///    `View/sceneLayoutAnchor()` upstream, the view discovers its scene
///    automatically and falls back to the container size class for the first
///    layout pass while discovery completes.
///
/// > Important: Phone and tablet content are distinct view subtrees with
/// > distinct structural identity. Crossing a size-class threshold (for
/// > example, resizing in Stage Manager) tears down one subtree and builds
/// > the other, resetting any `@State` inside. That's the right semantics for
/// > genuinely different hierarchies; keep state that must survive the switch
/// > above this view or in an observable model. For layout-dependent
/// > *decoration* of one hierarchy, use `View/responsive(in:content:)`, which
/// > keeps identity stable.
public struct ResponsiveView<PhoneContent: View, TabletContent: View>: View {

    public init(
        in context: LayoutContext = .container,
        @ViewBuilder phone: @escaping () -> PhoneContent,
        @ViewBuilder tablet: @escaping () -> TabletContent
    ) {
        self.context = context
        self.phone = phone
        self.tablet = tablet
    }

    public var body: some View {
        ResponsiveContent(context: context) { layout in
            switch layout {
            case .phone: phone()
            case .tablet: tablet()
            }
        }
    }

    private let context: LayoutContext
    private let phone: () -> PhoneContent
    private let tablet: () -> TabletContent
}
