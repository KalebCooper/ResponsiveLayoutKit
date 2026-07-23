//
//  ResponsiveLayoutKitTests.swift
//  ResponsiveLayoutKit
//

import SwiftUI
import Testing
import UIKit

@testable import ResponsiveLayoutKit

@Suite("AccessibilityScrollMode threshold decision")
struct AccessibilityScrollModeTests {

  @Test("Dynamic Type above threshold requires scrolling regardless of window height")
  func dynamicTypeAboveThreshold() {
    #expect(
      AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: .accessibility3,
        dynamicTypeSizeThreshold: .accessibility1,
        windowHeight: 10_000,
        windowHeightThreshold: 650
      )
    )
  }

  @Test("Dynamic Type at threshold does not require scrolling")
  func dynamicTypeAtThreshold() {
    #expect(
      !AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: .accessibility1,
        dynamicTypeSizeThreshold: .accessibility1,
        windowHeight: 1_000,
        windowHeightThreshold: 650
      )
    )
  }

  @Test("Short window requires scrolling")
  func shortWindow() {
    #expect(
      AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: .medium,
        dynamicTypeSizeThreshold: .accessibility1,
        windowHeight: 600,
        windowHeightThreshold: 650
      )
    )
  }

  @Test("Tall window with small Dynamic Type does not require scrolling")
  func tallWindow() {
    #expect(
      !AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: .medium,
        dynamicTypeSizeThreshold: .accessibility1,
        windowHeight: 1_000,
        windowHeightThreshold: 650
      )
    )
  }

  @Test("Undiscovered scene height contributes no scrolling vote")
  func undiscoveredSceneHeight() {
    #expect(
      !AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: .medium,
        dynamicTypeSizeThreshold: .accessibility1,
        windowHeight: nil,
        windowHeightThreshold: 650
      )
    )
    #expect(
      !AccessibilityScrollMode.thresholdRequiresScrolling(
        dynamicTypeSize: .medium,
        dynamicTypeSizeThreshold: .accessibility1,
        windowHeight: 0,
        windowHeightThreshold: 650
      )
    )
  }
}

@Suite("AccessibilityScrollHeightThreshold")
struct AccessibilityScrollHeightThresholdTests {

  @Test("Threshold values")
  func values() {
    #expect(AccessibilityScrollHeightThreshold.custom(123).value == 123)
    #expect(AccessibilityScrollHeightThreshold.large.value == 750)
    #expect(AccessibilityScrollHeightThreshold.regular.value == 650)
  }
}

@Suite("ResponsiveLayout")
struct ResponsiveLayoutTests {

  @Test(
    "Size class mapping",
    arguments: [
      (UserInterfaceSizeClass?.none, ResponsiveLayout.phone),
      (UserInterfaceSizeClass.compact, ResponsiveLayout.phone),
      (UserInterfaceSizeClass.regular, ResponsiveLayout.tablet),
    ])
  func sizeClassMapping(sizeClass: UserInterfaceSizeClass?, expected: ResponsiveLayout) {
    #expect(ResponsiveLayout(horizontalSizeClass: sizeClass) == expected)
  }

  @Test("Tablet pane ratio constants")
  func tabletLayoutRatios() {
    #expect(ResponsiveLayout.baseTabletLayoutRatio == 0.66)
    #expect(ResponsiveLayout.compactTabletLayoutRatio == 0.33)
  }

  @Test("Per-layout value picking")
  func valuePicking() {
    #expect(ResponsiveLayout.phone.value(phone: 8, tablet: 24) == 8)
    #expect(ResponsiveLayout.tablet.value(phone: 8, tablet: 24) == 24)
  }
}

@Suite("Responsive layout precedence")
struct ResponsiveLayoutPrecedenceTests {

