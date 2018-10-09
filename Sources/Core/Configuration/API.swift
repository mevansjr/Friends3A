//
//
//  Secure.swift
//
//  Created by Mark Evans on 2/22/17.
//  Copyright © 2017 3Advance, LLC. All rights reserved.
//

import Foundation

@objc public class API: NSObject {
    
    public var ApiEndpoint = ""
    public var ApiClientId = ""
    public var ApiClientSecret = ""
    
    public static let shared: API = {
        let instance = API()
        return instance
    }()
    
}
