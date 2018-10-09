//
//  ClientService.swift
//
//
//  Created by Mark Evans on 12/17/15.
//  Copyright © 2015 3Advance, LLC. All rights reserved.
//

import Foundation

public class ContactsService {

    // MARK: Properties

    public var manager = SessionManager()
    public var contacts = [Contact]()
    public var localSavedContacts = [[String: String]]()

    public typealias CompletionHandler = (_ success: Any?, _ error: NSError?) -> Void
    public typealias CompletionBoolHandler = (_ success: Bool) -> Void

    public static let DEFAULT_ERROR_CODE = 500
    public static let DEFAULT_ERROR_MSG = "There was a problem accessing the server. If this continues, please let us know."

    // MARK: Shared Instance

    public static let shared: ContactsService = {
        let instance = ContactsService()
        instance.setupManager()
        instance.contacts = [Contact]()
        return instance
    }()

    // MARK: Setup Methods

    public func setupManager() {
        let configuration = URLSessionConfiguration.default
        self.manager = SessionManager(configuration: configuration)
    }
}

public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return self.localizedDescription }

    public func handleError() -> NSError {
        return handleError(response: nil)
    }

    public func handleError(response: HTTPURLResponse?) -> NSError {
        var message = ""
        var status = self.code
        if let messageResponse = response?.allHeaderFields["Message"] as? String, !messageResponse.isEmpty, let statusCode = response?.statusCode {
            message = messageResponse
            status = statusCode
        }
        else if let messageResponse = response?.allHeaderFields["message"] as? String, !messageResponse.isEmpty, let statusCode = response?.statusCode {
            message = messageResponse
            status = statusCode
        }
        else {
            message = "There was a problem accessing the server. If this continues, please let us know."
            status = 500
        }
        if self.domain.contains("401") { status = 401 }
        return NSError(domain: message, code: status, userInfo: nil)
    }
}
