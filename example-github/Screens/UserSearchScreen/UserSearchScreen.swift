//
//  UserSearchScreen.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import SwiftUI

struct UserSearchScreen: View {

    @StateObject var viewModel: UserSearchScreenViewModel = .init()

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        ZStack {
            content
                .zIndex(0)
            toast
                .zIndex(1)
        }
        .contentLoading(viewModel.isLoading)
        .alert(
            LocalizedStringKey(viewModel.errorAlertTitle),
            isPresented: $viewModel.showError,
            actions: { Text(LocalizedStringKey(viewModel.errorAlertOkButtonTitle)) },
            message: { Text(viewModel.errorMessage) }
        )

    }

    var content: some View {
        VStack(spacing: 0) {
            SearchView(viewModel: viewModel)
            UserListView(viewModel: viewModel)
        }
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    @ViewBuilder
    var toast: some View {
        if viewModel.showToast {
            VStack {
                Spacer()
                Text(viewModel.toastMessage)
                    .toastTextStyle()
            }
            .padding()
            .transition(.opacity.animation(.easeInOut))
        }
    }
}

struct UserSearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchScreen()
    }
}
