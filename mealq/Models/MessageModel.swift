//
//  MessageModel.swift
//  mealq
//
//  Created by Xipu Li on 1/3/22.
//

import Foundation


struct Message: Identifiable, Codable, Hashable {
    var id: String
    var senderID: String
    var senderName: String
    var timeStamp: Date
    var content: String
    var failed: Bool?
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
