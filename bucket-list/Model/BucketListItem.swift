//
//  Item.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class BucketListItem: Identifiable {
    var id: UUID
    var activity: String
    var created: Date
    var updated: Date
    var imagePaths: [String]
    var completed: Bool
    var location: String?
    var latitude: Double?
    var longitude: Double?
    
    init(
        activity: String,
        imagePaths: [String] = [],
        completed: Bool = false,
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = UUID()
        self.activity = activity
        self.created = Date()
        self.updated = Date()
        self.imagePaths = imagePaths
        self.completed = completed
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func markAsCompleted() {
        self.completed = true
    }

    func markAsIncomplete() {
        self.completed = false
    }
}
