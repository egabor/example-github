//
//  ErrorCapable.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation

protocol ErrorCapable: AnyObject {

    var showError: Bool { get set }
    var errorMessage: String { get set }
}

extension ErrorCapable {

    func showErrorOnMain(message: String) {
        DispatchQueue.main.async { [self] in
            errorMessage = message
            showError = true
        }
    }

    var errorAlertTitle: String {
        String.alertErrorTitle
    }

    var errorAlertOkButtonTitle: String {
        String.alertOkButtonTitle
    }
}
