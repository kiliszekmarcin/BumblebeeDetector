//
//  ImageQuality.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 26/03/2021.
//

import UIKit
import Accelerate

class ImageQuality {
    let laplacian: [Int16] = [-1, -1, -1,
                              -1,  8, -1,
                              -1, -1, -1]
    
    func imageSharpness(image: UIImage) -> UIImage {
//        guard let pixelBuffer = buffer(from: image) else {
//            fatalError("Error acquiring pixelbuffer.")
//        }
        
        let convolved = convolutionFilterToImage(image: image, kernel: laplacian, divisor: 1)
        
        return convolved
    }
    
    func convolutionFilterToImage(image: UIImage, kernel: [Int16], divisor: Int) -> UIImage {
        precondition(kernel.count == 9 || kernel.count == 25 || kernel.count == 49, "Kernel size must be 3x3, 5x5 or 7x7.")
        
        let kernelSide = UInt32(sqrt(Float(kernel.count)))
        
        let imageRef = image.cgImage!
        
        let inProvider = imageRef.dataProvider
        let inBitmapData = inProvider!.data
        
        var inBuffer = vImage_Buffer(data: UnsafeMutablePointer(mutating: CFDataGetBytePtr(inBitmapData)), height: UInt(imageRef.height), width: UInt(imageRef.width), rowBytes: imageRef.bytesPerRow)
            
        let pixelBuffer = malloc(imageRef.bytesPerRow * imageRef.height)
        
        var outBuffer = vImage_Buffer(data: pixelBuffer, height: UInt(imageRef.height), width: UInt(imageRef.width), rowBytes: imageRef.bytesPerRow)
        
        var backgroundColor : Array<UInt8> = [0,0,0,0]
        
        _ = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, kernel, kernelSide, kernelSide, Int32(divisor), &backgroundColor, UInt32(kvImageBackgroundColorFill))
        
        let outImage = try? outBuffer.createCGImage(format: vImage_CGImageFormat(cgImage: image.cgImage!)!)
        
        free(pixelBuffer)
        
        return UIImage(cgImage: outImage!)
    }
    
    
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
        return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
