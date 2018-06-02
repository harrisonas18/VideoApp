//
//  HomeViewController.swift
//  InstagramClone
//
//  Created by The Zero2Launch Team on 12/4/16.
//  Copyright © 2016 The Zero2Launch Team. All rights reserved.
//
    
import UIKit
import SDWebImage
class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    fileprivate var isLoadingPost = false
    var refreshControl = UIRefreshControl()

    var posts = [Post]()
    var users = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        activityIndicatorView.startAnimating()
        loadPosts()
    }
    
    @objc func refresh() {
        self.posts.removeAll()
        self.users.removeAll()
        loadPosts()
    }
    
    func loadPosts() {
        isLoadingPost = true
        Api.Feed.getRecentFeed(withId: Api.User.CURRENT_USER!.uid, start: posts.first?.timestamp, limit: 3  ) { (results) in
            if results.count > 0 {
                results.forEach({ (result) in
                    self.posts.append(result.0)
                    self.users.append(result.1)
                })
            }
            self.isLoadingPost = false
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
            //self.displayNewPosts(newPosts: self.posts)
        }
//        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
//            guard let postUid = post.uid else {
//                return
//            }
//            self.fetchUser(uid: postUid, completed: {
//                self.posts.insert(post, at: 0)
//                self.tableView.reloadData()
//            })
//        }
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id }
            self.users = self.users.filter { $0.id != post.uid }
            
            self.tableView.reloadData()
        }
    }
    private func displayNewPosts(newPosts posts: [Post]) {
        guard posts.count > 0 else {
            return
        }        
        var indexPaths:[IndexPath] = []
        self.tableView.beginUpdates()
        for post in 0...(posts.count - 1) {
            let indexPath = IndexPath(row: post, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
    }
    
//    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
//        Api.User.observeUser(withId: uid, completion: {
//            user in
//            self.users.insert(user, at: 0)
//            completed()
//        })
//
//    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender  as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender  as! String
            hashTagVC.tag = tag
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 0
        }
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        if posts.isEmpty {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        // We want to trigger the loading when the user reaches the last two rows
//        guard !isLoadingPost, self.posts.count - indexPath.row == 2 else {
//            return
//        }
//
//        isLoadingPost = true
//
//        guard let lastPostTimestamp = self.posts.last?.timestamp else {
//            isLoadingPost = false
//            return
//        }
//        Api.Feed.getOldPosts(withId: Api.User.CURRENT_USER!.uid, start: lastPostTimestamp, limit: 3) { (results) in
//            var indexPaths:[IndexPath] = []
//            self.tableView.beginUpdates()
//            for result in results {
//                self.posts.append(result.0)
//                self.users.append(result.1)
//                let indexPath = IndexPath(row: self.posts.count - 1, section: 0)
//                indexPaths.append(indexPath)
//            }
//            self.tableView.insertRows(at: indexPaths, with: .none)
//            self.tableView.endUpdates()
//            self.isLoadingPost = false
//        }
//
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
           
            guard !isLoadingPost else {
                return
            }
            isLoadingPost = true

            guard let lastPostTimestamp = self.posts.last?.timestamp else {
                isLoadingPost = false
                return
            }
            Api.Feed.getOldFeed(withId: Api.User.CURRENT_USER!.uid, start: lastPostTimestamp, limit: 3) { (results) in
                if results.count == 0 {
                    return
                }
                for result in results {
                    self.posts.append(result.0)
                    self.users.append(result.1)
                }
                self.tableView.reloadData()

                self.isLoadingPost = false
            }

        }
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}
