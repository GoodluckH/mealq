//
//  ViewManager.swift
//  mealq
//
//  Created by Xipu Li on 1/14/22.
//

import Foundation


class ViewManager: ObservableObject {
    static let sharedViewManager = ViewManager()
    
    @Published var selectedTab: Tab = .social
    // - MARK: Notification Handling for Chat Messages
    @Published var selectedMealSession: String? // represents the mealID
    @Published var currentMealChatSession: String?
  //  @Published var launchedWhenAppNotRunning = false
    
    func toggleChatView(of mealID: String) {
        self.selectedTab = .meals
        self.selectedMealSession = mealID
    }
    
    
    private init() {}
}
