//
//  BucketListItemView.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData

struct BucketListItemView: View {
    @Bindable var item: BucketListItem
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.activity)
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                    
                    HStack {
                        Text("Created:")
                        Spacer()
                        Text(item.created, format: .dateTime.day().month().year())
                    }

                    if let location = item.location {
                        HStack {
                            Text("Location:")
                            Spacer()
                            Text(location)
                        }
                    } else {
                        HStack {
                            Text("Location:")
                            Spacer()
                            Text("Not specified")
                        }
                    }
                }
                .padding()
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(item.completed ? "Mark Incomplete" : "Mark Complete") {
                    if item.completed {
                        item.markAsIncomplete()
                    } else {
                        item.markAsCompleted()
                    }
                }
            }
        }
    }
}
