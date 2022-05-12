//
//  SearchButtonStyle.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import SwiftUI

public struct SearchButtonStyle: ButtonStyle {
    enum ButtonState {
        case normal
        case highlighted
        case disabled
    }

    @Environment(\.isEnabled) private var isEnabled

    var animation: Animation {
        return .easeInOut(duration: 0.2)
    }

    public let styleConfiguration: StyleConfiguration

    public init(styleConfiguration: StyleConfiguration = .init()) {
        self.styleConfiguration = styleConfiguration
    }

    // MARK: Content Composing Methods

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        view(for: configuration)
            .background(backgroundColor(for: state(isPressed)))
            .foregroundColor(foregroundColor(for: state(isPressed)))
            .scaleEffect(scaleEffectValue(for: state(isPressed)))
            .animation(animation, value: isPressed)
    }

    func view(for configuration: Configuration) -> some View {
        configuration.label
            .font(styleConfiguration.font)
            .padding(6)
    }

    // MARK: - State Helper

    func state(_ isPressed: Bool? = nil) -> ButtonState {
        guard isEnabled else { return .disabled }
        guard let isPressed = isPressed, isPressed else { return .normal }
        return .highlighted
    }

    // MARK: - State Based Properties

    func backgroundColor(for state: ButtonState) -> Color {
        switch state {
        case .disabled: return .searchButtonDisabledBackground
        case .highlighted: return .searchButtonHighlightedBackground
        default: return .searchButtonNormalBackground
        }
    }

    func foregroundColor(for state: ButtonState) -> Color {
        switch state {
        case .disabled: return .searchButtonDisabledTitle
        case .highlighted: return .searchButtonHighlightedTitle
        default: return .searchButtonNormalTitle
        }
    }

    func scaleEffectValue(for state: ButtonState) -> CGFloat {
        switch state {
        case .highlighted: return styleConfiguration.highlightedScaleEffect
        default: return styleConfiguration.normalScaleEffect
        }
    }
}

extension SearchButtonStyle {
    public struct StyleConfiguration {
        public let font: Font

        public let highlightedScaleEffect: CGFloat
        public let normalScaleEffect: CGFloat

        public init(
            font: Font = .system(size: 17, weight: .regular),
            highlightedScaleEffect: CGFloat = 0.98,
            normalScaleEffect: CGFloat = 1
        ) {
            self.font = font
            self.highlightedScaleEffect = highlightedScaleEffect
            self.normalScaleEffect = normalScaleEffect
        }
    }
}
