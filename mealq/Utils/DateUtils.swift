//
//  DateUtils.swift
//  mealq
//
//  Created by Xipu Li on 1/12/22.
//

import Foundation
import SwiftUI
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


func getTimeStampBetween(lastDate: Date, and newDate: Date, mandatory: Bool) -> String? {
    let today = Date()
//    let diffComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .day], from: lastDate, to: newDate)
    let diffFromToday =  Calendar.autoupdatingCurrent.dateComponents([.day], from: newDate, to: today)
    
    let lastDateHour = Calendar.autoupdatingCurrent.component(.hour, from: lastDate)
    let newDateHour = Calendar.autoupdatingCurrent.component(.hour, from: newDate)
    let lastDateDay = Calendar.autoupdatingCurrent.component(.day, from: lastDate)
    let newDateDay = Calendar.autoupdatingCurrent.component(.day, from: newDate)
    
    
//    let days  = diffComponents.day ?? 0
//    let hour = diffComponents.hour ?? 0
  
    let daysToToday = diffFromToday.day ?? 0
    
    let dateFormatter = DateFormatter()
    
    if Calendar.autoupdatingCurrent.isDateInToday(newDate) {
        if lastDateDay == newDateDay {
            if lastDateHour != newDateHour || mandatory {return "Today"}
        } else {return "Today"}
    } else if Calendar.autoupdatingCurrent.isDateInYesterday(newDate) {
        if lastDateDay == newDateDay {if lastDateHour != newDateHour {return "Yesterday"}}
        else  {return "Yesterday"}
    } else if daysToToday < 7 {
        dateFormatter.dateFormat = "EEEE"
        if lastDateDay == newDateDay {if lastDateHour != newDateHour {return dateFormatter.string(from: newDate)}}
        else {return dateFormatter.string(from: newDate)}
    } else {
        if lastDateDay == newDateDay {if lastDateHour != newDateHour  {return "FULLDATE"}}
        else {return "FULLDATE"}
    }
    return nil
}


func getShortWeekday(from num: Int) -> String {
    switch num {
    case 1: return "mon"
    case 2: return "tue"
    case 3: return "wed"
    case 4: return "thr"
    case 5: return "fri"
    case 6: return "sat"
    case 7: return "sun"
    default: return "🤘"
    }
}

func getWeekdayColor(from num: Int) -> Color {
    switch num {
    case 1: return Color("MyPrimary")
    case 2: return Color.green
    case 3: return Color.blue
    case 4: return Color.orange
    case 5: return Color.yellow
    case 6: return Color.pink
    case 7: return Color.purple
    default: return Color.red
    }
}
