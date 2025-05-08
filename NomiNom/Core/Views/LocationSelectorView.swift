import SwiftUI

struct LocationSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var address: String = "123 Main Street, City, State"
    
    var body: some View {
        NavigationView {
            VStack {
                // Handle bar for dragging
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                // Address content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Address")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(address)
                        .font(.body)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LocationSelectorView()
} 