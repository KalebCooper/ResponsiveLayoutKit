//
//  View+Responsive.swift
//  ResponsiveLayoutKit
//

import SwiftUI

extension View {

  /// Adapts this view to the resolved ``ResponsiveLayout``.
  ///
  /// The closure receives the view and the resolved layout — the same shape
  /// as `scrollTransition` and `visualEffect`:
  ///
  /// ```swift
  /// ContentList()
  ///     .responsive { content, layout in
  ///         content
  ///             .listStyle(layout == .tablet ? .insetGrouped : .plain)
  ///             .padding(layout.value(phone: 8, tablet: 24))
  ///     }
  /// ```
  ///
  /// The layout arrives as a value in a single closure, so crossing a
  /// size-class threshold (for example, resizing in Stage Manager) changes
  /// parameters — not view structure. `@State`, scroll positions, and
  /// running tasks inside this view survive the transition, unless you
  /// branch on the layout yourself inside the closure.
  ///
  /// - Parameters:
  ///   - context: Where layout is resolved — the local container (default)
  ///     or the window scene.
  ///   - content: Transforms this view for the resolved layout.
  public func responsive<Content: View>(
    in context: LayoutContext = .container,
    @ViewBuilder content: @escaping (Self, ResponsiveLayout) -> Content
  ) -> some View {
    ResponsiveContent(context: context) { layout in
      content(self, layout)
    }
  }

  /// Forces every responsive API in this subtree to a specific layout,
  /// overriding both container and scene resolution. Useful for previews,
  /// snapshot tests, or containers that should always behave one way.
  /// Pass `nil` to remove an override set upstream.
  public func responsiveLayout(_ layout: ResponsiveLayout?) -> some View {
    environment(\.responsiveLayoutOverride, layout)
  }
}
