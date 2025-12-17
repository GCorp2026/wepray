//
//  AuthView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedLanguage: Language?
    @State private var selectedDenomination: ChristianDenomination?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    formSection
                    languageSection
                    denominationSection
                    actionButton
                    toggleAuthMode
                }
                .padding(20)
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            selectedLanguage = appState.languages.first(where: { $0.code == "en" })
            selectedDenomination = appState.denominations.first(where: { $0.name == "Protestant" })
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary)

            Text("WePray")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text(isSignUp ? "Create your account" : "Welcome back")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
        }
        .padding(.top, 40)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            if isSignUp {
                CustomTextField(
                    placeholder: "Display Name",
                    text: $displayName,
                    icon: "person.fill"
                )
            }

            CustomTextField(
                placeholder: "Email",
                text: $email,
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )

            CustomTextField(
                placeholder: "Password",
                text: $password,
                icon: "lock.fill",
                isSecure: true
            )

            if isSignUp {
                CustomTextField(
                    placeholder: "Confirm Password",
                    text: $confirmPassword,
                    icon: "lock.fill",
                    isSecure: true
                )
            }
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Language")
                .font(.headline)
                .foregroundColor(AppColors.text)

            Menu {
                ForEach(appState.languages.sorted { $0.name < $1.name }) { language in
                    Button(action: { selectedLanguage = language }) {
                        HStack {
                            Text(language.flag)
                            Text(language.name)
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if let lang = selectedLanguage {
                        Text(lang.flag)
                        Text(lang.name)
                    } else {
                        Text("Select Language")
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            .foregroundColor(AppColors.text)
        }
    }

    private var denominationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Denomination")
                .font(.headline)
                .foregroundColor(AppColors.text)

            Menu {
                ForEach(appState.denominations.sorted { $0.name < $1.name }) { denom in
                    Button(action: { selectedDenomination = denom }) {
                        HStack {
                            Text(denom.name)
                            if selectedDenomination == denom {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if let denom = selectedDenomination {
                        Text(denom.name)
                    } else {
                        Text("Select Denomination")
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            .foregroundColor(AppColors.text)
        }
    }

    private var actionButton: some View {
        Button(action: handleAuth) {
            Text(isSignUp ? "Sign Up" : "Log In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }

    private var toggleAuthMode: some View {
        Button(action: { isSignUp.toggle() }) {
            Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                .font(.subheadline)
                .foregroundColor(AppColors.primary)
        }
    }

    private func handleAuth() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }

        if isSignUp {
            guard !displayName.isEmpty else {
                errorMessage = "Please enter a display name"
                showError = true
                return
            }

            guard password == confirmPassword else {
                errorMessage = "Passwords do not match"
                showError = true
                return
            }

            guard password.count >= 6 else {
                errorMessage = "Password must be at least 6 characters"
                showError = true
                return
            }
        }

        guard let language = selectedLanguage, let denomination = selectedDenomination else {
            errorMessage = "Please select a language and denomination"
            showError = true
            return
        }

        let user = UserProfile(
            displayName: isSignUp ? displayName : email.components(separatedBy: "@").first ?? "User",
            email: email,
            selectedLanguage: language,
            selectedDenomination: denomination,
            isAdmin: email.contains("admin")
        )

        appState.login(user: user, isNewUser: isSignUp)
    }
}

// MARK: - Custom Text Field with Password Visibility Toggle
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    @State private var showPassword: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.subtext)
                .frame(width: 20)

            if isSecure {
                Group {
                    if showPassword {
                        TextField(placeholder, text: $text)
                            .autocapitalization(.none)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }

                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppColors.subtext)
                }
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
