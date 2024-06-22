import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonView: View {
    @StateObject private var viewModel = UserViewModel()

    @State private var username: String = ""
    private let coordinator = SignInWithAppleCoordinator()
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                 .cornerRadius(8)
                 .padding(.horizontal)
             
             SignInWithAppleButton(
                 .signIn,
                 onRequest: { request in
                     request.requestedScopes = [.fullName, .email]
                 },
                 onCompletion: { result in
                     switch result {
                     case .success(let authorization):
                         self.coordinator.onSignIn = { userIdentifier, fullName, email in
                             viewModel.appleSignIn(email: email, username: username)
                         }
                         self.coordinator.authorizationController(controller: ASAuthorizationController(authorizationRequests: [ASAuthorizationAppleIDProvider().createRequest()]), didCompleteWithAuthorization: authorization)
                     case .failure(let error):
                         print("Authorization failed: \(error.localizedDescription)")
                     }
                 }
             )
             .signInWithAppleButtonStyle(.black)
             .frame(height: 50)
             .padding()
            
            if(viewModel.user != nil)
            {
                Text(viewModel.user!.email!)
            }
         }
     }
    
    
}





#Preview {
    SignInWithAppleButtonView()
}
