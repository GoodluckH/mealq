//
//  ReferralView.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct ReferralView: View {
    @Binding var showReferralSheet: Bool
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button(action: {showReferralSheet.toggle()}) {
             Image(systemName: "xmark")
        }
    }
}

struct ReferralView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralView(showReferralSheet: .constant(true))
    }
}
