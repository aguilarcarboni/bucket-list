//
//  Item.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import Foundation
import SwiftData

@Model
final class BucketListItem {
    var id: UUID
    var activity: String
    var created: Date
    var updated: Date
    var imagePaths: [String]
    var completed: Bool
    var location: String?
    
    init(
        activity: String,
        imagePaths: [String] = [],
        completed: Bool = false,
        location: String? = nil
    ) {
        self.id = UUID()
        self.activity = activity
        self.created = Date()
        self.updated = Date()
        self.imagePaths = imagePaths
        self.completed = completed
        self.location = location
    }

    func markAsCompleted() {
        self.completed = true
    }

    func markAsIncomplete() {
        self.completed = false
    }
}
