//
//  DiscoverViewController.swift
//  InstagramClone
//
//  Created by The Zero2Launch Team on 12/4/16.
//  Copyright © 2016 The Zero2Launch Team. All rights reserved.
//

import UIKit
import Firebase
class DiscoverViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    var users: [UserModel] = []
    var numberOfItemsInSection = 0
    var isLoadingPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handlePagination()
        //collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:
            .plain, target: nil, action: nil)
        collectionView.alwaysBounceVertical = true
        // Set the PinterestLayout delegate
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
    }
    
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        //loadTopPosts()
    }
    
    var startKey: String!
    var donePaginating = false
    
    func handlePagination()
    {
        /*
         querying the first 12 messages in the database
         if the start key is equal to nil this part of the code will be executed and set the last key id to the start key to fetch the following messages
         */
        let ref = Database.database().reference(withPath:"posts").queryOrderedByKey()
        
        if startKey == nil {
            ref.queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { snapshot in
                guard let children = snapshot.children.allObjects.last as? DataSnapshot else {return}
                
                if snapshot.childrenCount > 0 {
                    for child in snapshot.children.allObjects as![DataSnapshot]
                    {
                        guard let dictionary = child.value as? [String:Any] else {return}
                        self.posts.append(Post.transformPostPhoto(dict: dictionary, key: child.key ))
                    }
                    self.numberOfItemsInSection = self.posts.count
                    self.startKey = children.key
                    self.collectionView?.reloadData()
                }
            })
        }
            /* start key
             starting to query data the value of the last key id of  of the first  12
             and inserting in the proper place... base on the feed count
             */
        else {
            ref.queryStarting(atValue:startKey).queryLimited(toFirst: 6).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let children = snapshot.children.allObjects.last as? DataSnapshot else { return}
                
                if (snapshot.childrenCount == 6) {
                    for child in snapshot.children.allObjects as![DataSnapshot]
                    {
                        if child.key != self.startKey{
                            guard let dictionary = child.value as? [String:Any] else {return}
                            self.posts.insert(Post.transformPostPhoto(dict: dictionary, key: child.key), at: self.posts.count)
                        }
                    }
                    self.startKey = children.key
                    self.collectionView?.reloadData()
                } else if (snapshot.childrenCount > 0) {
                    for child in snapshot.children.allObjects as![DataSnapshot]
                    {
                        if child.key != self.startKey{
                            guard let dictionary = child.value as? [String:Any] else {return}
                            self.posts.insert(Post.transformPostPhoto(dict: dictionary, key: child.key), at: self.posts.count)
                        }
                    }
                    self.startKey = children.key
                    self.collectionView?.reloadData()
                    self.donePaginating = true
                } else {
                    return
                }
            })
            
        }// end of else of start key
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender  as! String
            detailVC.postId = postId
        }
    }
    
    

}//end of class

extension DiscoverViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self

        return cell
    }
}
//MARK: - PINTEREST LAYOUT DELEGATE
extension DiscoverViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {

        return (375 / posts[indexPath.item].ratio!) / 2
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == numberOfItemsInSection-1 && donePaginating == false) {
            print("will display called")
            handlePagination()
            
            numberOfItemsInSection=posts.count
        } else {
            return
        }
    }
}

extension DiscoverViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
        //return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    
}

extension DiscoverViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
    
}

