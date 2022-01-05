//
//  ChatRow.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import SwiftUI

struct ChatRow: View {

    var users: [MealqUser]
    var message: Message
    var currentUser: MealqUser
    var sender: MealqUser
    init (users: [MealqUser], message: Message, currentUser: MealqUser) {
        self.users = users
        self.message = message
        self.currentUser = currentUser
        
        let senderID = message.senderID
        self.sender = users[users.firstIndex(where: {$0.id == senderID})!]
    }
    
    
    var body: some View {
        HStack (alignment: .bottom, spacing: 0) {
            if sender != currentUser {
                NavigationLink (destination: UserProfileView(user: sender)){
                   ProfilePicView(picURL: sender.normalPicURL)
                    .padding(.vertical)
                    .padding(.leading)
                    .frame(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6)}
            }
            
            if sender == currentUser {Spacer(minLength: UIScreen.main.bounds.width / 6)}
            
            VStack(alignment: sender == currentUser ? .trailing : .leading, spacing: 5) {
                Text(message.content)
                    .customFont(name: "Quicksand-Regular", style: .callout)
                    .foregroundColor(sender == currentUser ? .white : .black)
                    .padding(10)
                    .background(sender == currentUser ? .blue : Color("SearchBarBackgroundColor"))
                    .clipShape(ChatBubble(myMsg: sender == currentUser))
                Text(message.timeStamp, style: .time)
                    .customFont(name: "Quicksand-Regular", style: .caption2)
                    .foregroundColor(.gray)
                    //.padding(sender == currentUser ? .leading : .trailing, 10)
            }
            if sender != currentUser {Spacer(minLength: UIScreen.main.bounds.width / 6)}
            else {
                VStack{}.padding(.leading, UIScreen.main.bounds.width / 24).padding(.vertical)
            }
        }.id(message.id)
    }
}







//
//struct ChatRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatRow()
//    }
//}
