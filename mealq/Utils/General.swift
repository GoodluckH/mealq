//
//  General.swift
//  mealq
//
//  Created by Xipu Li on 12/24/21.
//

import Foundation
import UIKit 


func getAllMealParticipantsExSelf(to: [MealqUser], from: MealqUser, me: MealqUser) -> [MealqUser] {
    var toUsers = to
    toUsers.append(from)
    return toUsers.filter{$0 != me}
}

func combineArrays<T> (_ arrays: [T]...) -> [T] {
    return arrays.flatMap { $0 }
}


extension UIImage {
    static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
