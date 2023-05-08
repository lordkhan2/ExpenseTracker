//
//  LocalFileManager.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 8/5/2023.
//

import Foundation
import UIKit

class LocalFileManager{
    
    static let fileManagerInstance = LocalFileManager()
    
    func saveImage(image:UIImage, identifier: String){
        //derive the path and data to be saved to local directory
        guard let data = image.jpegData(compressionQuality: 1.0),
        let path = getPathForTheImage(identifier: identifier) else {
            print("Errors in saving image data.")
            return
        }
        //save data to the local directory
        do {
            try data.write(to: path)
            print("image has been saved")
        } catch let error{
            print("Error in saving the image.\(error)")
        }
        
    }
    
    func getImage(identifier:String) -> UIImage? {
        //get the image from the local directory and return nil if the file does not exist
        guard let path = getPathForTheImage(identifier: identifier)?.path, FileManager.default.fileExists(atPath: path) else {
            print("Error getting path.")
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    func getPathForTheImage(identifier:String) -> URL? {
        //derive the path for storing images based on identifiers
        guard let path = FileManager
            .default
            .urls(for:.documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("\(identifier).jpg") else{
            print("Errors in getting path")
            return nil
        }
        return path
    }
}
