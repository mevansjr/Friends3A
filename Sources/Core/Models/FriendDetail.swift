//
// FriendDetail.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public class FriendDetail: NSObject, Mappable {

    public enum FriendStatus: String { 
        case declined = "declined"
        case pending = "pending"
        case accepted = "accepted"
    }
    var friendId: Int?
    var friendName: String?
    var friendPhoneCountryCode: String?
    var friendPhoneNumber: String?
    var friendProfileImageUri: String?
    var friendStatus: String?
    var friendUserId: Int?
    var userId: Int?
    var isAwaitingInvitation: Bool = false
    var numFriend: Int?

    public class func newInstance(_ map: Map) -> Mappable? {
        return FriendDetail()
    }
    required public init?(map: Map){}
    override init(){}

    public func mapping(map: Map) { 
        friendId <- map["FriendId"]
        friendName <- map["FriendName"]
        friendPhoneCountryCode <- map["FriendPhoneCountryCode"]
        friendPhoneNumber <- map["FriendPhoneNumber"]
        friendProfileImageUri <- map["FriendProfileImageUri"]
        friendStatus <- map["FriendStatus"]
        friendUserId <- map["FriendUserId"]
        userId <- map["UserId"]
        isAwaitingInvitation <- map["IsAwaitingInvitation"]
        numFriend <- map["NumFriends"]
    }
}

extension FriendDetail {
    var emptyFindName: String? {
        if let key = self.friendPhoneNumber {
            ContactsService.shared.getSavedLocalContacts()
            if let object = ContactsService.shared.localSavedContacts.filter({$0[key] != nil}).last, let name = object[key], name.isNotEmpty {
                return name
            }
        }
        return nil
    }
}

extension Array {
    func sendContacts() -> [FriendDetail] {
        if let contacts = self as? [Contact] {
            var friends = [FriendDetail]()
            contacts.forEach({ (contact) in
                let friend = FriendDetail()
                friend.friendPhoneCountryCode = "+1"
                friend.friendPhoneNumber = contact.PhoneNumber?.phoneDigits
                friend.friendName = contact.FullName
                friends.append(friend)
            })
            return friends
        }
        return [FriendDetail]()
    }
    
    func textMessageFriends() -> [FriendDetail] {
        if let friends = self as? [FriendDetail] {
            return friends.filter({$0.friendUserId != nil})
        }
        return [FriendDetail]()
    }
}

