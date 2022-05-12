//
//  TagTextStyle.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import SwiftUI

public struct TagTextStyle: ViewModifier {

    public init () {}

    public func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.tagBackground)
            .foregroundColor(.tagText)
            .cornerRadius(4)
    }
}

public extension View {
    func tagTextStyle() -> some View {
        modifier(TagTextStyle())
    }
}
