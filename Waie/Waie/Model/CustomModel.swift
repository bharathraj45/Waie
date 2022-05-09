//
//  CustomModel.swift
//  Waie
//
//  Created by Bharath Raj Venkatesh on 17/04/22.
//

import Foundation

struct ApplicationCellViewModel: Cachable, Codable {
    var fileName: String = Constants.fileName
    let explanation: String
    let title: String
    let url: String
}

struct CustomImageData: Cachable, Codable {
    var fileName: String = Constants.fileNameImage
    let imageData: Data
}
