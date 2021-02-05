//
//  PlaceModel.swift
//  PreInterviewTask
//
//  Created by Sherbeny on 05/02/2021.
//

import Foundation
import Firebase

class PlaceModel {
    
   
    private(set) public var name: String
    private(set) public var latitude: Double
    private(set) public var longitude: Double
    private(set) public var documentId: String
    
    init(name: String, latitude: Double, longitude: Double, documentId: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.documentId = documentId
    }
    
    class func parseData(dataSet: QuerySnapshot?) -> [PlaceModel] {
        
        var place = [PlaceModel]()
        guard let dataSet = dataSet else { return place}
        
        for document in dataSet.documents {
            let name = document["name"] as? String ?? "Anyplace"
            let latitude = document["latitude"] as? Double ?? 0.0
            let longitude = document["longitude"] as? Double ?? 0.0
            let documentID = document.documentID
            
            let placeModel = PlaceModel(name: name, latitude: latitude, longitude: longitude, documentId: documentID)
            place.append(placeModel)
        }
        
        return place
    }
    
}
