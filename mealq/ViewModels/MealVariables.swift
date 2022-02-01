//
//  ShowMealButton.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import Foundation


class MealVariables: ObservableObject {
    static let sharedMealVariables = MealVariables()
    
    private init(){}
    
    @Published var showMealButton = true
    @Published var showUnreadBadges = true
    @Published var hideUnreadBadgesForMealID: String? = nil
}
