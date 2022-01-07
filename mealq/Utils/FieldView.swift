//
//  FieldView.swift
//  mealq
//
//  Created by Xipu Li on 1/5/22.
//

import SwiftUI
import UIKit

struct FieldView : UIViewRepresentable {
    @Binding var text : String
    @Binding var heightToTransmit: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let textView = UITextView(frame: .zero, textContainer: nil)
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor(Color.primary) // visual debugging
        textView.isScrollEnabled = false   // causes expanding height
        context.coordinator.textView = textView
        textView.text = text
        view.addSubview(textView)

        // Auto Layout
        textView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.heightBinding = $heightToTransmit
        context.coordinator.textBinding = $text
        DispatchQueue.main.async {
            context.coordinator.runSizing()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var textBinding : Binding<String>?
        var heightBinding : Binding<CGFloat>?
        var textView : UITextView?
        
        func runSizing() {
            guard let textView = textView else { return }
            textView.sizeToFit()
            self.textBinding?.wrappedValue = textView.text
            self.heightBinding?.wrappedValue = textView.frame.size.height
        }
        
        func textViewDidChange(_ textView: UITextView) {
            runSizing()
        }
    }
}
