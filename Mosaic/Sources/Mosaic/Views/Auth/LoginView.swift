import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mosaicBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Mosaic")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Color.mosaicAccent)
                        Text("Real connections. Radical accountability.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .mosaicTextField()

                        SecureField("Password", text: $password)
                            .mosaicTextField()
                    }

                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await authViewModel.signIn(email: email, password: password) }
                    } label: {
                        Group {
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In").frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .buttonStyle(MosaicPrimaryButtonStyle())
                    .disabled(authViewModel.isLoading)

                    Button("Create an account") {
                        showSignUp = true
                    }
                    .foregroundStyle(Color.mosaicAccent)
                }
                .padding(32)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
