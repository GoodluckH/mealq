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
    
    private var lastDoc: QueryDocumentSnapshot? = nil
    private var lastMealID = ""
    
    @Published var fetchingMoreMessages = Status.idle
    @Published var fetchingMessages = Status.idle
    func fetchMessages(from mealID: String) {
        self.lastDoc = nil
        self.lastMealID = ""
        fetchingMoreMessages = .idle
        fetchingMessages = .loading
        let first = db.collection("chats").document(mealID).collection("messages").order(by: "timeStamp", descending: true).limit(to: 20)
        if let _ = user {
            first.addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    self.fetchingMessages = .error
                    print("Something went wrong when fetching messages: \(String(describing: error?.localizedDescription))")
                    return
                }

                guard let lastSnapshot = documents.last else {
                    self.fetchingMessages = .idle
                    return
                }

                
                var tempMessages: [Message] = documents.map {doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let senderID = data["senderID"] as! String
                    let senderName = data["senderName"] as! String
                    let timeStamp = data["timeStamp"] as! Timestamp
                    let content = data["content"] as! String
                    return Message(id: id, senderID: senderID, senderName: senderName, timeStamp: timeStamp.dateValue(), content: content)
                }
                
                tempMessages.reverse()
                
                self.messages = tempMessages
                self.lastDoc = lastSnapshot
                self.lastMealID = mealID
                self.fetchingMessages = .idle
            }
        }
    }
    

    func fetchMoreMessages() {
        if let lastDoc = lastDoc {
            self.fetchingMessages = .loading
            self.fetchingMoreMessages = .loading
            self.db.collection("chats").document(lastMealID).collection("messages").order(by: "timeStamp", descending: true).start(afterDocument: lastDoc).limit(to: 20).getDocuments {snap, err in
                guard let documents = snap?.documents else {
                    print ("error updating new messages: \(err?.localizedDescription ?? "")")
                    self.fetchingMessages = .error
                    self.fetchingMoreMessages = .error
                    return
                }
                guard let lastSnapshot = documents.last else {
                    self.fetchingMessages = .idle
                    self.fetchingMoreMessages = .idle
                    self.lastDoc = nil
                    self.lastMealID = ""
                    return
                }
                    
                var tempMessages: [Message] = documents.map {doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let senderID = data["senderID"] as! String
                    let senderName = data["senderName"] as! String
                    let timeStamp = data["timeStamp"] as! Timestamp
                    let content = data["content"] as! String
                    return Message(id: id, senderID: senderID, senderName: senderName, timeStamp: timeStamp.dateValue(), content: content)
                }
                tempMessages.reverse()
                tempMessages.append(contentsOf: self.messages)
                self.messages = tempMessages
                self.lastDoc = lastSnapshot
                self.fetchingMessages = .idle
                self.fetchingMoreMessages = .done
            }
        }
    }
    
    
    
    
    
    
    
    // TODO: Implement the status indication and failure handling
    @Published var sendingMessage = Status.idle
    private var failedMessages = [Message]()
    
    func sendMessage(from sender: MealqUser, for meal: Meal) {
        self.sendingMessage = .loading
        if let _ = user {
            
            let tempMessageContent = self.messageContent
            self.messageContent = ""
            
            let message = self.db.collection("chats").document(meal.id).collection("messages").document()
            let mealDoc = self.db.collection("chats").document(meal.id)
            let date = Date()
            let payload = [
                "id": message.documentID,
                "senderID": sender.id,
                "senderName": sender.fullname,
                "content": tempMessageContent,
                "timeStamp": date
            ] as [String: Any]
            
            self.messages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: tempMessageContent))
            
            let batch = self.db.batch()
            
            batch.updateData([
                "recentMessage.content": tempMessageContent,
                "recentMessage.sentByName": sender.fullname,
                "recentMessage.timeStamp": date,
                "recentMessage.messageID": message.documentID,
            ], forDocument: mealDoc)
            
            for user in getAllMealParticipantsExSelf(to: Array(meal.to.keys), from: meal.from, me: sender) {
                batch.updateData([
                    "unreadMessages.\(user.id)": FieldValue.increment(Int64(1))
                ], forDocument: mealDoc)
            }
            
            batch.commit() {err in
                if let err = err {
                    print("something went wrong when updating the recent message on meal: \(err.localizedDescription)")
                    self.sendingMessage = .error
                    self.failedMessages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: tempMessageContent, failed: true))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        message.setData(payload) {err in
                            if let err = err {
                                self.sendingMessage = .error
                                self.failedMessages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: tempMessageContent, failed: true))
                                print("Something went wrong while sending message: \(err.localizedDescription)")
                            } else  {
                                self.sendingMessage = .done
                                print("Successfully sent message!")
                            }
                        }
                    }
                }
            }
            
            //batch.setData(payload, forDocument: message)
            
            
//            mealDoc.setData([
//                "recentMessage": ["content": tempMessageContent],
//                "recentMessage": ["sentByName": sender.fullname],
//                "recentMessage": ["timeStamp": date],
//                "recentMessage": ["messageID": message.documentID],
//            ], merge: true) {err in
//                if let err = err {
//                    print("something went wrong when updating the recent message on meal: \(err.localizedDescription)")
//                    self.sendingMessage = .error
//                    self.failedMessages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: tempMessageContent, failed: true))
//                } else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        message.setData(payload) {err in
//                            if let err = err {
//                                self.sendingMessage = .error
//                                self.failedMessages.append(Message(id: message.documentID, senderID:sender.id, senderName: sender.fullname, timeStamp: date, content: tempMessageContent, failed: true))
//                                print("Something went wrong while sending message: \(err.localizedDescription)")
//                            } else  {
//                                for user in getAllMealParticipantsExSelf(to: Array(meal.to.keys), from: meal.from, me: sender) {
//                                    mealDoc.setData([
//                                        "unreadMessages": [user.id: FieldValue.increment(Int64(1))]
//                                    ], merge: true)
//                                }
//
//                                self.sendingMessage = .done
//                                print("Successfully sent message!")
//                            }
//                        }
//                    }
//                }
//            }

  
        } else {self.sendingMessage = .idle}
    }
    
    enum Status {
        case idle, loading, done, error
    }
    
    
}
