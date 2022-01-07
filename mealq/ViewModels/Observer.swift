//
//  Observer.swift
//  mealq
//
//  Created by Xipu Li on 1/5/22.
//

import Foundation
import UIKit

class Observer: ObservableObject {

    @Published var enteredForeground = true

    init() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }

    @objc func willEnterForeground() {
        enteredForeground.toggle()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
