 //
//  test.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct test: View {
    @State var text = ""
    @State var showSearchResult: Bool = false
    @FocusState private var usernameFieldIsFocused: Bool
    var body: some View {
        ZStack (alignment: .top) {
            VStack {
      
                NavigationView{
                    VStack{
                        Text("lsjflkasdjfkasdjlkfjasdkljf")
                        Text("lsjflkasdjfkasdjlkfjasdkljf")
                        Text("lsjflkasdjfkasdjlkfjasdkljf")
                        Text("lsjflkasdjfkasdjlkfjasdkljf")
                        NavigationLink("", destination: RoundedRectangle(cornerRadius:25), isActive: $showSearchResult)
                    }
                }
             
            }
           
       }
}
}



struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
