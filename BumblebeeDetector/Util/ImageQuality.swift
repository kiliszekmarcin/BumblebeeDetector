//
//  ImageQuality.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 26/03/2021.
//

import UIKit
import Accelerate

class ImageQuality {
    // define laplacian kernels with different data types
    let laplacian: [Int16] = [-1, -1, -1,
                              -1,  8, -1,
                              -1, -1, -1]
    
    let laplacian_float: [Float] = [-1, -1, -1,
                                    -1,  8, -1,
                                    -1, -1, -1]
    
    /// returns the standard derivation of the concoluvions of the images passed as an argument
    func sequenceSharpnessStDev(images: [UIImage]) -> [Double] {
        var stDevs: [Double] = []
        
        for image in images {
            let stDev: Double
            (_, stDev, _) = imageSharpness(image: image)
            
            stDevs.append(stDev)
        }
        
        return stDevs
    }
    
    /// applies a convolution filter to an image and returns the convolved image, standard derivation and mean
    func imageSharpness(image: UIImage) -> (UIImage, Double, Double) {
        let compressedData = image.jpegData(compressionQuality: 1.0)
        let compressedUIImage = UIImage(data: compressedData!)
        
        return convolutionFilterToStDev(image: compressedUIImage!, kernel: laplacian, divisor: 1)
    }
    
    /// applies a convolution filter to an image and returns the convolved image, standard derivation and mean
    private func convolutionFilterToStDev(image: UIImage, kernel: [Int16], divisor: Int) -> (UIImage, Double, Double) {
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
        
        let stDev: Double
        let mean: Double
        
        (stDev, mean) = getStDevAndMean(data: outBuffer.data,
                     rowBytes: Int(outBuffer.rowBytes),
                     width: Int(outBuffer.width),
                     height: Int(outBuffer.height),
                     orientation: UInt32(image.imageOrientation.rawValue))
        
        free(pixelBuffer)
        
        return (UIImage(cgImage: outImage!), stDev, mean)
    }
    
    /// calculate standard deviation and mean of an edge image
    private func getStDevAndMean(data: UnsafeMutableRawPointer,
                      rowBytes: Int,
                      width: Int, height: Int,
                      orientation: UInt32? ) -> (Double, Double) {
        
        var sourceBuffer = vImage_Buffer(data: data,
                                         height: vImagePixelCount(height),
                                         width: vImagePixelCount(width),
                                         rowBytes: rowBytes)
        
        var floatPixels: [Float]
        let count = width * height
        
        if sourceBuffer.rowBytes == width * MemoryLayout<Pixel_8>.stride {
            let start = sourceBuffer.data.assumingMemoryBound(to: Pixel_8.self)
            floatPixels = vDSP.integerToFloatingPoint(
                UnsafeMutableBufferPointer(start: start,
                                           count: count),
                floatingPointType: Float.self)
        } else {
            floatPixels = [Float](unsafeUninitializedCapacity: count) {
                buffer, initializedCount in
                
                var floatBuffer = vImage_Buffer(data: buffer.baseAddress,
                                                height: sourceBuffer.height,
                                                width: sourceBuffer.width,
                                                rowBytes: width * MemoryLayout<Float>.size)
                
                vImageConvert_Planar8toPlanarF(&sourceBuffer,
                                               &floatBuffer,
                                               0, 255,
                                               vImage_Flags(kvImageNoFlags))
                
                initializedCount = count
            }
        }
        
        // Convolve with Laplacian.
        vDSP.convolve(floatPixels,
                      rowCount: height,
                      columnCount: width,
                      with3x3Kernel: laplacian_float,
                      result: &floatPixels)
        
        // Calculate standard deviation.
        var mean = Float.nan
        var stdDev = Float.nan
        
        vDSP_normalize(floatPixels, 1,
                       nil, 1,
                       &mean, &stdDev,
                       vDSP_Length(count))
        
        return (Double(stdDev), Double(mean))
    }
}
