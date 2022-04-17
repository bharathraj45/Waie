//
//  ImageView+extension.swift
//  Waie
//
//  Created by Bharath Raj Venkatesh on 17/04/22.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()
let cacher: Cacher = Cacher(destination: .temporary)

extension UIImageView {
    
    func loadImage(from url: URL) {
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        if let cachedObject: CustomImageData = cacher.load(fileName: Constants.fileNameImage),
           let image = UIImage(data: cachedObject.imageData) {
            self.image = image
            return
        }
        
        guard let imageData = try? Data(contentsOf: url) else { return }
        guard let retreivedImage = UIImage(data:imageData) else { return }
        
        imageCache.setObject(retreivedImage, forKey: url.absoluteString as AnyObject)
        
        let customImageData = CustomImageData(imageData: imageData)
        cacher.persist(item: customImageData) { url, error in
            if let error = error {
                print("Object failed to persist: \(error)")
            } else {
                print("Object persisted in \(String(describing: url))")
            }
        }
        DispatchQueue.main.async {
            self.image = retreivedImage
        }
    }
}
