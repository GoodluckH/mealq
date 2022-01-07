//
//  BigUserPicLoaderView.swift
//  mealq
//
//  Created by Xipu Li on 12/4/21.
//

import Lottie
import SwiftUI
import UIKit

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    /// The file name for the JSON file.
    var fileName: String
    var loopMode: LottieLoopMode?
    var speed: CGFloat?
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view =  UIView(frame: .zero)
        
        // add animation
        let animationView = AnimationView()
        animationView.animation = Animation.named(fileName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode ?? .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.animationSpeed = speed ?? 1.0
        animationView.play()
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
     }
    
    
}
