//
//  ResponsiveLayout.swift
//  ResponsiveLayoutKit
//

import SwiftUI

/// The high-level layout family a view should render for.
public enum ResponsiveLayout: Equatable, Sendable {

  /// A compact, single-column layout suited to iPhone-class widths.
  case phone

  /// An expanded layout suited to iPad-class (regular-width) environments.
  case tablet

  /// The fraction of available width a primary tablet pane typically occupies.
  public static let baseTabletLayoutRatio: CGFloat = 0.66

  /// The fraction of available width a secondary tablet pane typically occupies.
  public static let compactTabletLayoutRatio: CGFloat = 0.33

  /// Maps a horizontal size class to a layout family. `nil` and `.compact`
  /// resolve to ``phone``; `.regular` resolves to ``tablet``.
  public init(horizontalSizeClass: UserInterfaceSizeClass?) {
    self = horizontalSizeClass == .regular ? .tablet : .phone
  }

  /// Picks a per-layout value — handy inside `View/responsive(in:content:)`:
  ///
  /// ```swift
  /// .padding(layout.value(phone: 8, tablet: 24))
  /// ```
  public func value<Value>(phone: Value, tablet: Value) -> Value {
    self == .tablet ? tablet : phone
  }
}