  @Test("Container size class is the fallback when neither override nor scene is present")
  func containerFallback() {
    #expect(
      resolvedResponsiveLayout(override: nil, sceneLayout: nil, horizontalSizeClass: .regular)
        == .tablet
    )
    #expect(
      resolvedResponsiveLayout(override: nil, sceneLayout: nil, horizontalSizeClass: .compact)
        == .phone
    )
    #expect(
      resolvedResponsiveLayout(override: nil, sceneLayout: nil, horizontalSizeClass: nil) == .phone
    )
  }

  @Test("Override wins over the container size class")
  func overrideWinsOverContainer() {
    #expect(
      resolvedResponsiveLayout(override: .tablet, sceneLayout: nil, horizontalSizeClass: .compact)
        == .tablet
    )
  }

  @Test("Override wins over scene truth")
  func overrideWinsOverScene() {
    #expect(
      resolvedResponsiveLayout(
        override: .phone, sceneLayout: .tablet, horizontalSizeClass: .regular) == .phone
    )
  }

  @Test("Scene truth wins over the container size class when there is no override")
  func sceneWinsOverContainer() {
    #expect(
      resolvedResponsiveLayout(override: nil, sceneLayout: .tablet, horizontalSizeClass: .compact)
        == .tablet
    )
  }
}

@Suite("LayoutContext resolution")
struct LayoutContextTests {

  // `.container` resolves with no scene truth (the reader passes nil), so a
  // regular scene never upgrades a compact container.
  @Test("Container context ignores scene truth")
  func containerContextIgnoresScene() {
    #expect(
      resolvedResponsiveLayout(override: nil, sceneLayout: nil, horizontalSizeClass: .compact)
        == .phone
    )
  }

  @Test("Container and scene are distinct cases")
  func distinctCases() {
    #expect(LayoutContext.container != LayoutContext.scene)
    #expect(LayoutContext.container == .container)
    #expect(LayoutContext.scene == .scene)
  }

  // `.scene` resolves against the scene's layout, so a regular scene upgrades
  // a compact container to tablet.
  @Test("Scene context resolves against scene truth")
  func sceneContextUsesSceneTruth() {
    #expect(
      resolvedResponsiveLayout(override: nil, sceneLayout: .tablet, horizontalSizeClass: .compact)
        == .tablet
    )
  }
}

@Suite("EnvironmentValues resolved layout")
struct EnvironmentValuesResolvedLayoutTests {

  @Test("Canonical key applies override, then scene truth, then container")
  func canonicalPrecedence() {
    var environment = EnvironmentValues()
    environment.horizontalSizeClass = .compact
    #expect(environment.responsiveLayout == .phone)

    environment.sceneResponsiveLayout = .tablet
    #expect(environment.responsiveLayout == .tablet)

    environment.responsiveLayoutOverride = .phone
    #expect(environment.responsiveLayout == .phone)
  }

  @Test("Container key applies an override")
  func containerAppliesOverride() {
    var environment = EnvironmentValues()
    environment.horizontalSizeClass = .compact
    environment.responsiveLayoutOverride = .tablet
    #expect(environment.containerResponsiveLayout == .tablet)
  }

  @Test("Container key ignores scene truth")
  func containerIgnoresScene() {
    var environment = EnvironmentValues()
    environment.horizontalSizeClass = .compact
    environment.sceneResponsiveLayout = .tablet
    #expect(environment.containerResponsiveLayout == .phone)
    #expect(environment.responsiveLayout == .tablet)
  }

  @Test("Phone fallback when nothing is set")
  func phoneFallback() {
    let environment = EnvironmentValues()
    #expect(environment.containerResponsiveLayout == .phone)
    #expect(environment.responsiveLayout == .phone)
  }
}

@Suite("Responsive content width")
struct ResponsiveContentWidthTests {

