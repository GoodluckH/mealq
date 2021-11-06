//
//  CreateMealButton.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

/// A button to wake up the `InviteSheet`
struct CreateMealButton: View {
    @State var showInviteModalView: Bool = false
    
    var body: some View {
        GeometryReader {geometry in
            let (geoX, geoY) = computeScreenSize(with: geometry.size)
            Button(action: {showInviteModalView.toggle()}, label: {Image(systemName: "fork.knife")})
                .buttonStyle(mealqButtonStyle(clipShape: Circle()))
                .position(x: geoX - MealButtonConstants.xOffset, y: geoY - MealButtonConstants.yOffset)
                .sheet(isPresented: $showInviteModalView) {
                    InviteSheet()
                }
        
        }.ignoresSafeArea(.keyboard)
    }
    
    
    private func computeScreenSize(with geoSize: CGSize) -> (CGFloat, CGFloat) {
        return (geoSize.width, geoSize.height)
    }

    private struct MealButtonConstants {
        static let xOffset: CGFloat = 50
        static let yOffset: CGFloat = 50
        static let inviteViewCornerRadius: CGFloat = 15
    }
    
}























struct CreateMealButton_Previews: PreviewProvider {
    static var previews: some View {
        CreateMealButton()
    }
}
