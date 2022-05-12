//
//  UserListView.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import SwiftUI

struct UserListView<ViewModel: UserListViewModelProtocol>: View {

    @ObservedObject var viewModel: ViewModel

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        if viewModel.isEmpty {
            emptyList
        } else {
            list
        }
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.users) { $0 }
                listBottomView
            }
        }
    }

    var emptyList: some View {
        VStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .padding(.bottom)
            Text(LocalizedStringKey(viewModel.localizedEmptyListText))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - LEVEL 2 Views: Helpers & Other Subcomponents

    @ViewBuilder
    var nextPageProgressView: some View {
        HStack(alignment: .center) {
            Spacer()
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: .gray)
                )
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadNextPage()
        }
    }

    var retryNextPageButton: some View {
        Button(
            action: viewModel.retryNextPage,
            label: { Text(LocalizedStringKey(viewModel.localizedRetryButtonTitle)) }
        )
        .padding(.horizontal)
        .buttonStyle(ReloadButtonStyle())
    }

    @ViewBuilder
    var listBottomView: some View {
        if viewModel.nextPageLoading == .loading {
            nextPageProgressView
        } else if viewModel.nextPageLoading == .retry {
            retryNextPageButton
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            UserListView(viewModel: PreviewUserListViewModel.empty)
            UserListView(viewModel: PreviewUserListViewModel.someItems)
            UserListView(viewModel: PreviewUserListViewModel.someItemsWithNextPage)

            UserListView(viewModel: PreviewUserListViewModel.empty)
                .preferredColorScheme(.dark)
            UserListView(viewModel: PreviewUserListViewModel.someItems)
                .preferredColorScheme(.dark)
            UserListView(viewModel: PreviewUserListViewModel.someItemsWithNextPage)
                .preferredColorScheme(.dark)
        }
    }
}
