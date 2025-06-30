//
//  MapView.swift
//  bucket-list
//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import MapKit
import SwiftData
import GeoToolbox

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var bucketListItems: [BucketListItem]
    @State private var cameraPosition = MapCameraPosition.automatic
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingCreateSheet = false
    @State private var selectedLocationName: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { reader in
                    Map(position: $cameraPosition) {
                        // Show existing bucket list items as pins
                        ForEach(bucketListItems.filter { $0.coordinate != nil }, id: \.id) { item in
                            if let coordinate = item.coordinate {
                                Annotation(item.activity, coordinate: coordinate) {
                                    ZStack {
                                        Circle()
                                            .fill(item.completed ? .green : .blue)
                                            .frame(width: 30, height: 30)
                                        
                                        Image(systemName: item.completed ? "checkmark" : "star.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                }
                            }
                        }
                        
                        // Show temporary pin for selected location
                        if let selectedLocation = selectedLocation {
                            Annotation("New Location", coordinate: selectedLocation) {
                                ZStack {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 30, height: 30)
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .bold))
                                }
                            }
                        }
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .sequenced(before: DragGesture(minimumDistance: 0))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    if let location = drag?.location,
                                       let coordinate = reader.convert(location, from: .local) {
                                        handleLongPress(coordinate: coordinate)
                                    }
                                default:
                                    break
                                }
                            }
                    )
                }
                
                // Instructions and floating action button
                VStack {
                    if selectedLocation == nil && bucketListItems.filter({ $0.coordinate != nil }).isEmpty {
                        HStack {
                            Text("Tap and hold on the map to place a pin")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.regularMaterial, in: Capsule())
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        if selectedLocation != nil {
                            Button(action: {
                                showingCreateSheet = true
                            }) {
                                Label("Add Item Here", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(.blue)
                                    .clipShape(Capsule())
                                    .shadow(radius: 4)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Map")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if selectedLocation != nil {
                        Button("Clear Pin") {
                            selectedLocation = nil
                            selectedLocationName = ""
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateBucketListItemView(
                    preselectedLocation: selectedLocation,
                    preselectedLocationName: selectedLocationName
                )
            }
        }
    }
    
    private func handleLongPress(coordinate: CLLocationCoordinate2D) {
        selectedLocation = coordinate
        
        // Get location name using reverse geocoding
        Task {
            await reverseGeocode(coordinate: coordinate)
        }
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) async {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        guard let request = MKReverseGeocodingRequest(location: location) else {
            await MainActor.run {
                selectedLocationName = "Unknown Location"
            }
            return
        }
        
        do {
            let mapItems = try await request.mapItems
            if let mapItem = mapItems.first,
               let placeDescriptor = PlaceDescriptor(item: mapItem) {
                
                await MainActor.run {
                    // Use the modern GeoToolbox PlaceDescriptor API
                    if let commonName = placeDescriptor.commonName {
                        selectedLocationName = commonName
                    } else if let address = placeDescriptor.address {
                        selectedLocationName = address
                    } else {
                        // Fallback to the traditional approach
                        selectedLocationName = [
                            mapItem.name,
                            mapItem.placemark.locality,
                            mapItem.placemark.administrativeArea,
                            mapItem.placemark.country
                        ].compactMap { $0 }.joined(separator: ", ")
                    }
                    
                    // If still empty, use a default
                    if selectedLocationName.isEmpty {
                        selectedLocationName = "Selected Location"
                    }
                }
            } else {
                await MainActor.run {
                    selectedLocationName = "Unknown Location"
                }
            }
        } catch {
            print("Reverse geocoding failed: \(error)")
            await MainActor.run {
                selectedLocationName = "Unknown Location"
            }
        }
    }
}



#Preview {
    MapView()
        .modelContainer(for: BucketListItem.self, inMemory: true)
} 