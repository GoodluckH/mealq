//
//  General.swift
//  mealq
//
//  Created by Xipu Li on 12/24/21.
//

import Foundation



func getAllMealParticipantsExSelf(to: [MealqUser], from: MealqUser, me: MealqUser) -> [MealqUser] {
    var toUsers = to
    toUsers.append(from)
    return toUsers.filter{$0 != me}
}

func combineArrays<T> (_ arrays: [T]...) -> [T] {
    return arrays.flatMap { $0 }
}
