//
//  MapSnapshotView.swift
//  mealq
//
//  Created by Xipu Li on 3/26/22.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
  let location: CLLocationCoordinate2D
  var span: CLLocationDegrees = 0.03

  @State private var snapshotImage: UIImage? = nil

  var body: some View {
      GeometryReader {geo in
          Group {
            if let image = snapshotImage {
              Image(uiImage: image)
            } else {
              ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
              .background(Color(UIColor.secondarySystemBackground))
            }
          } .onAppear {
              generateSnapshot(height: geo.size.height, width: geo.size.width)
            }
      }

  }
    
    func generateSnapshot(height: CGFloat, width: CGFloat) {

      // The region the map should display.
      let region = MKCoordinateRegion(
        center: self.location,
        span: MKCoordinateSpan(
          latitudeDelta: self.span,
          longitudeDelta: self.span
        )
      )

      // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true
        
        
      // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)

      snapshotter.start { (snapshotOrNil, errorOrNil) in
        if let error = errorOrNil {
          print(error)
          return
        }
        if let snapshot = snapshotOrNil {
            self.snapshotImage = snapshot.image
            snapshot.point(for: self.location)
        }
      }
    }
}

