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
    var cachedImage: Binding<Image?>?
    
    
    
    
    var body: some View {
        
        GeometryReader{ geometry in
            if let image = cachedImage?.wrappedValue {
                image.resizable().aspectRatio(1, contentMode: .fit)
                    .background(Image("AppBackground").resizable().aspectRatio(1, contentMode: .fit)).clipShape(Circle())
            }

            else {
                if let picURL = picURL {
                AsyncImage(url: picURL) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(1, contentMode: .fit)
                            .onAppear{cachedImage?.wrappedValue = image}
                } else if phase.error != nil {
                    Text("").font(resizeFont(in: geometry.size, scale: ProfilePicStyles.errorTextFontScaleFactor))
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                } else {
                    ActivityIndicatorView(isVisible: .constant(true), type: .gradient(makeColors(from: ProfilePicStyles.gradient)))
                }
            }
                .background(Image("AppBackground").resizable().aspectRatio(1, contentMode: .fit))
            .clipShape(Circle())
            } else {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(Circle())
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
                
            }
        }//geomtry reader
        
    }
}
































struct ProfilePicView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicView()
    }
}
