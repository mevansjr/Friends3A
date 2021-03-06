//
//  ViewController.swift
//  Demo
//
//  Created by Mark Evans on 10/8/18.
//  Copyright © 2018 Mark Evans. All rights reserved.
//

import UIKit
import Friends3A

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ContactsService.shared.requestContacts { (condition, contacts) in
            print("\(condition ? "Allowed Contacts Access": "NOT ALLOWED Contacts Access")")
            if let json = contacts.toJSONString(prettyPrint: true) {
                print("contacts: \(json)")
            }
        }
    }
}

