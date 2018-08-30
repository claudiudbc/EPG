//
//  APIManager.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 23/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

class APIManager: NSObject {

    static let sharedInstance = APIManager()
    var channels: [Channel]?
    
    func getChannels(completion: ((Result<Root>) -> Void)?) {
        let url = "http://localhost:1337/epg"
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let responseModel = try jsonDecoder.decode(Root.self, from: jsonData)
                        self.channels = responseModel.channels
                        completion?(.success(responseModel))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
