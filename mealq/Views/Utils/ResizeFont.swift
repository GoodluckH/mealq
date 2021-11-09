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



@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
struct CustomFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    var name: String
    var style: UIFont.TextStyle
    var weight: Font.Weight = .semibold

    func body(content: Content) -> some View {
        return content.font(Font.custom(
            name,
            size: UIFont.preferredFont(forTextStyle: style).pointSize)
            .weight(weight))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont(
        name: String,
        style: UIFont.TextStyle,
        weight: Font.Weight = .semibold) -> some View {
        return self.modifier(CustomFont(name: name, style: style, weight: weight))
    }
}
