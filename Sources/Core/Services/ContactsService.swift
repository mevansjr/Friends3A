//
//  ContactsService.swift
//  
//
//  Created by Mark Evans on 8/14/17.
//  Copyright © 2017 3Advance, LLC. All rights reserved.
//

import Foundation
import UIKit

public class Contact: NSObject, Mappable {
    var ContactId: String?
    var Organization: String?
    var FirstName: String?
    var LastName: String?
    var FullName: String?
    var PhoneNumber: String?
    var Image: UIImage?
    var IsSelected = false
    var Friend: FriendDetail?

    class func newInstance(_ map: Map) -> Mappable? {
        return Contact()
    }
    public required init?(map: Map){}
    override init(){}

    public func mapping(map: Map) {
        Organization <- map["Organization"]
        FirstName <- map["FirstName"]
        LastName <- map["LastName"]
        FullName <- map["FullName"]
        PhoneNumber <- map["PhoneNumber"]
        Image <- map["Image"]
        IsSelected <- map["IsSelected"]
        Friend <- map["Friend"]
    }
}

typealias CompletionHandler = (_ success: Any?, _ error: NSError?) -> Void
typealias CompletionBoolHandler = (_ success: Bool) -> Void

extension ContactsService {
    func sendFriends(contacts: [FriendDetail], completion: @escaping CompletionHandler) {
        DispatchQueue(label: "background", qos: .background).async {
            self.manager.request(ContactsAPIRouter.sendFriends(contacts))
                .validate(statusCode: 200..<300)
                .responseArray { (response: DataResponse<[FriendDetail]>) in
                    if let rsp = response.result.value {
                        completion(rsp, nil)
                    } else if let error = response.result.error {
                        completion(nil, error.handleError(response: response.response))
                    }
                    else {
                        completion(nil, NSError(domain: ContactsService.DEFAULT_ERROR_MSG, code: ContactsService.DEFAULT_ERROR_CODE, userInfo: nil))
                    }
            }
        }
    }
    
    func requestContacts(completion: @escaping (_ granted: Bool, _ contacts: [Contact]) -> Void) {
        SwiftAddressBook.requestAccessWithCompletion { (granted: Bool, _: CFError?) -> Void in
            DispatchQueue.main.async {
                if granted {
                    self.contacts = self.getContacts()
                }
                completion(granted, self.contacts)
            }
        }
    }

    func getSavedLocalContacts() {
        localSavedContacts = [[String: String]]()
        if let contacts = UserDefaults.standard.value(forKey: "local-saved-contacts") as? [[String: String]] {
            localSavedContacts = contacts
        }
    }

    func saveLocalContacts(friends: [FriendDetail]) {
        getSavedLocalContacts()
        friends.forEach { (friend) in
            if let phone = friend.friendPhoneNumber?.phoneDigits, let name = friend.friendName {
                localSavedContacts.append([phone: name])
            }
        }
        UserDefaults.standard.set(localSavedContacts, forKey: "local-saved-contacts")
        UserDefaults.standard.synchronize()
    }

    private func getAddressBook() -> [SwiftAddressBookPerson] {
        var addressBook = [SwiftAddressBookPerson]()
        guard var addressBookContacts = swiftAddressBook?.allPeople else {
            return addressBook
        }
        addressBookContacts = addressBookContacts.filter({$0.phoneNumbers != nil})
        for person in addressBookContacts {
            if let _ = person.phoneNumbers?.map({$0}) {
                addressBook.append(person)
            }
        }
        return addressBook
    }

    func appendSinglePhoneContacts(array: [Contact]) -> [Contact] {
        var c = [Contact]()
        c = array
        for a in self.getAddressBook() {
            let contact = Contact()
            if let addressOrganization = a.organization {
                if addressOrganization.isNotEmpty  {
                    contact.FullName = addressOrganization
                }
            }
            if let addressBookFullName = a.compositeName {
                if addressBookFullName.isNotEmpty  {
                    contact.FullName = addressBookFullName
                }
            }
            if let addressBookFirstName = a.firstName {
                if addressBookFirstName.isNotEmpty  {
                    contact.FullName = addressBookFirstName
                }
            }
            if let addressBookLastName = a.lastName {
                if let addressBookFirstName = a.firstName {
                    if addressBookFirstName.isNotEmpty && addressBookLastName.isNotEmpty {
                        contact.FullName = "\(addressBookFirstName) \(addressBookLastName)"
                    }
                }
            }
            if let addressBookImage = a.image {
                contact.Image = addressBookImage
            }
            contact.IsSelected = false

            if let name = contact.FullName {
                var phones = [String]()
                if let p = a.phoneNumbers?.map({$0}) {
                    p.forEach({phones.append($0.value.phoneDigits)})
                }
                if phones.count == 1 {
                    let phone = phones[0]
                    if !phone.isEmpty && phone.count >= 10 && phone.count <= 11 {
                        contact.PhoneNumber = phone.formattedNumber
                        contact.ContactId = "\(name)-\(phone.formattedNumber)"
                        c.append(contact)
                    }
                }
            }
        }
        return c
    }

