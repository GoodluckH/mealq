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
    var invitor: MealqUser
    var sender: MealqUser
    var showAvatar: Bool
    @State private var showTimeStamp = false
    @State private var isLinkActive = false
    init (users: [MealqUser], message: Message, currentUser: MealqUser, invitor: MealqUser, showAvatar: Bool) {
        self.users = users
        self.message = message
        self.currentUser = currentUser
        self.invitor = invitor
        let senderID = message.senderID
        if let idx = users.firstIndex(where: {$0.id == senderID}) {
            self.sender = users[idx]
        } else {self.sender = invitor}
        self.showAvatar = showAvatar 
        
    }

    
    var body: some View {
        HStack (alignment: showAvatar ? .bottom : .center,spacing: 0) {
            if sender != currentUser && showAvatar {
                
             NavigationLink(destination: UserProfileView(user: sender)) {
                
                //Button(action: {isLinkActive = true}){
                    ProfilePicView(picURL: sender.normalPicURL)
                         .padding(.leading).padding(.bottom, 5)
                         .frame(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 10)
                
                //}
                  
             }.isDetailLink(false)
                
                
                



//                NavigationLink (""){
//                    if let activeSender = activeSender {
//                        UserProfileView(user: bindingForSender(sender: activeSender).wrappedValue)
//                    } else {
//                        EmptyView()
//                    }
//                }
            
               
            } else  {
                HStack{}.padding(.vertical)
                    .padding(.leading)
                    .frame(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 12)
            }
            
            if sender == currentUser {Spacer(minLength: UIScreen.main.bounds.width / 6)}
            
            VStack(alignment: sender == currentUser ? .trailing : .leading, spacing: 5) {
                Text(message.content)
                    .customFont(name: "Quicksand-Regular", style: .callout)
                    .foregroundColor(sender == currentUser ? .white : .black)
                    .padding(8)
                    .background(sender == currentUser ? .blue : Color("SearchBarBackgroundColor"))
                    .clipShape(ChatBubble(myMsg: sender == currentUser))
                    .onTapGesture {
                        if !showAvatar {
                            withAnimation(.easeOut(duration: 0.2)){showTimeStamp.toggle()}
                        }
                    }
                
                if showAvatar || showTimeStamp {
                    Text(message.timeStamp, style: .time)
                    .customFont(name: "Quicksand-Regular", style: .caption2)
                    .foregroundColor(.gray)
                    .transition(.move(edge: .top))
                }
                    
            }
            if sender != currentUser {Spacer(minLength: UIScreen.main.bounds.width / 6)}
            else {
                VStack{}.padding(.trailing, UIScreen.main.bounds.width / 24).padding(.vertical)
            }
        }
    }
}







//
//struct ChatRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatRow()
//    }
//}
