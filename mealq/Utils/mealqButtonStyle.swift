//
//  mealqButtonStyle.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import Foundation


/// A button style configuration with generic type `S`that conforms to `Shape` protocol.
struct mealqButtonStyle<S>: ButtonStyle where S: Shape {
    /// A `Shape` to clip the shape of the butotn.
    var clipShape: S
    var pressedColor: Color?
    var backgroundColor: Color?
    var foregroundColor: Color?
    var shadowColor: Color?
    /// Applies styling to a button.
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .padding()
            .background(configuration.isPressed ? pressedColor ?? Color.gray : backgroundColor ?? Color.black)
            .foregroundColor(foregroundColor ?? .white)
            .clipShape(clipShape)
            .shadow(color: shadowColor ?? Color.gray, radius: configuration.isPressed ? StyleConstants.isPressedShadowRadius : StyleConstants.isNotPressedShadowRadius)
            .scaleEffect(configuration.isPressed ? StyleConstants.isPressedScaleFactor : StyleConstants.isNotPressedScaleFactor)
            .animation(.easeOut(duration: StyleConstants.animationDuration), value: configuration.isPressed)
    }
}


/// A collection of constants to support `mealqButtonStyle`.
fileprivate struct StyleConstants {
    static let animationDuration: Double = 0.1
    static let isPressedScaleFactor: Double = 0.9
    static let isNotPressedScaleFactor: Double = 1
    static let isPressedShadowRadius: Double = 2
    static let isNotPressedShadowRadius: Double = 5
}
