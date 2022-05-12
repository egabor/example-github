//
//  SearchView.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import SwiftUI

struct SearchView<ViewModel: SearchViewModelProtocol>: View {

    @ObservedObject var viewModel: ViewModel
    @FocusState private var isFocused: Bool

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
    }

    var content: some View {
        VStack {
            searchField
            .padding(.horizontal)
            Divider()
        }
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    var searchField: some View {
        HStack {
            searchInput
            searchButton
        }
    }

    // MARK: - LEVEL 2 Views: Helpers & Other Subcomponents

    var searchInput: some View {
        HStack(spacing: 0) {
            searchImage
            TextField(
                LocalizedStringKey(viewModel.localizedSearchFieldPlaceholder),
                text: $viewModel.searchText
            )
            .focused($isFocused)
            .onSubmit {
                viewModel.search()
            }
            clearButton
        }
        .onTapGesture {
            isFocused = true
        }
        .searchFieldStyle()
        .disabled(viewModel.isSearchFieldDisabled)
    }

    var searchImage: some View {
        Image(systemName: "magnifyingglass")
            .padding(10)
    }

    @ViewBuilder
    var clearButton: some View {
        if viewModel.showsClearButton {
            Button(
                action: viewModel.clearSearch,
                label: clearButtonImage
            )
            .padding(10)
            .transition(.opacity.animation(.easeInOut))
        }
    }

    func clearButtonImage() -> some View {
        Image(systemName: "multiply.circle.fill")
    }

    var searchButton: some View {
        Button(
            LocalizedStringKey(viewModel.localizedSearchButtonTitle),
            action: viewModel.search
        )
        .buttonStyle(SearchButtonStyle())
        .disabled(viewModel.isSearchDisabled)
    }
}

struct SearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        SearchView(viewModel: PreviewSearchViewModel())
    }
}
