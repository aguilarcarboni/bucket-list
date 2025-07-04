//
//  bucket_listApp.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData

@main
struct bucket_listApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BucketListItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
