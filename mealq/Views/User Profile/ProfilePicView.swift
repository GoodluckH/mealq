//
//  ProfilePicView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import ActivityIndicatorView
import FacebookCore


/// A view for current user's profile picture.
struct ProfilePicView: View {
    
    var picURL: URL?
   
    var body: some View {
        GeometryReader{ geometry in
            AsyncImage(url: picURL ?? URL(string: "https://INVALIDADDRESS")) { phase in
                if let image = phase.image {
                image.resizable()
                    .aspectRatio(1, contentMode: .fit)
            } else if phase.error != nil {
                Text("🐮").font(resizeFont(in: geometry.size, scale: ProfilePicStyles.errorTextFontScaleFactor))
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
            } else {
                ActivityIndicatorView(isVisible: .constant(true), type: .gradient(makeColors(from: ProfilePicStyles.gradient)))
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: makeColors(from: ProfilePicStyles.gradient)), startPoint: .bottomTrailing, endPoint: .topLeading))
        .clipShape(Circle())
            
        }
        
        
    }
}
































struct ProfilePicView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicView()
    }
}
