//
//  SingleFriendRequestRow.swift
//  mealq
//
//  Created by Xipu Li on 11/12/21.
//

import SwiftUI
import ActivityIndicatorView

struct SingleNotificationView: View {
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @EnvironmentObject var sessionStore: SessionStore
    var notificationItem: NotificationItem
    
    var displayText: String
    var user: MealqUser
    var now: Date
    var time: Date
    var navDest: AnyView
    
    init (notificationItem: NotificationItem, now: Date) {
        self.notificationItem = notificationItem
        
        if notificationItem.payload is Meal {
            let meal = notificationItem.payload as! Meal
            self.displayText = "\(meal.from.fullname) invited you for \(meal.name)"
            self.user = meal.from
            self.now = now
            self.time = meal.createdAt
            self.navDest =  AnyView(MealDetailView(meal: meal))
        } else {
            let user = notificationItem.payload as! MealqUser
            self.displayText = "\(user.fullname) wants to be your friend"
            self.user = user
            self.now = now
            self.time = notificationItem.timeStamp
            self.navDest = AnyView(UserProfileView(user: user))
        }
        
    }
     
    var body: some View {
    
            NavigationLink(destination: navDest) {
                
                HStack {
                    ProfilePicView(picURL: user.normalPicURL).frame(width: UIScreen.main.bounds.width / 8,
                                                                    height: UIScreen.main.bounds.width / 8)
                        .padding(.leading, Constants.tightStackSpacing)
                    
                    VStack(alignment:.leading) {
                        Text(displayText)
                            .customFont(name: "Quicksand-Bold", style: .subheadline)
                            .foregroundColor(Color("MyPrimary"))
                            .lineLimit(3)

                        Spacer()
                        Text(dateToString(from: time,to: now))
                                .customFont(name: "Quicksand-SemiBold", style: .footnote)
                                .foregroundColor(.gray)
                    }
                    Spacer()
                    if notificationItem.payload is Meal {
                        if (notificationItem.payload as! Meal).weekday != 0 {
                            CalendarBadge(weekday: (notificationItem.payload as! Meal).weekday)
                        }
                    }
                }
               
            }
            
            .padding(.vertical, Constants.tightStackSpacing * 2)
    }
}




























//
//
//
//
//
//struct SingleFriendRequestRow_Previews: PreviewProvider {
//    static let user = MealqUser(id: "asdfsdf", fullname: "test", email: "sdf@lsd.com")
//    static var previews: some View {
//        SingleFriendRequestRow(user: user)
//    }
//}
