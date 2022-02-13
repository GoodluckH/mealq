//
//  DatePickerViewModel.swift
//  mealq
//
//  Created by Xipu Li on 2/12/22.
//

import Foundation


class DatePickerViewModel: ObservableObject {
    static var sharedDatePickerViewModel = DatePickerViewModel()
    @Published var showDatePicker = false
    @Published var date: Date = Date()
    @Published var animate = false
    @Published var currentMeal = ""
    
    private init() {}
}