    func appendMultiPhoneContacts(array: [Contact]) -> [Contact] {
        var c = [Contact]()
        c = array
        for a in self.getAddressBook() {
            var phones = [String]()
            if let p = a.phoneNumbers?.map({$0}) {
                p.forEach({phones.append($0.value.phoneDigits)})
            }
            if phones.count > 1 {
                for phone in phones {
                    let contact = Contact()
                    if let addressOrganization = a.organization {
                        if addressOrganization.isNotEmpty  {
                            contact.FullName = addressOrganization
                        }
                    }
                    if let addressBookFullName = a.compositeName {
                        if addressBookFullName.isNotEmpty  {
                            contact.FullName = addressBookFullName
                        }
                    }
                    if let addressBookFirstName = a.firstName {
                        if addressBookFirstName.isNotEmpty  {
                            contact.FullName = addressBookFirstName
                        }
                    }
                    if let addressBookLastName = a.lastName {
                        if let addressBookFirstName = a.firstName {
                            if addressBookFirstName.isNotEmpty && addressBookLastName.isNotEmpty {
                                contact.FullName = "\(addressBookFirstName) \(addressBookLastName)"
                            }
                        }
                    }
                    if let addressBookImage = a.image {
                        contact.Image = addressBookImage
                    }
                    contact.IsSelected = false

                    if let name = contact.FullName {
                        if !phone.isEmpty && phone.count >= 10 && phone.count <= 11 {
                            contact.PhoneNumber = phone.formattedNumber
                            contact.ContactId = "\(name)-\(phone.formattedNumber)"
                            c.append(contact)
                        }
                    }
                }
            }
        }
        return c
    }

    private func getContacts() -> [Contact]  {
        self.contacts.removeAll()
        self.contacts = self.appendSinglePhoneContacts(array: self.contacts)
        self.contacts = self.appendMultiPhoneContacts(array: self.contacts)
        self.contacts = self.contacts.filterDuplicate({$0.ContactId})
        for c in self.contacts {
            print("ContactId: \(c.ContactId!)")
        }
        return self.contacts
    }

    func filterContacts(contacts: [Contact]) -> [Contact]  {
        var contacts = contacts
        contacts = contacts.sorted(by: { (a, b) -> Bool in
            if a.ContactId != nil && b.ContactId != nil {
                return a.ContactId! < b.ContactId!
            }
            return false
        })
        return contacts
    }
}

extension Array {
    func getSelected() -> [Contact] {
        if let contacts = self as? [Contact] {
            return contacts.filter({$0.IsSelected == true})
        }
        return [Contact]()
    }

    var allSectionHeaderLetters: [String] {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    }

    func filteredContactsByHeaderLetter(section: Int, headerLetters: [String]) -> [Contact] {
        let letter = headerLetters[section]
        if let contacts = self as? [Contact] {
            let array = contacts.filter({ (y) -> Bool in
                var name = ""
                if y.ContactId != nil && !y.ContactId!.isEmpty {
                    name = y.ContactId!
                }
                let title = name
                if !title.isEmpty {
                    var l = String(title[title.index(title.startIndex, offsetBy: 0)])
                    if !l.isAlphaOnly() {
                        l = "#"
                    }
                    return l.lowercased() == letter.lowercased()
                }
                return false
            })
            return array
        }
        return [Contact]()
    }

    func getAlphaHeaderLetters() -> [String] {
        var array = [String]()
        if let contacts = self as? [Contact] {
            for contact in contacts {
                var name = ""
                if contact.ContactId != nil {
                    name = contact.ContactId!
                }
                let title = name

                if !title.isEmpty {
                    let firstLetter = String(title[title.index(title.startIndex, offsetBy: 0)])
                    if firstLetter.isAlphaOnly() {
                        array.append(firstLetter.uppercased())
                    }
                }
            }
            array = uniq(source: array)
            array.sort { (x, y) -> Bool in
                return x < y
            }
            return array
        }
        return array
    }

    func getNonAlphaHeaderLetters() -> [String] {
        var array = [String]()
        if let contacts = self as? [Contact] {
            for contact in contacts {
                var name = ""
                if contact.ContactId != nil {
                    name = contact.ContactId!
                }
                let title = name

                if !title.isEmpty {
                    let firstLetter = String(title[title.index(title.startIndex, offsetBy: 0)])
                    if !firstLetter.isAlphaOnly() {
                        array.append("#")
                    }
                }
            }
            array = uniq(source: array)
            array.sort { (x, y) -> Bool in
                return x < y
            }
            return array
        }
        return array
    }
}

extension Array {
    func filterDuplicate<T>(_ keyValue:(Element)->T) -> [Element]
    {
        var uniqueKeys = Set<String>()
        return filter{uniqueKeys.insert("\(keyValue($0))").inserted}
    }
}


extension String {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }

    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    func isAlphaNumeric() -> Bool {
        let uc = NSCharacterSet.alphanumerics.inverted
        return self.rangeOfCharacter(from: uc) == nil
    }

    func isAlphaOnly() -> Bool {
        let alphaSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let uc = alphaSet.inverted
        return self.rangeOfCharacter(from: uc) == nil
    }

    var phoneDigits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    var formattedNumber: String {
        var phoneNumber = self.phoneDigits
        let mask = "XXX-XXX-XXXX"
        switch phoneNumber.count {
        case 11:
            phoneNumber.removeFirst()
        case 12:
            phoneNumber.removeFirst()
            phoneNumber.removeFirst()
        default:
            print("")
        }
        if phoneNumber.count > 10 {
            return ""
        }
        var result = ""
        var index = phoneNumber.startIndex
        mask.forEach({
            if index != phoneNumber.endIndex {
                if $0 == "X" {
                    result.append(phoneNumber[index])
                    index = phoneNumber.index(after: index)
                }
                else {
                    result.append($0)
                }
            }
        })
        return result
    }
}

func uniq<S: Sequence, E: Hashable>(source: S) -> [E] where E==S.Iterator.Element {
    var seen: [E:Bool] = [:]
    return source.filter { seen.updateValue(true, forKey: $0) == nil }
}
