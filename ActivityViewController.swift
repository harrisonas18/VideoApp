//
//  ActivityViewController.swift
//  InstagramClone
//
//  Created by The Zero2Launch Team on 12/4/16.
//  Copyright © 2016 The Zero2Launch Team. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [Notification]()
    var users = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotifications()
    }
    
    func loadNotifications() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.Notification.observeNotification(withId: currentUser.uid , completion: {
            notification in
            guard let uid = notification.from else {
                return
            }
            self.fetchUser(uid: uid, completed: {
                self.notifications.insert(notification, at: 0)
                self.tableView.reloadData()
            })
        })
    }
    
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Activity_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender  as! String
            detailVC.postId = postId
        }
        if segue.identifier == "Activity_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Activity_CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender  as! String
            commentVC.postId = postId
        }
    }
}

extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notification = notification
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension ActivityViewController: ActivityTableViewCellDelegate {
    
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Activity_DetailSegue", sender: postId)
    }
    
    func goToProfileVC(userId: String) {
        performSegue(withIdentifier: "Activity_ProfileSegue", sender: userId)
    }
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "Activity_CommentSegue", sender: postId)
    }
    
}
