//
//  Settings.swift
//  NomiNom
//
//  Created by Owen Murphy on 5/9/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject private var userSessionManager: UserSessionManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Profile Button
                    NavigationLink(destination: ProfileEditView()) {
                        HStack {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            VStack (alignment: .leading) {
                                if let user = userSessionManager.currentUser {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Profile")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Loading...")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 20)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                    }
                    
                    // Section 1: General Settings
                    VStack(alignment: .leading, spacing: 10) {
                        Text("General")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        SettingsRow(title: "Get $0 delivery feees with NomiNom")
                        SettingsRow(title: "Payment")
                        SettingsRow(title: "Saved Stores")
                        SettingsRow(title: "My Rewards")
                        SettingsRow(title: "Get help")
                        SettingsRow(title: "Gift Card")
                        SettingsRow(title: "Refer Friends, Get $1")
                    }
                    .padding(.bottom)
                    
                    // Section 2: Account Settings
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Account Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        SettingsRow(title: "Manage Account")
                        SettingsRow(title: "Business Profile")
                        SettingsRow(title: "Address")
                        SettingsRow(title: "Privacy")
                        SettingsRow(title: "Notifications")
                        // Theme Button NavigationLink
                        NavigationLink(destination: ThemeSelectionView()) {
                            HStack {
                                Text("Theme")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        NavigationLink(destination: LanguageSettingsView()) {
                            HStack {
                                Text("Language Preference")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await refreshUserData()
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func refreshUserData() async {
        isLoading = true
        do {
            try await userSessionManager.refreshUserData()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct SettingsRow: View {
    let title: String
    var isToggle: Bool = false // Added for potential toggle controls
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if isToggle {
                Toggle("", isOn: .constant(false)) // Replace with actual state
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSessionManager.shared)
}
