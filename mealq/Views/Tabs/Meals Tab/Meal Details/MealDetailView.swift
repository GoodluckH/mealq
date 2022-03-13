//
//  MealDetailView.swift
//  mealq
//
//  Created by Xipu Li on 1/1/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Introspect
import Lottie

struct MealDetailView: View {
    @Binding var meal: Meal?
    var allowEdit: Bool
    @State private var showBigPic = false
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var messagseManager: MessagesManager
    
    @State private var showAlert = false
    @State private var editMealName = false
    @State private var text: String

    
    init(meal: Binding<Meal?>, allowEdit: Bool) {
        //Use this if NavigationBarTitle is with Large Font
       // UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
       // UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]
        // UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
      //   UINavigationItem.BackButtonDisplayMode = .minimal
            
        self._meal = meal
        self._text = State(initialValue: meal.wrappedValue?.name ?? "" )
        self.allowEdit = allowEdit
    }
    
    var body: some View {
         if let meal = meal {
             ZStack{
                 ScrollView{
                     VStack {
                
                        ProfilePicView(picURL: meal.from.normalPicURL)
                            .onTapGesture{showBigPic = true}
                            .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
                            .sheet(isPresented: $showBigPic) {
                                BigUserPicView(picURL: URL(string: ((meal.from.thumbnailPicURL?.absoluteString) != nil) ? meal.from.thumbnailPicURL!.absoluteString + "?width=1000&height=1000" : ""))
                            }.navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    HStack (spacing: Constants.tightStackSpacing) {
                                        if editMealName {
                                            TextField("",text: $text, onEditingChanged: {editingChanged in
                                                if !editingChanged {
                                                    editMealName = false
                                                }
                                            })
                                                .multilineTextAlignment(.center)
                                                .font(Font.custom("Quicksand-Bold", size: 20))
                                                .lineLimit(1)
                                                .onSubmit {
                                                    if text != meal.name{
                                                        mealsManager.changeMealName(to: text, for: meal.id)
                                                    }
                                                    editMealName = false
                                                }
                                                .introspectTextField { text in
                                                    text.becomeFirstResponder()
                                                }
                                            Image(systemName: "pencil")
                                                .foregroundColor(.clear)
                                        }
                                        else if mealsManager.changingMealName == .loading {
                                            LottieView(fileName: "wagmi-loading", loopMode: .loop)
                                                .frame(height: UIScreen.main.bounds.width / 5)
                                            Image(systemName: "pencil")
                                                .foregroundColor(.clear)
                                        }
                                            
                                        else {
                                            Text(meal.name).font(Font.custom("Quicksand-Bold", size: 20))
                                            if allowEdit{
                                                Button(action: {
                                                editMealName = true
                                            }) {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(Color("MyPrimary"))
                                            }
                                            }
                                        }
                                    
                                    }
                                }
                            }
                              
                        Text(meal.from.fullname)
                            .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                        
                        
                         MealControlButtons(userStatus: meal.to, meal: meal)
                         SetDetailedDate(mealID: meal.id).padding(.bottom)
                         
    //                         if mealsManager.settingSpecificDate == .loading {
    //                             LottieView(fileName: "wagmi-loading", loopMode: .loop)
    //                                 .frame(height: UIScreen.main.bounds.width / 4)
    //                         } else {
    //
    //                             if let mealDate = meal.specificDate {
    //                                 Text(mealDate, style: .timer)
    //                                 Text(mealDate, style: .date)
    //                                 Text(mealDate, style: .time)
    //                             } else {
    //                                 Text("specific date is not set")
    //                             }
    //                         }
                         MapSnippet(meal: meal)
                         
                       
                            LazyVStack(pinnedViews: [.sectionHeaders]){
                                Section(header: SectionHeader(headerText: "invited:")) {
                                    ForEach(meal.to.keys.sorted{$0.fullname > $1.fullname}, id: \.self) { user in
                                    
                                    HStack {
                                        NavigationLink(destination: UserProfileView(user: user)){
                                            ProfilePicView(picURL: user.normalPicURL)
                                                .frame(width: ProfilePicStyles.profilePicWidth / 2.5, height: ProfilePicStyles.profilePicHeight / 2.5)
                                            Text(user.fullname).foregroundColor(Color("MyPrimary"))
                                            
                                        }
                                        Spacer()
                                        Text(meal.to[user]!)
                                    }.padding(.horizontal)
                                    
                                }
                                }
                        }
                       
                    
                    Spacer()

                }
                 }
            
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
 
         }}
    }
    
}





















//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView()
//    }
//}
