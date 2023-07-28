//
//  ImageSaver.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/28.
//

import UIKit

final class ImageSaver: NSObject {
    private var completion: (()-> Void)?

    func writeToPhotoAlbum(image: UIImage, completion: (()-> Void)? = nil) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            print("🚨: \(error.localizedDescription)")
            return
        }

        completion?()
    }
}
