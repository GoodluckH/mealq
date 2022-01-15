//
//  ViewManager.swift
//  mealq
//
//  Created by Xipu Li on 1/14/22.
//

import Foundation


class ViewManager: ObservableObject {
    static let sharedViewManager = ViewManager()
    
    // - MARK: Notification Handling
    @Published var selectedTab: Tab = .social
    @Published var selectedMealSession: String? // represents the mealID
    @Published var currentMealChatSession: String? 
    
    func toggleChatView(of mealID: String) {
        self.selectedTab = .meals
        self.selectedMealSession = mealID
    }
    
    
    
    private init() {}
}
