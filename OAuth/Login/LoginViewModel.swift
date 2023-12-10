//
//  LoginViewModal.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/5/23.
//

import AuthenticationServices

class LoginViewModel:NSObject, ObservableObject {
    
    @Published var isAuthorized = false
    @Published var isLoading = false
    
    func signInpressed() {
        
        guard let signInURL = NetworkRequest.RequestType.signIn.networkRequest()?.url
        else {
            print("Could not create the sign in URL .")
            return
        }
        
        let callbackURLScheme = NetworkRequest.callbackURLScheme
        let authenticationSession = ASWebAuthenticationSession(
          url: signInURL,
          callbackURLScheme: callbackURLScheme) { [weak self] callbackURL, error in
          guard
            error == nil,
            let callbackURL = callbackURL,
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
            let code = queryItems.first(where: { $0.name == "code" })?.value,
            let networkRequest =
              NetworkRequest.RequestType.codeExchange(code: code).networkRequest()
          else {
            print("An error occurred when attempting to sign in.")
            return
          }

          self?.isLoading = true
          networkRequest.start(responseType: String.self) { result in
            switch result {
            case .success:
              self?.isAuthorized = true
            case .failure(let error):
              print("Failed to exchange access code for tokens: \(error)")
              self?.isLoading = false
            }
          }
        }

        authenticationSession.presentationContextProvider = self
        authenticationSession.prefersEphemeralWebBrowserSession = true

        if !authenticationSession.start() {
          print("Failed to start ASWebAuthenticationSession")
        }
    }
}

extension LoginViewModel: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession)
  -> ASPresentationAnchor {
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first as? UIWindowScene
      let window = windowScene?.windows.first
      return window ?? ASPresentationAnchor()
  }
}
