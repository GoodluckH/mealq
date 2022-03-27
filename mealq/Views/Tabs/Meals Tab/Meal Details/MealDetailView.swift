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














extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}






//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView()
//    }
//}
