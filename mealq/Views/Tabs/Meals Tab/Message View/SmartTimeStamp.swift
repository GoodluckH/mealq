//
//  SmartTimeStamp.swift
//  mealq
//
//  Created by Xipu Li on 1/6/22.
//


import Combine

import Introspect
import SwiftUI

struct SmartTimeStamp: View {
    
    @ObservedObject var keyboard = KeyboardResponder()
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollView: UIScrollView? = nil
    
    var body: some View {
        VStack{
            ScrollView {
                // ...
            }.introspectScrollView {scrollView = $0}
        }
        .onReceive(keyboard.$currentHeight) { height in
            // I use a conditional unwrap because in my app, the Scrollview above
            // is conditional depending on whether there are messeges fetched
            // from the server, which means the scrollView will be nil initially
            if let _ = scrollView {
                
                // Again, I found that the ScrollView content will reset their offsets
                // if I start typing in my TextField. So, I only want to update offsets
                // when there's no user inputs
                   if height > 0 {
                       self.scrollView!.setContentOffset(CGPoint(x: 0, y: self.scrollView!.contentOffset.y + height), animated: true)
                   } else {
                       // For my app, I don't need the following but maybe helfpful for your situation
                       //self.scrollView!.contentOffset.y = max(self.scrollView!.contentOffset.y - keyboardHeight, 0)
                   }
                   keyboardHeight = height
               }
            
        }
    }
}

//struct SmartTimeStamp_Previews: PreviewProvider {
//    static var previews: some View {
//        SmartTimeStamp()
//    }
//}
