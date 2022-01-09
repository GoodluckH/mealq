//
//  ToBottomMessageButton.swift
//  mealq
//
//  Created by Xipu Li on 1/6/22.
//

import SwiftUI

struct ToBottomMessageButton: View {
    var reader: ScrollViewProxy
    var lastMessageID: String
    
    var body: some View {    
       // GeometryReader {geometry in
          //  let (geoX, geoY) = computeScreenSize(with: geometry.size)
            Button(action: {
                Haptics.rigid()
                withAnimation {reader.scrollTo(lastMessageID, anchor: .bottom)}
            }, label: {Image(systemName: "arrow.down")})
                .buttonStyle(mealqButtonStyle(clipShape: Circle(), backgroundColor: .white, foregroundColor: .black))
               // .position(x: geoX, y: geoY)
            
       // }
    }
    
    
    private func computeScreenSize(with geoSize: CGSize) -> (CGFloat, CGFloat) {
        return (geoSize.width, geoSize.height)
    }

    private struct MealButtonConstants {
        static let xOffset: CGFloat = 50
        static let yOffset: CGFloat = 50
        static let inviteViewCornerRadius: CGFloat = 10
    }
}

//struct ToBottomMessageButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ToBottomMessageButton()
//    }
//}
