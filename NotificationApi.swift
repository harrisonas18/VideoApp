//
//  NotificationApi.swift
//  InstagramClone
//
//  Created by mac on 4/6/17.
//  Copyright © 2017 The Zero2Launch Team. All rights reserved.
//

import Foundation
import FirebaseDatabase
class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    func observeNotification(withId  id: String, completion: @escaping (Notification) -> Void) {
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                print(dict)
                let newNoti = Notification.transform(dict: dict, key: snapshot.key)
                completion(newNoti)
            }
        })
    }

}
