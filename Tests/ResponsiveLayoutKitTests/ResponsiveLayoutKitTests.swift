//
//  ResponsiveLayoutKitTests.swift
//  ResponsiveLayoutKit
//

import SwiftUI
import Testing
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

    @Test("Size class mapping", arguments: [
        (UserInterfaceSizeClass?.none, ResponsiveLayout.phone),
        (UserInterfaceSizeClass.compact, ResponsiveLayout.phone),
        (UserInterfaceSizeClass.regular, ResponsiveLayout.tablet),
    ])
    func sizeClassMapping(sizeClass: UserInterfaceSizeClass?, expected: ResponsiveLayout) {
        #expect(ResponsiveLayout(horizontalSizeClass: sizeClass) == expected)
    }

    @Test("Per-layout value picking")
    func valuePicking() {
        #expect(ResponsiveLayout.phone.value(phone: 8, tablet: 24) == 8)
        #expect(ResponsiveLayout.tablet.value(phone: 8, tablet: 24) == 24)
    }
}
