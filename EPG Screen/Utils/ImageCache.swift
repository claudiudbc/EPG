//
//  ImageCache.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 29/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private var observer: NSObjectProtocol!
    
    static let shared = ImageCache()
    
    private init() {
        observer = NotificationCenter.default.addObserver(
            forName: .UIApplicationDidReceiveMemoryWarning,
            object: nil, queue: nil) { [weak self] notification in
                self?.cache.removeAllObjects()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
