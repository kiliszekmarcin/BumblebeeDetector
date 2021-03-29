//
//  Requests.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 29/03/2021.
//  snippets adapted from https://www.donnywals.com/uploading-images-and-forms-to-a-server-using-urlsession/

import UIKit

class Requests {
    static func sendImages(images: [UIImage], completion: @escaping (_ json: Any?, _ error: Error?)->()) {
        let url = URL(string: "http://3.249.81.168/api/image")!
        let selectedImages = selectionMethod(images: images)
        
        // setup the request
        let boundary = "Bounrady-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // setup the request body
        let httpBody = NSMutableData()
        
        for (i, image) in selectedImages.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                httpBody.append(convertFileData(fieldName: "image_field",
                                                fileName: "image\(i).jpeg",
                                                mimeType: "image/jpeg",
                                                fileData: imageData,
                                                using: boundary))
            }
        }
        
        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data
        
        // send the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                // json object from the data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    completion(json, error)
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
    
    static func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
    
    static func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    }
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
