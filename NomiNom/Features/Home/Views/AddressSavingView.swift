import SwiftUI
import MapKit

struct AddressSavingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddressSavingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    init(selectedAddress: LocationPrediction, addressType: String) {
        _viewModel = StateObject(wrappedValue: AddressSavingViewModel(selectedAddress: selectedAddress, addressType: addressType))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Selected Address
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.selectedAddress.structuredFormatting.mainText)
                            .font(.headline)
                        Text(viewModel.selectedAddress.structuredFormatting.secondaryText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        // Apartment/Suite and Entry Code
                        HStack(spacing: 16) {
                            InputField(title: "Apartment/Suite", text: $viewModel.apartment)
                            InputField(title: "Entry Code", text: $viewModel.entryCode)
                        }
                        
                        // Building Name
                        InputField(title: "Building Name", text: $viewModel.buildingName)
                        
                        // Map View
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Where is the location entrance?")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        if let coordinate = viewModel.coordinate {
                            LocationMapView(
                                coordinate: coordinate,
                                title: viewModel.selectedAddress.structuredFormatting.mainText,
                                subtitle: viewModel.selectedAddress.structuredFormatting.secondaryText
                            )
                        } else if viewModel.isLoading {
                            ProgressView()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Drop-off Options
                        InputField(title: "Drop-off Options", text: $viewModel.dropOffOptions)
                        
                        // Extra Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extra Description")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextEditor(text: $viewModel.extraDescription)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Address Label
                        InputField(title: "Address Label", text: $viewModel.addressLabel)

                        // Save Button
                        Button(action: {
                            Task {
                                await viewModel.saveAddress()
                                if viewModel.saveError == nil {
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                if viewModel.isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text("Save Address")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.buttonPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isSaving)

                        if let error = viewModel.saveError {
                            Text(error.localizedDescription)
                                .foregroundColor(themeManager.currentTheme.error)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Save Address")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveAddress()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

private struct InputField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    AddressSavingView(
        selectedAddress: LocationPrediction(
            placeId: "123",
            description: "123 Main St",
            structuredFormatting: StructuredFormatting(
                mainText: "123 Main St",
                secondaryText: "San Francisco, CA 94105"
            )
        ),
        addressType: "Home"
    )
    .environmentObject(ThemeManager())
} 