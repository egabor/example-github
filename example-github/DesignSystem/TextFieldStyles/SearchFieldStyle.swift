//
//  SearchFieldStyle.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import SwiftUI

public struct SearchFieldStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Color.searchFieldBackground)
            .cornerRadius(12)
            .accentColor(.searchFieldCaret)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.searchFieldText)
            .submitLabel(.search)
    }
}

public extension View {
    func searchFieldStyle() -> some View {
        modifier(SearchFieldStyle())
    }
}
