//
//  BucketListItemView.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct BucketListItemView: View {
    @Bindable var item: BucketListItem
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var region: MKCoordinateRegion?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with completion status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.activity)
                            .font(.largeTitle)
                            .bold()
                            .strikethrough(item.completed)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.completed ? .green : .orange)
                                .frame(width: 12, height: 12)
                            
                            Text(item.completed ? "Completed" : "Not completed")
                                .font(.subheadline)
                                .foregroundColor(item.completed ? .green : .orange)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 32))
                        .foregroundColor(item.completed ? .green : .gray)
                }
                
                // Location Section with Map
                if let coordinate = item.coordinate {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Location")
                                .font(.headline)
                        }
                        
                        if let location = item.location {
                            Text(location)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Mini Map
                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )), annotationItems: [item]) { bucketItem in
                            MapAnnotation(coordinate: bucketItem.coordinate!) {
                                ZStack {
                                    Circle()
                                        .fill(bucketItem.completed ? .green : .blue)
                                        .frame(width: 20, height: 20)
                                    
                                    Image(systemName: bucketItem.completed ? "checkmark" : "star.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 8, weight: .bold))
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        .disabled(true)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.circle")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(coordinate.latitude, specifier: "%.4f"), \(coordinate.longitude, specifier: "%.4f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                } else if let location = item.location {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text("Location")
                                .font(.headline)
                        }
                        
                        Text(location)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                // Images Section
                if !item.imagePaths.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(.purple)
                            Text("Photos (\(item.imagePaths.count))")
                                .font(.headline)
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(item.imagePaths, id: \.self) { imagePath in
                                AsyncImage(url: getImageURL(for: imagePath)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(.gray.opacity(0.3))
                                        .overlay {
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        }
                                }
                                .frame(height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                // Details Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Details")
                            .font(.headline)
                    }
                    
                    VStack(spacing: 8) {
                        DetailRow(label: "Created", value: item.created.formatted(date: .abbreviated, time: .shortened))
                        DetailRow(label: "Updated", value: item.updated.formatted(date: .abbreviated, time: .shortened))
                        DetailRow(label: "Status", value: item.completed ? "✅ Completed" : "⏳ Pending")
                        DetailRow(label: "ID", value: item.id.uuidString.prefix(8) + "...")
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
                
                Button(item.completed ? "Mark Incomplete" : "Mark Complete") {
                    withAnimation {
                        if item.completed {
                            item.markAsIncomplete()
                        } else {
                            item.markAsCompleted()
                        }
                        item.updated = Date()
                    }
                }
                .foregroundColor(item.completed ? .orange : .green)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditBucketListItemView(item: item)
        }
    }
    
    private func getImageURL(for imagePath: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(imagePath)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// Edit View (placeholder for now)
struct EditBucketListItemView: View {
    @Bindable var item: BucketListItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Edit functionality coming soon...")
                .navigationTitle("Edit Item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
