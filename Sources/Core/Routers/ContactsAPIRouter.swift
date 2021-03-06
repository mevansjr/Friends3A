//
// ContactsAPIRouter.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

enum ContactsAPIRouter: URLRequestConvertible {
    case sendFriends([FriendDetail])

    static let baseURLString = API.shared.ApiEndpoint

    var method: HTTPMethod {
        switch self { 
        case .sendFriends:
                return .post
        }
    }

    var path: String {
        switch self { 
        case .sendFriends:
                let path = "/me/friends"
                return path
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try ContactsAPIRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self { 
        case .sendFriends(let friends):
            var parameters = [[String: Any]]()
            if friends.count > 0 {
                for f in friends {
                    var friend = [String: Any]()
                    if let countryCode = f.friendPhoneCountryCode {
                        friend["FriendPhoneCountryCode"] = countryCode
                    }
                    if let phoneNumber = f.friendPhoneNumber {
                        friend["FriendPhoneNumber"] = phoneNumber
                    }
                    if let fullName = f.friendName {
                        friend["FriendName"] = fullName
                    }
                    parameters.append(friend)
                }
            }
            urlRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: parameters)

        }
        return urlRequest
    }
}


