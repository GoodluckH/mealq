//
//  ResizeFont.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import Foundation



func resizeFont(in size: CGSize, scale factor: CGFloat) -> Font {
    Font.system(size: factor * min(size.width, size.height))
}
