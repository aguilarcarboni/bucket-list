//
//  Created by Andrés on 28/6/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct CreateBucketListItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var activity = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    TextField("Enter bucket list activity", text: $activity)
                }
                
                Section("Images") {
                    PhotosPicker(
                        selection: $selectedImages,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                    }
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(activity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onChange(of: selectedImages) { _, newItems in
            Task {
                await loadImages(from: newItems)
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        var loadedData: [Data] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                loadedData.append(data)
            }
        }
        
        await MainActor.run {
            imageData = loadedData
        }
    }
    
    private func addItem() {
        let imagePaths = saveImages()
        let newItem = BucketListItem(
            activity: activity.trimmingCharacters(in: .whitespacesAndNewlines),
            imagePaths: imagePaths
        )
        modelContext.insert(newItem)
        dismiss()
    }
    
    private func saveImages() -> [String] {
        var savedPaths: [String] = []
        
        for (index, data) in imageData.enumerated() {
            let fileName = "\(UUID().uuidString)_\(index).jpg"
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                savedPaths.append(fileName)
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        return savedPaths
    }
}

