//
//
//  Secure.swift
//
//  Created by Mark Evans on 2/22/17.
//  Copyright © 2017 3Advance, LLC. All rights reserved.
//

import Foundation
import OAuth3A

@objc public class Secure: NSObject {
    
    #if Live
    let ApiEndpoint = "https://<Enter Production API Endpoint>"
    let ApiClientId = "<Enter Production Client ID>"
    let ApiClientSecret = "<Enter Production Client Secret>"
    #elseif Stage
    let ApiEndpoint = "https://<Enter Beta API Endpoint>"
    let ApiClientId = "<Enter Beta Client ID>"
    let ApiClientSecret = "<Enter Beta Client Secret>"
    #elseif Dev
    let ApiEndpoint = "https://<Enter Alpha API Endpoint>"
    let ApiClientId = "<Enter Alpha Client ID>"
    let ApiClientSecret = "<Enter Alpha Client Secret>"
    #endif
    
    static let shared: Secure = {
        let instance = Secure()
        return instance
    }()

    func start() {
        API.shared.ApiEndpoint = Secure.shared.ApiEndpoint
        API.shared.ApiClientId = Secure.shared.ApiClientId
        API.shared.ApiClientSecret = Secure.shared.ApiClientSecret
        #if Stage
        debugLog()
        #elseif Dev
        debugLog()
        #endif
    }

    private func debugLog() {
        print("\n******************************************************************")
        print(">> OAuth3A Module")
        print("******************************************************************")
        print(">> ApiEndpoint: \(API.shared.ApiEndpoint)")
        print(">> ApiClientId: \(API.shared.ApiClientId)")
        print(">> ApiClientSecret: \(API.shared.ApiClientSecret)")
        print("******************************************************************\n")
    }
    
}
