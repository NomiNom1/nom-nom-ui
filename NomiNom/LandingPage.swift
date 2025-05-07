import SwiftUI

struct LandingPage: View {
    var body: some View {
        ZStack {
            // Background Color
            AppColors.primary
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Logo
                Image("logo") // Replace with your logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                    .padding(.top, 50)

                Spacer()
                
                Button(action: {
                    // Action for Search Nearby
                }) {
                    Text("Search Nearby")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(AppColors.Button.secondary)
                        .cornerRadius(50)
                }
                .padding(.bottom, 10)

                Button(action: {
                    // Action for Sign In
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(AppColors.Button.secondary)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(AppColors.Button.secondary, lineWidth: 2)
                        )
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
    }
} 