  @Test("Negative fraction clamps the cap to zero")
  func negativeFractionClamped() {
    #expect(
      resolvedContentMaxWidth(layout: .tablet, sceneWidth: 1000, tabletFraction: -0.5) == 0
    )
  }

  @Test("Phone layout is uncapped")
  func phoneUncapped() {
    #expect(
      resolvedContentMaxWidth(layout: .phone, sceneWidth: 1210, tabletFraction: 0.66)
        == .infinity
    )
  }

  @Test("Tablet layout caps to the scene-width fraction")
  func tabletCapped() {
    #expect(
      resolvedContentMaxWidth(layout: .tablet, sceneWidth: 1000, tabletFraction: 0.66) == 660
    )
    #expect(
      resolvedContentMaxWidth(layout: .tablet, sceneWidth: 1000, tabletFraction: 0.5) == 500
    )
  }

  @Test("Tablet layout with no discovered scene width is uncapped")
  func undiscoveredSceneUncapped() {
    #expect(
      resolvedContentMaxWidth(layout: .tablet, sceneWidth: nil, tabletFraction: 0.66)
        == .infinity
    )
    #expect(
      resolvedContentMaxWidth(layout: .tablet, sceneWidth: 0, tabletFraction: 0.66) == .infinity
    )
  }
}

@Suite("SceneLayoutEnvironment mock values")
@MainActor
struct SceneLayoutMockTests {

  @Test("Aspect ratio reflects size, not orientation")
  func aspectRatio() {
    let landscape = SceneLayoutEnvironment(
      mockValues: SceneLayoutMockValues(
        size: CGSize(width: 856, height: 600),
        horizontalSizeClass: .regular,
        interfaceOrientation: .portrait
      )
    )
    #expect(landscape.isLandscapeAspectRatio)

    let portrait = SceneLayoutEnvironment(
      mockValues: SceneLayoutMockValues(
        size: CGSize(width: 600, height: 856),
        horizontalSizeClass: .regular,
        interfaceOrientation: .landscapeLeft
      )
    )
    #expect(!portrait.isLandscapeAspectRatio)
  }

  @Test("Applied values replace every published value")
  func applyReplacesValues() {
    let environment = SceneLayoutEnvironment(
      mockValues: SceneLayoutMockValues(
        size: CGSize(width: 402, height: 874),
        horizontalSizeClass: .compact
      )
    )
    environment.apply(
      SceneLayoutMockValues(
        size: CGSize(width: 1210, height: 856),
        horizontalSizeClass: .regular,
        verticalSizeClass: .compact,
        interfaceOrientation: .landscapeRight,
        safeAreaInsets: EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0)
      )
    )
    #expect(environment.horizontalSizeClass == .regular)
    #expect(environment.interfaceOrientation == .landscapeRight)
    #expect(environment.responsiveLayout == .tablet)
    #expect(environment.safeAreaInsets.top == 24)
    #expect(environment.size == CGSize(width: 1210, height: 856))
    #expect(environment.verticalSizeClass == .compact)
  }

  @Test("Mock values default to a portrait regular-height window")
  func defaults() {
    let values = SceneLayoutMockValues(
      size: CGSize(width: 402, height: 874),
      horizontalSizeClass: .compact
    )
    #expect(values.interfaceOrientation == .portrait)
    #expect(values.safeAreaInsets == EdgeInsets())
    #expect(values.verticalSizeClass == .regular)
  }
}

@Suite("SceneLayoutRegistry")
struct SceneLayoutRegistryTests {

  // Instance reuse keys on a live UIWindowScene, which cannot be constructed
  // in a unit test. Verified empirically: the SwiftPM logic-test host exposes
  // no connected UIWindowScene (`connectedScenes` is empty), so this is
  // disabled rather than forced into a flaky failure. The body still asserts
  // reuse and runs if a host ever provides a live scene.
  @MainActor
  @Test(
    "Same connected scene resolves to the same environment instance",
    .disabled("requires a live UIWindowScene; the SwiftPM logic-test host has none")
  )
  func reusesInstancePerScene() throws {
    let windowScene = try #require(
      UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
      "no connected UIWindowScene available in the test host"
    )
    let first = SceneLayoutRegistry.shared.environment(for: windowScene)
    let second = SceneLayoutRegistry.shared.environment(for: windowScene)
    #expect(first === second)
  }
}
