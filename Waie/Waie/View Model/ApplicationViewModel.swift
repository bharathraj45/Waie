//
//  ApplicationViewModel.swift
//  Waie
//
//  Created by Bharath Raj Venkatesh on 17/04/22.
//

import Foundation

protocol ApplicationProtocol {
    func requestNASAApi()
}

class ApplicationViewModel: ApplicationProtocol {
    
    var model: Model?
    var applicationCellViewModel: ApplicationCellViewModel?
    var reloadTableViewClosure : (() -> Void)?
    var networkUnavailabilityClosure: (() -> Void)?
    let rowCount = 1
    let cacher: Cacher = Cacher(destination: .temporary)
    
    func requestNASAApi() {
        if Reachability.isConnectedToNetwork() {
            NetworkManager.shared.request(url: Constants.apiURL) { [weak self] (result: Result<Model, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.model = response
                    self.applicationCellViewModel = ApplicationCellViewModel(explanation: response.explanation, title: response.title, url: response.url)
                    if let applicationCellModel = self.applicationCellViewModel {
                        FileManager.default.clearTmpDirectory()
                        self.cacher.persist(item: applicationCellModel) { url, error in
                            if let error = error {
                                print("Object failed to persist: \(error)")
                            } else {
                                print("Object persisted in \(String(describing: url))")
                            }
                        }
                    }
                    self.reloadTableViewClosure?()
                case .failure (let error):
                    print(error)
                }
            }
        }
        else {
            if let cachecObject: ApplicationCellViewModel = cacher.load(fileName: Constants.fileName) {
                self.applicationCellViewModel = cachecObject
                self.reloadTableViewClosure?()
            }
            else {
                self.networkUnavailabilityClosure?()
            }
        }
    }
}
