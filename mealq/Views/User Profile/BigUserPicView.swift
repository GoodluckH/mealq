//
//  BigUserPicView.swift
//  mealq
//
//  Created by Xipu Li on 11/23/21.
//

import SwiftUI
import Lottie

struct BigUserPicView: View {
    var picURL: URL?
    // @StateObject var motionData = MotionObserver()
    
    // TODO: Make the image loading more efficient
    
    var body: some View {
        ZStack {
            GeometryReader {geo in
                // background
                GeometryReader { geo in
                    let size = geo.size
                    
                    AsyncImage(url: picURL ?? nil, content: { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .cornerRadius(0)
                    }) {
                        Image("AppLogo").resizable().aspectRatio(contentMode: .fill).frame(width: size.width, height: size.height)
                    }

                    Color.black.opacity(0.2)
                    
                }// GeometryReader
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial)
                
                // foreground
                
                GeometryReader {geo in
                    let size = geo.size
                    AsyncImage(url: picURL ?? nil, content: { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .cornerRadius(picCornerRadius)
                    }) {
                   LottieView(fileName: "bearLoader").frame(width: size.width, height: size.height)
                            .cornerRadius(picCornerRadius)
                                         
                    }
                }
                .frame(width: geo.size.width / picWidthFactor, height: geo.size.height/picHeightFactor)
                .position(x: geo.size.width/2, y: geo.size.height/2)
               // .offset(motionData.movingOffset)
                
            }
           
            
            
        }//.onAppear{motionData.fetchMotionData(duration: picHorizontalPadding)}
        .zIndex(0)
        .environment(\.colorScheme, .dark)
        
        

    }
    
    private let picHeightFactor: CGFloat = 1.5
    private let picWidthFactor: CGFloat = 1.2
    private let picCornerRadius: CGFloat = 25
    private let picHorizontalPadding: CGFloat = 30
    private let picOffsetDurationHairCut: CGFloat = 0.8
    
    
}

struct BigUserPicView_Previews: PreviewProvider {
    static var previews: some View {
        BigUserPicView()
    }
}
