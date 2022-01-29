//
//  SingleActivityCard.swift
//  mealq
//
//  Created by Xipu Li on 1/28/22.
//

import SwiftUI

struct SingleActivityCard: View {
    var activity: Meal
    var me: MealqUser
    var showDetail: Bool
    @Binding var detailedCard: String? 
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @Namespace var nspace
    
    

    
    
    var body: some View {
        
        VStack{
            
            VStack(alignment: .leading){
                HStack {
                    
                    NavigationLink(destination: UserProfileView(user: activity.from)) {
                        ProfilePicView(picURL: activity.from.normalPicURL)
                            .frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                    }
                    
                    
                     
        
                    
                VStack(alignment: .leading) {
                    if activity.from.id == me.id {
                        NavigationLink(destination: UserProfileView(user: activity.from)) {
                         Text("You").customFont(name: "Quicksand-Bold", style: .headline, weight: .bold)
                        }
                    }
                    else {
                        NavigationLink(destination: UserProfileView(user: activity.from)) {
                            Text(activity.from.fullname).customFont(name: "Quicksand-Bold", style: .headline)
                        }
                    }
                    if let date = getTimeStampBetween(lastDate: Date(), and: activity.createdAt, mandatory: true) {
                        if date == "Today"  {
                            Text(activity.createdAt, style: .time).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                        } else if date == "Yesterday" {
                            HStack(spacing: 4){
                                Text(date).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                                Text(activity.createdAt, style: .time).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                            }
                        } else if date == "FULLDATE" {
                            Text(activity.createdAt, style: .date).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                        } else {
                            HStack(spacing: 4){
                                Text(date).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                                Text(activity.createdAt, style: .time).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                            }
                        }
                    } else {
                        Text(activity.createdAt, style: .date).customFont(name: "Quicksand-SemiBold", style: .caption1).foregroundColor(.gray)
                    }
                    
                    
                }
                    
                Spacer()
                if activity.weekday != 0 {
                    CalendarBadge(weekday: activity.weekday)
                    .frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                }
            }
                (Text("invited \(activity.to.count) people for ").foregroundColor(.gray) + Text("\(activity.name)"))
                    .customFont(name: "Quicksand-SemiBold", style: .subheadline).padding(.top, Constants.tightStackSpacing)
                
                
                if showDetail {
                    VStack (alignment: .leading) {
                        ForEach(Array(activity.to.keys)) {user in
                            HStack{
                                NavigationLink(destination: UserProfileView(user: user)) {
                                    ProfilePicView(picURL: user.normalPicURL)
                                     .frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                                     .matchedGeometryEffect(id: user.id, in: nspace)
                                    if user.id == me.id {Text("You").customFont(name: "Quicksand-SemiBold", style: .subheadline, weight: .bold)}
                                    else {
                                        Text(user.fullname).customFont(name: "Quicksand-SemiBold", style: .subheadline)
                                        if let _ = friendsManager.friends.firstIndex(of: user) {
                                            Image(systemName: "person.2.fill")
                                                .font(.system(size: 15))
                                                .foregroundColor(.gray)
                                        }
                                            
                                               
                                               
                                        
                                        
                                    }
                                    
                                }
                       
                                Spacer()
                            }
                        }
                    }
                } else {
                    HStack {
                        ForEach(Array(activity.to.keys)) {user in
                            ProfilePicView(picURL: user.normalPicURL)
                                .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                                .matchedGeometryEffect(id: user.id, in: nspace)
                        }
                    Spacer()
                    }
                }
                

            }.padding()

        }.background(

                RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius)
                    .foregroundColor(Color("QueryLoaderStartingColor"))
                    .shadow(color: .gray, radius: detailedCard == activity.id ? Constants.roundedRectShadowRadius : Constants.roundedRectSelectedShadowRadius)
                    .onTapGesture{
                        withAnimation(.easeOut(duration: 0.2)){
                            if detailedCard == activity.id {detailedCard = nil}
                            else {detailedCard = activity.id}
                        }
                    
                    }
            
            
            
        )
    }
}


















//struct SingleActivityCard_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleActivityCard(activity: Meal(id: "!2312fsdf", name: "Okemo", from: <#T##MealqUser#>, to: <#T##[MealqUser : String]#>, weekday: <#T##Int#>, createdAt: <#T##Date#>, recentMessageID: <#T##String#>, recentMessageContent: <#T##String#>, sentByName: <#T##String#>, messageTimeStamp: <#T##Date#>, unreadMessages: <#T##Int#>))
//    }
//}
