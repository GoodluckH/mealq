//
//  DebugView.swift
//  mealq
//
//  Created by Xipu Li on 1/11/22.
//

import SwiftUI
import Combine

struct DebugView: View {
    
    @StateObject var chatsManager = ChatsManager()
      @State private var activeChat : String?
      
      private func activeChatBinding(id: String?) -> Binding<Bool> {
          .init {
              activeChat != nil && activeChat == id
          } set: { newValue in
              activeChat = newValue ? id : nil
          }
      }
      
      private func bindingForChat(id: String) -> Binding<Chat> {
          .init {
              chatsManager.chats.first { $0.id == id }!
          } set: { newValue in
              chatsManager.chats = chatsManager.chats.map { $0.id == id ? newValue : $0 }
          }
      }
      
      var body: some View {
          NavigationView{
              VStack{
                  HStack {
                      Text("Chats")
                  }.padding()
                  VStack{
                      List() {
                          ForEach($chatsManager.chats, id: \.id) { $chat in
                           
                              
//                              Button(action: {
//                                  activeChat = chat.id
//                              }) {
//                                  DemoChatRow(chat: $chat)
//                              }
                          }
                      }.listStyle(.plain)
                  }
//                  .background {
//                      NavigationLink("", isActive: activeChatBinding(id: activeChat)) {
//                          if let activeChat = activeChat {
//                              ChatDetailView(chat: bindingForChat(id: activeChat).wrappedValue)
//                          } else {
//                              EmptyView()
//                          }
//                      }
//                  }
              }.navigationBarTitle("").navigationBarHidden(true)
              
          }.navigationViewStyle(.stack)
              .environmentObject(chatsManager)
      }
}


struct DemoChatRow: View {
    @Binding var chat: Chat
    var body: some View {
        VStack{
            Text(chat.name)
            Text(chat.lastMessageTimeStamp, style: .time)
        }
        .frame(height: 50)
    }
}


struct ChatDetailView: View {
    var chat: Chat
    @EnvironmentObject var chatsManager: ChatsManager
    var body: some View {
        Button(action: {
            chatsManager.updateDate(for: chat.id)
        } ) {
            Text("Click to update the current chat to now")
        }
    }
}



class ChatsManager: ObservableObject {
    @Published var chats = [
        Chat(id: "GroupChat 1", name: "GroupChat 1", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 2", name: "GroupChat 2", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 3", name: "GroupChat 3", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 4", name: "GroupChat 4", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 5", name: "GroupChat 5", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 6", name: "GroupChat 6", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 7", name: "GroupChat 7", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 8", name: "GroupChat 8", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 9", name: "GroupChat 9", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat 10", name: "GroupChat 10", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat2 5", name: "GroupChat2 5", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat2 6", name: "GroupChat2 6", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat2 7", name: "GroupChat2 7", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat2 8", name: "GroupChat2 8", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat2 9", name: "GroupChat2 9", lastMessageTimeStamp: Date()),
        Chat(id: "GroupChat2 10", name: "GroupChat2 10", lastMessageTimeStamp: Date())].sorted(by: {$0.lastMessageTimeStamp.compare($1.lastMessageTimeStamp) == .orderedDescending})
    
    func updateDate(for chatID: String) {
        if let idx = chats.firstIndex(where: {$0.id == chatID}) {
            self.chats[idx] = Chat(id: chatID, name: self.chats[idx].name, lastMessageTimeStamp: Date())
         }
        self.chats.sort(by: {$0.lastMessageTimeStamp.compare($1.lastMessageTimeStamp) == .orderedDescending})
    }
    
        
}




struct Chat: Identifiable, Hashable {
    var id: String
    var name: String
    var lastMessageTimeStamp: Date
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}


struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView().environmentObject(ChatsManager())
    }
}

