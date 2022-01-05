//
//  ChatBubble.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import SwiftUI

struct ChatBubble: Shape {
    var myMsg: Bool
    
    func path(in rect: CGRect) -> Path {
        let path  = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, myMsg ? .bottomLeft : .bottomRight], cornerRadii: Constants.chatBubbleCornerRadius)
        return Path(path.cgPath)
    }
}
