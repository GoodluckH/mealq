//
//  NoMatchView.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct NoMatchView: View {
    @State var showReferralSheet = false
    @Binding var searchText: String
    var body: some View {
        VStack {
            Text("wow, such empty").padding()
            Button(action: {showReferralSheet = true}) {
                Text("invite friend")
                    .fontWeight(.black)
            }
            .buttonStyle(mealqButtonStyle(clipShape: Capsule()))
            .fullScreenCover(isPresented: $showReferralSheet, onDismiss: {searchText = ""}) {
                ReferralView(showReferralSheet: $showReferralSheet)
            }
        }
        
    }
}


