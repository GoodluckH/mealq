//
//  InviteSheet.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct InviteSheet: View {
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 30, height: 5)
                .padding(10)

            Text("invite your friend")

            Spacer()
          
        }
        .cornerRadius(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.purple)
    }
    

}































struct InviteSheet_Previews: PreviewProvider {
    static var previews: some View {
        InviteSheet()
    }
}
