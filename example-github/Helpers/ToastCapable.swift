//
//  ToastCapable.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation

protocol ToastCapable: AnyObject {

    var showToast: Bool { get set }
    var toastMessage: String { get set }
    var toastTimer: Timer? { get set }
}

extension ToastCapable {

    func showToastOnMain(message: String) {
        DispatchQueue.main.async { [self] in
            toastTimer?.invalidate()
            toastTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { [weak self] timer in
                self?.showToast = false
            })
            toastMessage = message
            showToast = true
        }
    }
}
