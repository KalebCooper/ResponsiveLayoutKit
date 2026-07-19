//
//  LayoutContext.swift
//  ResponsiveLayoutKit
//

import Foundation

/// The source of truth a responsive API resolves its layout against.
///
/// - ``container`` answers "how much room does *this view* have."
/// - ``scene`` answers "what environment is my *window* in."
public enum LayoutContext: Equatable, Sendable {

  /// Resolve against the space this view actually occupies — a sheet, split
  /// column, popover, or inspector. Matches SwiftUI's native size-class
  /// semantics (for example, a sheet on iPad reports a compact width). This
  /// is the default and requires no setup.
  case container

  /// Resolve against the window scene this view belongs to, regardless of
  /// the local container. A view inside a compact-width sheet on iPad still
  /// sees the scene's regular width. Use for structural decisions such as
  /// sidebar-versus-tab-bar or column counts.
  case scene
}
