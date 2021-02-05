//
//  DropablePin.swift
//  PreInterviewTask
//
//  Created by Sherbeny on 04/02/2021.
//

import Foundation
import MapKit

class DropablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
