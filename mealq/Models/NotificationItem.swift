//
//  NotificationItem.swift
//  mealq
//
//  Created by Xipu Li on 1/20/22.
//

import Foundation
import Combine

struct NotificationItem: Identifiable, Hashable {
    
    var id: UUID
    var payload: Any
    var timeStamp: Date
    
    static func == (lhs: NotificationItem, rhs: NotificationItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
