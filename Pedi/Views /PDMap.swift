//
//  PDMap.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/21/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections

class PDMap: MGLMapView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    styleURL = URL(string: "mapbox://styles/irosenb/cjjyq8qjq801e2rlhdg0i1ceu")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addRoute(_ route: Route) {
    let distanceFormatter = LengthFormatter()
    let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
    
    let travelTimeFormatter = DateComponentsFormatter()
    travelTimeFormatter.unitsStyle = .short
    let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
    
    var routeCoordinates = route.coordinates!
    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
    
    // Add the polyline to the map and fit the viewport to the polyline.
    let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
    
    addAnnotation(routeLine)
    setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: edge, animated: true)
  }
}
