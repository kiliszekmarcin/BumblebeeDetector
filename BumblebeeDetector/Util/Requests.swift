//
//  Requests.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 29/03/2021.
//

import Foundation
import UIKit

class Requests {
    static func sendImages(images: [UIImage]) {
        print("in the request :)")
        let url = URL(string: "http://3.249.81.168/api/image")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        let selectedImages = selectionMethod(images: images)
        print("\(selectedImages.count) images")
        
        // initialise the query items
        var queryItems: [URLQueryItem] = []
        for (i, image) in selectedImages.enumerated() {
            queryItems.append(
                URLQueryItem(name: "image\(i)", value: image.jpegData(compressionQuality: 1.0)?.base64EncodedString())
            )
        }
        
        // set the query items
        components.queryItems = queryItems
        
        // get the query
        let query = components.url!.query!
        
        // prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(query.utf8)
        
        // send the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                // json object from the data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle it here
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    /// Selects which images will be sent to the API
    static func selectionMethod(images: [UIImage]) -> [UIImage] {
        // temporarily just send one
        if let firstImage = images.first {
            return [firstImage]
        } else {
            return []
        }
    }
}
