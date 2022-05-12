//
//  ToastTextStyle.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import SwiftUI

public struct ToastTextStyle: ViewModifier {

    public init () {}

    public func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .semibold))
            .multilineTextAlignment(.center)
            .padding(8)
            .background(Color.toastBackground)
            .foregroundColor(.toastText)
            .cornerRadius(12)
    }
}

public extension View {
    func toastTextStyle() -> some View {
        modifier(ToastTextStyle())
    }
}
