//
//  WalkthroughContentViewController.swift
//  InstagramClone
//
//  Created by DUYET on 5/11/17.
//  Copyright © 2017 The Zero2Launch Team. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var forwardBtn: UIButton!
    
    var index = 0
    var imageFileName = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentLbl.text = content
        backgroundImg.image = UIImage(named: imageFileName)
        
        pageControl.currentPage = index
        switch index {
        case 0...1:
            forwardBtn.setImage(UIImage(named: "arrow.png"), for: UIControlState.normal)
        case 2:
            forwardBtn.setImage(UIImage(named: "doneIcon.png"), for: UIControlState.normal)
        default:
            break
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        switch index {
        case 0...1:
            let pageVC = parent as! WalkthroughViewController
            pageVC.forward(index: index)
        case 2:
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            
            dismiss(animated: true, completion: nil)
        default:
            print("")
        }
    }
   }
