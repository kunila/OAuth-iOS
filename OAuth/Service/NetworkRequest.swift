//
//  NetworkRequest.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/5/23.
//

import Foundation
import CryptoKit

extension Data {
    // Returns a base64 encoded string, replacing reserved characters
    // as per the PKCE spec https://tools.ietf.org/html/rfc7636#section-4.2
    func pkce_base64EncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

struct NetworkRequest {
  enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
  }

  enum RequestError: Error {
    case invalidResponse
    case networkCreationError
    case otherError
    case sessionExpired
  }

  enum RequestType: Equatable {
    case codeExchange(code: String)
    case getRepos
    case getUser
    case signIn

    func networkRequest() -> NetworkRequest? {
      guard let url = url() else {
        return nil
      }
      return NetworkRequest(method: httpMethod(), url: url)
    }

    private func httpMethod() -> NetworkRequest.HTTPMethod {
      switch self {
      case .codeExchange:
        return .post
      case .getRepos:
        return .get
      case .getUser:
        return .get
      case .signIn:
        return .get
      }
    }
      
      enum PKCE {
          static func generateCodeVerifier() -> String {
              var buffer = [UInt8](repeating: 0, count: 32)
              _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
              return Data(buffer).base64EncodedString()
          }

          static func generateCodeChallenge(from string: String) -> String? {
              guard let data = string.data(using: .utf8) else { return nil }
              let hashed = SHA256.hash(data: data)
              return Data(hashed).pkce_base64EncodedString()
          }
      }
      
      

    private func url() -> URL? {
      switch self {
      case .codeExchange(let code):
        let queryItems = [
          URLQueryItem(name: "client_id", value: NetworkRequest.clientID),
          URLQueryItem(name: "client_secret", value: NetworkRequest.clientSecret),
          URLQueryItem(name: "code", value: code)
        ]
        return urlComponents(host: "btreeadvaaccess-sts-dev.azurewebsites.net", path: "/connect/token", queryItems: queryItems).url
      case .getRepos:
        guard
          let username = NetworkRequest.username,
          !username.isEmpty
        else {
          return nil
        }
        return urlComponents(path: "/users/\(username)/repos", queryItems: nil).url
      case .getUser:
        return urlComponents(path: "/user", queryItems: nil).url
      case .signIn:
        let codeVerifier = PKCE.generateCodeVerifier()
        let codeChallenge = PKCE.generateCodeChallenge(from: codeVerifier)!
        let queryItems = [
          URLQueryItem(name: "client_id", value: NetworkRequest.clientID),
          URLQueryItem(name: "scope", value: NetworkRequest.scope),
          URLQueryItem(name: "redirect_uri", value: NetworkRequest.redirectUri),
          URLQueryItem(name: "response_type", value: responseType),
          URLQueryItem(name: "code_challenge", value: codeChallenge),
          URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod)
        ]

        return urlComponents(host: "btreeadvaaccess-sts-dev.azurewebsites.net", path: "/connect/authorize", queryItems: queryItems).url
      }
    }

    private func urlComponents(host: String = "btreeadvaaccess-sts-dev.azurewebsites.net", path: String, queryItems: [URLQueryItem]?) -> URLComponents {
      switch self {
      default:
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        return urlComponents
      }
    }
  }

  typealias NetworkResult<T: Decodable> = (response: HTTPURLResponse, object: T)

  // MARK: Private Constants
  static let callbackURLScheme = "NoStorage"
  static let clientID = "mobile.advantageredis"
  static let clientSecret = "udTgdj7hFdcvFrtsmPgfry8GsryTjdbd"
  static let scope = "openid profile offline_access political-api advantage-redis-api walkbook-api"
  static let redirectUri = "advantagewalkapp://advantagelogin"
  static let responseType = "code"
  static let codeChallengeMethod = "S256"

  // MARK: Properties
  var method: HTTPMethod
  var url: URL

  // MARK: Static Methods
  static func signOut() {
    Self.accessToken = ""
    Self.refreshToken = ""
    Self.username = ""
  }

  // MARK: Methods
  func start<T: Decodable>(responseType: T.Type, completionHandler: @escaping ((Result<NetworkResult<T>, Error>) -> Void)) {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    if let accessToken = NetworkRequest.accessToken {
      request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    let session = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let response = response as? HTTPURLResponse else {
        DispatchQueue.main.async {
          completionHandler(.failure(RequestError.invalidResponse))
        }
        return
      }
      guard
        error == nil,
        let data = data
      else {
        DispatchQueue.main.async {
          let error = error ?? NetworkRequest.RequestError.otherError
          completionHandler(.failure(error))
        }
        return
      }

      if T.self == String.self, let responseString = String(data: data, encoding: .utf8) {
        let components = responseString.components(separatedBy: "&")
        var dictionary: [String: String] = [:]
        for component in components {
          let itemComponents = component.components(separatedBy: "=")
          if let key = itemComponents.first, let value = itemComponents.last {
            dictionary[key] = value
          }
        }
        DispatchQueue.main.async {
          NetworkRequest.accessToken = dictionary["access_token"]
          NetworkRequest.refreshToken = dictionary["refresh_token"]
          // swiftlint:disable:next force_cast
          completionHandler(.success((response, "Success" as! T)))
        }
        return
      } else if let object = try? JSONDecoder().decode(T.self, from: data) {
        DispatchQueue.main.async {
          if let user = object as? User {
            NetworkRequest.username = user.login
          }
          completionHandler(.success((response, object)))
        }
        return
      } else {
        DispatchQueue.main.async {
          completionHandler(.failure(NetworkRequest.RequestError.otherError))
        }
      }
    }
    session.resume()
  }
}
