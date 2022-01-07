//
//  MessagesManager.swift
//  mealq
//
//  Created by Xipu Li on 1/3/22.
//

import Foundation
import Firebase

class MessagesManager: ObservableObject {
    @Published var messageContent = ""
    @Published var messages = [Message]()
    private var db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func fetchMessages(from mealID: String) {
        if let _ = user {
            self.db.collection("chats").document(mealID).collection("messages").order(by: "timeStamp", descending: false).addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Something went wrong when fetching messages: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                self.messages = documents.map {doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let senderID = data["senderID"] as! String
                    let senderName = data["senderName"] as! String
                    let timeStamp = data["timeStamp"] as! Timestamp
                    let content = data["content"] as! String
                    return Message(id: id, senderID: senderID, senderName: senderName, timeStamp: timeStamp.dateValue(), content: content)
                }
                //self.messages.sort(by: {$0.timeStamp > $1.timeStamp})
                
            }
        }
    }
    
    // TODO: Implement the status indication and failure handling
    @Published var sendingMessage = Status.idle
    private var failedMessages = [Message]()
    
    func sendMessage(from sender: MealqUser, for mealID: String) {
        self.sendingMessage = .loading
        if let _ = user {
            let message = self.db.collection("chats").document(mealID).collection("messages").document()
            let date = Date()
            let payload = [
                "id": message.documentID,
                "senderID": sender.id,
                "senderName": sender.fullname,
                "content": self.messageContent,
                "timeStamp": date
            ] as [String: Any]
            
            
            self.messages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: self.messageContent))
            self.messageContent = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                message.setData(payload) {err in
                    if let err = err {
                        self.sendingMessage = .error
                        self.failedMessages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: self.messageContent, failed: true))
                        print("Something went wrong while sending message: \(err.localizedDescription)")
                    } else  {
                        self.sendingMessage = .done
                        print("Successfully sent message!")
                    }
                }
            }
  
        } else {self.sendingMessage = .idle}
    }
    
    enum Status {
        case idle, loading, done, error
    }
    
    
}
