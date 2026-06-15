import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var ageText = ""

    private var age: Int { Int(ageText) ?? 0 }
    private var isValid: Bool {
        !email.isEmpty && password.count >= 8 && !displayName.isEmpty && age >= 18
    }

    var body: some View {
        ZStack {
            Color.mosaicBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Create Account")
                        .font(.title.bold())

                    VStack(spacing: 14) {
                        TextField("Display name", text: $displayName)
                            .mosaicTextField()

                        TextField("Age (18+)", text: $ageText)
                            .keyboardType(.numberPad)
                            .mosaicTextField()

                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .mosaicTextField()

                        SecureField("Password (8+ characters)", text: $password)
                            .mosaicTextField()
                    }

                    Text("By signing up, you confirm you are 18 or older and agree to our Terms of Service.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            await authViewModel.signUp(
                                email: email,
                                password: password,
                                displayName: displayName,
                                age: age
                            )
                        }
                    } label: {
                        Group {
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Join Mosaic").frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .buttonStyle(MosaicPrimaryButtonStyle())
                    .disabled(!isValid || authViewModel.isLoading)
                }
                .padding(32)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
