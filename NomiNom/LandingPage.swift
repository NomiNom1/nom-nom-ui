import SwiftUI

struct LandingPage: View {
    @State private var showSignIn = false
    @State private var showLanguageSettings = false
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                themeManager.currentTheme.background
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
                        Text("search_nearby".localized)
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(themeManager.currentTheme.buttonPrimary)
                            .cornerRadius(50)
                    }
                    .padding(.bottom, 10)
                    
                    Button(action: {
                        showSignIn = true
                    }) {
                        Text("sign_in".localized)
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.buttonPrimary)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(themeManager.currentTheme.buttonPrimary, lineWidth: 2)
                            )
                    }
                    .padding(.bottom, 20)
                    
                    // Language Selection Button
                    Button(action: {
                        showLanguageSettings = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text(languageManager.currentLanguage.displayName)
                        }
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
            .sheet(isPresented: $showLanguageSettings) {
                LanguageSettingsView()
            }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
            .environmentObject(ThemeManager())
            .environmentObject(LanguageManager.shared)
    }
} 
