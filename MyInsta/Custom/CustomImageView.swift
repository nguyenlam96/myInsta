//
//  CustomImageView.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit


var imageCache = [String:UIImage]()

class CustomImageView: UIImageView {
    
    var lastUrlUsedToLoadImage: String?
    
    func fetchPostImage(with imageUrl: String) {
        
        self.lastUrlUsedToLoadImage = imageUrl
        self.image = nil
        if let cacheImage = imageCache[imageUrl] {
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: imageUrl) else {
            Logger.LogDebug(type: .error, message: "Invalid Url")
            return
        }
        // do URL task:
        URLSession.shared.dataTask(with: url) { [unowned self](data, response, error) in
            // check error:
            guard error == nil else {
                Logger.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            // check response:
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    Logger.LogDebug(type: .error, message: "Status code: \(httpResponse.statusCode)")
                    return
                }
            } else {
                Logger.LogDebug(type: .warning, message: "httpResponse is nil")
            }
            
            if url.absoluteString != self.lastUrlUsedToLoadImage {
                Logger.LogDebug(type: .warning, message: "Not the current URL we are fetching")
                return
            }
            
            // check data:
            guard let data = data else {
                Logger.LogDebug(type: .error, message: "data is nil")
                return
            }
            guard let image = UIImage(data: data) else {
                Logger.LogDebug(type: .error, message: "fail to create image from data")
                return
            }
            // save image to cache every time it's loaded
            imageCache[ url.absoluteString] = image
            
            // back to main queue when each the image:
            DispatchQueue.main.async {
                self.image = image
            }
            
            }.resume()
        
        
    } // end fetch Post Image
    
}
