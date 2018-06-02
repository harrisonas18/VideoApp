//
//  User.swift
//  InstagramClone
//
//  Created by The Zero2Launch Team on 12/30/16.
//  Copyright © 2016 The Zero2Launch Team. All rights reserved.
//

import Foundation
class UserModel {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.id = key
        return user
    }
}
