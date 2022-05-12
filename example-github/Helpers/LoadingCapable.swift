//
//  LoadingCapable.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation

protocol LoadingCapable: AnyObject {

    var isLoading: Bool { get set }
}

extension LoadingCapable where Self: ObservableObject {

    func setLoadingOnMain(to value: Bool) {
        DispatchQueue.main.async { [self] in
            self.isLoading = value
        }
    }
}
