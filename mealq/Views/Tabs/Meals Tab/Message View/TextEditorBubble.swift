//
//  TextEditorBubble.swift
//  mealq
//
//  Created by Xipu Li on 1/5/22.
//

import SwiftUI

struct TextEditorBubble: Shape {
    
    func path(in rect: CGRect) -> Path {
        let path  = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: Constants.textFieldBubbleCornerRadius)
        return Path(path.cgPath)
    }
}
