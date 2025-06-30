//
//  ContentView.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    var body: some View {
        TabView {
            BucketListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
    }
}

struct BucketListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var bucketListItems: [BucketListItem]
    @State private var showingCreateSheet = false
    @State private var showingImportSheet = false
    @State private var selectedBucketListItem: BucketListItem?

    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                if bucketListItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("No Items Yet")
                                .font(.title2)
                                .bold()
                            
                            Text("Add your first bucket list item to get started")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingCreateSheet = true }) {
                            Label("Add Item", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $selectedBucketListItem) {
                        ForEach(bucketListItems) { item in
                            NavigationLink(value: item) {
                                BucketListItemRowView(item: item)
                            }
                        }
                        .onDelete(perform: deleteBucketListItems)
                    }
                    .listStyle(.sidebar)
                }
            }
            .navigationTitle("Bucket List")
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: { showingImportSheet = true }) {
                        Label("Import CSV", systemImage: "doc.text")
                    }
                    .help("Import items from CSV file")
                    
                    Button(action: { showingCreateSheet = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .help("Add new bucket list item")
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateBucketListItemView()
            }
            .sheet(isPresented: $showingImportSheet) {
                CSVImportView()
            }
        } detail: {
            if let selectedBucketListItem = selectedBucketListItem {
                BucketListItemView(item: selectedBucketListItem)
            } else if bucketListItems.isEmpty {
                EmptyStateDetailView(showingCreateSheet: $showingCreateSheet)
            } else {
                DefaultDetailView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    private func deleteBucketListItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let itemToDelete = bucketListItems[index]
                if selectedBucketListItem == itemToDelete {
                    selectedBucketListItem = nil
                }
                modelContext.delete(itemToDelete)
            }
        }
    }
}

struct BucketListItemRowView: View {
    let item: BucketListItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(item.completed ? .green.opacity(0.2) : .gray.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.completed ? .green : .secondary)
                    .font(.system(size: 16, weight: .medium))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.activity)
                    .font(.headline)
                    .strikethrough(item.completed)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if item.completed {
                        Label {
                            Text(item.created, format: .dateTime.day().month().year())
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    if let location = item.location {
                        Label {
                            Text(location)
                        } icon: {
                            Image(systemName: "location")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            if !item.imagePaths.isEmpty {
                Image(systemName: "photo")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct DefaultDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("Select an Item")
                    .font(.title2)
                    .bold()
                
                Text("Choose a bucket list item from the sidebar to view details")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial.opacity(0.3))
    }
}

struct EmptyStateDetailView: View {
    @Binding var showingCreateSheet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.star")
                .font(.system(size: 72))
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                Text("Start Your Journey")
                    .font(.largeTitle)
                    .bold()
                
                Text("Create your first bucket list item and begin tracking your dreams and adventures")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button(action: { showingCreateSheet = true }) {
                    Label("Add Your First Item", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("Or drag and drop a CSV file to import items")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial.opacity(0.3))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BucketListItem.self, inMemory: true)
}
