import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoading {
                LoadingView()
            } else if authViewModel.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
