//
//  General.swift
//  mealq
//
//  Created by Xipu Li on 12/24/21.
//

import Foundation

/// Generate a string representation of how long has passed since `date` til `now`.
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


func getTimeStampBetween(lastDate: Date, and newDate: Date) -> String? {
    let today = Date()
    let diffComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .day], from: lastDate, to: newDate)
    let diffFromToday =  Calendar.autoupdatingCurrent.dateComponents([.day], from: newDate, to: today)
    
    let days  = diffComponents.day ?? 0
    let hour = diffComponents.hour ?? 0
  
    let daysToToday = diffFromToday.day ?? 0
    
    let dateFormatter = DateFormatter()
    
    if Calendar.autoupdatingCurrent.isDateInToday(lastDate) {
        if hour >= 1 {return "Today"}
    } else if Calendar.autoupdatingCurrent.isDateInYesterday(lastDate) {
        if hour >= 1 {return "Yesterday"}
    } else if daysToToday < 7{
        dateFormatter.dateFormat = "EEEE"
        if hour >= 1 {return dateFormatter.string(from: lastDate)}
    } else if days >= 1 {
        return "FULLDATE"
    }
    
    
    return nil
}

