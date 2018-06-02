//
//  FeedApi.swift
//  InstagramClone
//
//  Created by The Zero2Launch Team on 2/1/17.
//  Copyright © 2017 The Zero2Launch Team. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FeedApi {
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeFeed(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func getRecentFeed(withId id: String, start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([(Post, UserModel)]) -> Void) {
        
        var feedQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp")
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            feedQuery = feedQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: "timestamp").queryLimited(toLast: limit)
        } else {
            feedQuery = feedQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        feedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects
            let myGroup = DispatchGroup()
       
            
            var results: [(post: Post, user: UserModel)] = []

            for (index, item) in (items as! [DataSnapshot]).enumerated() {
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        results.insert((post, user), at: index)
                        print(index)
                        myGroup.leave()
                    })
                })
            }
            myGroup.notify(queue: .main) {
                results.sort(by: {$0.0.timestamp! > $1.0.timestamp! })
                completionHandler(results)
            }
            
            
        })
        
    }
    
    func getOldFeed(withId id: String, start timestamp: Int, limit: UInt, completionHandler: @escaping ([(Post, UserModel)]) -> Void) {
        
        let feedOrderQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp")
        let feedLimitedQuery = feedOrderQuery.queryEnding(atValue: timestamp - 1, childKey: "timestamp").queryLimited(toLast: limit)

        feedLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
         
            let myGroup = DispatchGroup()
            
            var results: [(post: Post, user: UserModel)] = []

            for (index, item) in items.enumerated() {
                print(item)

                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        results.insert((post, user), at: index)
                        myGroup.leave()
                    })
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: {
                results.sort(by: {$0.0.timestamp! > $1.0.timestamp! })
                completionHandler(results)
            })
        })
        
    }
    
    func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
