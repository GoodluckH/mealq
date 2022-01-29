//
//  ActivitiesZone.swift
//  mealq
//
//  Created by Xipu Li on 1/28/22.
//

import SwiftUI

struct ActivitiesZone: View {
    @EnvironmentObject var activitiesManager: ActivitiesManager
    @EnvironmentObject var sessionStore: SessionStore
    
    @State var detailedCard: String? = nil
    
    

    
    var body: some View {
        if activitiesManager.loadingActivities == .loading {
            LottieView(fileName: "envelope").padding()
     } else {
         if activitiesManager.activities.isEmpty {
             Text("Empty feed")
             Spacer()
         } else {
            
                 
                     ScrollView() {
                         LazyVStack{
                     ForEach(activitiesManager.activities, id: \.id) {act in
                     SingleActivityCard(activity: act, me: sessionStore.localUser!, showDetail: detailedCard == act.id, detailedCard: $detailedCard)
                         
                             .padding(.vertical, Constants.tightStackSpacing)
                         .buttonStyle(.plain)
                         .listRowSeparator(.hidden)
                     
                     if act.id == activitiesManager.activities.last?.id {
                         if activitiesManager.activities.last?.id != (activitiesManager.masterAcitivityArray.last?["mealID"]! as! String) {
                             PlaceholderCard().onAppear {
                                 activitiesManager.getMoreActivities(fromIndex: activitiesManager.currentSliceEnd, delay: true)
                             }.padding(.vertical, Constants.tightStackSpacing)
                            
                         } else {
                             
                                 HStack{
                                     Spacer()
                                     Text("all caught up!")
                                     Spacer()
                                     
                                 }
                             }
                             
                          
                         }
                         
                 }
                 
                         }.padding()
                   
                
                     
                 
                 
             }
             //.listStyle(.plain)
         }
     }
    }
}

struct ActivitiesZone_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesZone()
    }
}
