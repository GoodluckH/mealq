//
//  BigUserPicMotionObserver.swift
//  mealq
//
//  Created by Xipu Li on 11/23/21.
//

import SwiftUI
import CoreMotion



class MotionObserver: ObservableObject {
    @Published var motionManager = CMMotionManager()
    
    @Published var xValue: CGFloat = 0
    @Published var yValue: CGFloat = 0
    
    @Published var movingOffset: CGSize = .zero
    
    
    /// Gets the current device motion data and store them to respective properties.
    ///
    /// Note that "roll" indicates the motion around the device's x-axis and "pitch" y-axis.
    ///
    /// - parameter duration: how much movement.
    /// - SeeAlso: `xValue`, `yValue`
    func fetchMotionData(duration: CGFloat) {
        motionManager.startDeviceMotionUpdates(to: .main) { data, err in
            if let err = err {
                print(err.localizedDescription); return;
            }
            guard let data = data else {
                print("Error getting device motion data"); return;
            }
            
            withAnimation{
                self.xValue = data.attitude.roll
                self.yValue = data.attitude.pitch
                self.movingOffset = self.getOffset(duration: duration)
            }

        }
    }
    
    
    /// Computes the offset given duration.
    /// - returns: a `CGSize` property to be used for `offset`.
    private func getOffset(duration: CGFloat) -> CGSize {
        var width = duration * xValue
        var height = duration * yValue
        
        // avoid the picture goes off device frame
        width = (width < 0 ? (-width > duration ? -duration : width) : (width > duration ? duration : width))
        height = (height < 0 ? (-height > duration ? -duration : height) : (height > duration ? duration : height))
        
        return CGSize(width: width, height: height)
    }
}
