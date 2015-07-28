//
//  ViewController.swift
//  FullScreenHW
//
//  Created by Joel Kopelioff on 7/27/15.
//  Copyright (c) 2015 Joel Kopelioff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    
    
    
}

