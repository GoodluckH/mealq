//
//  Haptics.swift
//  mealq
//
//  Created by Xipu Li on 11/17/21.
//

import Foundation
import SwiftUI

struct Haptics {
    static let medium = { UIImpactFeedbackGenerator(style: .medium).impactOccurred()}
    static let soft = { UIImpactFeedbackGenerator(style: .soft).impactOccurred()}
    static let light = { UIImpactFeedbackGenerator(style: .light).impactOccurred()}
    static let heavy = { UIImpactFeedbackGenerator(style: .heavy).impactOccurred()}
    static let rigid = { UIImpactFeedbackGenerator(style: .rigid).impactOccurred()}
}
