//
//  HashTagViewController.swift
//  InstagramClone
//
//  Created by The Zero2Launch Team on 3/30/17.
//  Copyright © 2017 The Zero2Launch Team. All rights reserved.
//

import UIKit

class HashTagViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [Post] = []
    var tag = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(tag)"
        collectionView.dataSource = self
        collectionView.delegate = self
        loadPosts()
    }
    
    func loadPosts() {
        Api.HashTag.fetchPosts(withTag: tag) { (postId) in
            Api.Post.observePost(withId: postId, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "HashTag_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender  as! String
            detailVC.postId = postId
        }
    }
}

extension HashTagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
}

extension HashTagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}

extension HashTagViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "HashTag_DetailSegue", sender: postId)
    }
}


