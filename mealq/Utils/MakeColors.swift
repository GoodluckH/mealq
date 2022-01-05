//
//  MakeColors.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import Foundation

/// Returns an array of `Color` given inputs.
///
/// - parameter hexArray: array of integers in the format of "0xFFFFFF".
/// - returns: an array of `Color`.
func makeColors(from hexArray: [Int]) -> [Color] {
    return hexArray.map{hexVal in converToColor(from: hexVal)}
}


/// Returns a `Color` given a hex value.
///
/// - parameter hexValue: an integer in the format of "0xFFFFFF".
/// - returns: a `Color`.
func converToColor(from hexValue: Int) -> Color {
    let r = CGFloat((hexValue & 0xFF0000) >> 16)/255.0
    let g = CGFloat((hexValue & 0xFF00) >> 8)/255.0
    let b = CGFloat((hexValue & 0xFF))/255.0
    return Color(red: r, green: g, blue: b)
}
