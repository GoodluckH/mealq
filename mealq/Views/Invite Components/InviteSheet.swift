//
//  InviteSheet.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import Introspect




struct InviteSheet: View {
    @State var selectedFriends: [MealqUser] = []
    @State var mealName = ""
    @EnvironmentObject var friendsManager: FriendsManager
    @State var isDragging = false

    var drag: some Gesture {
        DragGesture(minimumDistance: 50)
            .onChanged { _ in
                self.isDragging = true
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
            .onEnded { _ in self.isDragging = false }
    }
    
    var body: some View {
    
        ScrollView ([], showsIndicators: false) { // pass in an empty set to disable the scrolling
            VStack {
                Header(mealName: $mealName, selectedFriends: selectedFriends).padding(.top).padding(.top)
                FakeSearchBar().shadow(color: .gray, radius: searchBarShadowRadius, y: searchBarShadowYOffset)
                
                HStack{
                    if friendsManager.friends.isEmpty {
                        Text("no friends yet; search to add more").bold()
                    }
                    else {Text("tap to select friends").bold()}
                    Spacer()
                    
                }.padding(.horizontal).offset(y: 16)
                FriendSelection(selectedFriends: $selectedFriends)
                
                HStack{Text("tap to select a date (optional)").bold(); Spacer()}.padding(.horizontal).offset(y: 16)
                Spacer()
      
            } // VStack
            .introspectViewController{vc in if let sheet = vc.sheetPresentationController {sheet.prefersGrabberVisible = true}}
            .gesture(drag)
            
        }.onTapGesture {UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)}

    }
    
    
    private let searchBarShadowRadius: CGFloat = 5
    private let searchBarShadowYOffset: CGFloat = 2

}










struct Header: View {
    @Binding var mealName: String
    @FocusState private var focused: Bool
    var selectedFriends: [MealqUser]
    @State var scale: CGFloat = 1

    
    
    var body: some View {
        HStack {
            TextField("", text: $mealName)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .accentColor(Color("MyPrimary"))
                .placeholder("meal name", when: mealName.isEmpty, textColor: (mealName.isEmpty && focused) ? .gray : .primary)
                .introspectTextField {text in text.becomeFirstResponder()}
                .focused($focused)
                .frame(alignment: .leading)
                .font(.largeTitle.weight(.black))
                .minimumScaleFactor(0.1)
                .scaleEffect(scale)
                .onChange(of: focused) { state in
                    let baseAnimation = Animation.easeInOut(duration: 1)
                    if !state {
                        withAnimation(baseAnimation) {
                            scale = 0.5
                        }
                    }
                }
            
        }
        .padding()
        
    }
}







//
//
//
//struct SendInviteButton: View {
//    var selectedFriends: [MealqUser]
//    var body: some View {
//            Button(action:{}) {
//                Image(systemName: "paperplane.circle.fill")
//                    .foregroundColor(selectedFriends.isEmpty ? .gray : .primary)
//                    .font(.largeTitle.weight(.black))
//            }
//            .disabled(selectedFriends.isEmpty)
//
//    }
//}
//

























struct InviteSheet_Previews: PreviewProvider {
    static var previews: some View {
        InviteSheet()
            .preferredColorScheme(.light)
    }
}
