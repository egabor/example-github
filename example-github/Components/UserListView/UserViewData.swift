//
//  UserViewData.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import SwiftUI

struct UserViewData: Identifiable {
    let id: UUID = .init()
    let login: String
    let type: String
    let avatarUrl: String
}

extension UserViewData: View {

    var imageSize: CGFloat { 50 }
    var verticalPadding: CGFloat { 4 }
    var cellHeight: CGFloat { imageSize + verticalPadding * 2 }

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
            .padding(.horizontal)
            .frame(height: cellHeight)
    }

    var content: some View {
        HStack {
            imageView
                .frame(maxWidth: imageSize, maxHeight: imageSize)
            VStack(alignment: .leading, spacing: 4) {
                loginText
                typeTag
            }
            Spacer()
        }
        .padding(.vertical, verticalPadding)
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    @ViewBuilder
    var imageView: some View {
        AsyncImageView(
            url: URL(string: avatarUrl),
            placeholder: { ProgressView() },
            image: {
                Image(uiImage: $0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: imageSize, maxHeight: imageSize)
                    .background(Color.white)
            }
        )
        .cornerRadius(imageSize/2.0)
    }

    var loginText: some View {
        Text(login)
    }

    var typeTag: some View {
        Text(type)
            .tagTextStyle()
    }
}

extension Array where Element == UserViewData {

    static var previewArray: Self {
        [
            .init(login: "abc", type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/736191?v=4"),
            .init(login: "cde", type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/959793?v=4"),
            .init(login: "fgh", type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/1263582?v=4"),
            .init(login: "ijk", type: "Organization", avatarUrl: "https://avatars.githubusercontent.com/u/455508?v=4"),
            .init(login: "lmn", type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/544478?v=4")
        ]
    }
}
