//
//  ReloadButtonStyle.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 19..
//

import SwiftUI

public struct ReloadButtonStyle: ButtonStyle {
    enum ButtonState {
        case normal
        case highlighted
        case disabled
    }

    @Environment(\.isEnabled) private var isEnabled

    struct Config {
        static let width: CGFloat = .infinity
        static let height: CGFloat = 50
        static let cornerRadius: CGFloat = 12.0
        static let font: SwiftUI.Font = .system(size: 18, weight: .semibold)

        static let highlightedScaleEffect: CGFloat = 0.98
        static let normalScaleEffect: CGFloat = 1
        static let borderWidth: CGFloat = 1
    }

    var animation: Animation {
        return .easeInOut(duration: 0.2)
    }

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        HStack {
            view(for: configuration)
        }
        .padding(1)
        .frame(maxWidth: Config.width)
        .frame(height: Config.height)
        .background(backgroundColor(for: state(isPressed)))
        .foregroundColor(foregroundColor(for: state(isPressed)))
        .clipShape(RoundedRectangle(cornerRadius: Config.cornerRadius))
        .overlay(border(for: state(isPressed)))
        .scaleEffect(scaleEffectValue(for: state(isPressed)))
        .animation(animation, value: isPressed)
    }

    @ViewBuilder
    func view(for configuration: Configuration) -> some View {
        configuration.label
            .font(Config.font)
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
        case .disabled: return .reloadButtonDisabledBackground
        case .highlighted: return .reloadButtonHighlightedBackground
        default: return .reloadButtonNormalBackground
        }
    }

    func foregroundColor(for state: ButtonState) -> Color {
        switch state {
        case .disabled: return .reloadButtonDisabledTitle
        case .highlighted: return .reloadButtonHighlightedTitle
        default: return .reloadButtonNormalTitle
        }
    }

    func scaleEffectValue(for state: ButtonState) -> CGFloat {
        switch state {
        case .highlighted: return Config.highlightedScaleEffect
        default: return Config.normalScaleEffect
        }
    }

    // MARK: - Border

    func borderColor(for state: ButtonState) -> Color {
        switch state {
        case .disabled: return .reloadButtonDisabledBorder
        case .highlighted: return .reloadButtonHighlightedBorder
        default: return .reloadButtonNormalBorder
        }
    }

    func border(for state: ButtonState) -> some View {
        RoundedRectangle(cornerRadius: Config.cornerRadius)
            .stroke(foregroundColor(for: state), lineWidth: Config.borderWidth)
    }
}
