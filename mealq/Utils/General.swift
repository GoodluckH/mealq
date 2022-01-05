//
//  General.swift
//  mealq
//
//  Created by Xipu Li on 12/24/21.
//

import Foundation

func dateToString(from date: Date, to now: Date) -> String {
    
    let diffComponents = Calendar.current.dateComponents([.hour, .day, .minute, .second], from: date, to: now)
    let days = diffComponents.day ?? 0
    let hours = diffComponents.hour ?? 0
    let mins = diffComponents.minute ?? 0
    let seconds = diffComponents.second ?? 0
    
    
    switch days {
    case 0:
        switch hours {
        case 0:
            switch mins {
            case 0:
                switch seconds {
                    case 0...59: return "\(seconds)s"
                    default: return "now"
                }
            default: return "\(mins)m"
            }
        default: return "\(hours)h"
        }
    case 1...7: return "\(days)d"
    default: return "\(days%7)w"
    }

    
}
