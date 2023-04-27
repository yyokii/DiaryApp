//
//  UIImage+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/27.
//

import UIKit

extension UIImage {

    /// Re-orientate the image to `.up`.
    public func reorientToUp() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        } else {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

            self.draw(in: CGRect(origin: .zero, size: self.size))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }

    /**
     targetSizeに合わせてリサイズを行う。targetSizeより小さい場合は元のUIImageを返す。
     */
    public func resizeImage(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / self.size.width
        let heightRatio = targetSize.height / self.size.height
        let scaleFactor = min(widthRatio, heightRatio)

        // Skip resizing if the image is already smaller than the target size
        if scaleFactor >= 1.0 {
            return self
        }

        let newSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
