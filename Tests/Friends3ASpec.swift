//
//  Friends3ASpec.swift
//  Friends3A
//
//  Created by Mark Evans on 04/10/16.
//  Copyright © 2017 3Advance. All rights reserved.
//

import Quick
import Nimble
@testable import Friends3A

class Friends3ASpec: QuickSpec {

    override func spec() {

        describe("Friends3ASpec") {
            it("works") {
                expect(Friends3A.name) == "Friends3A"
            }
        }

    }

}
