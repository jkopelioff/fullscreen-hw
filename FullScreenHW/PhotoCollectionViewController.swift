//
//  PhotoCollectionViewController.swift
//  FullScreenHW
//
//  Created by Joel Kopelioff on 7/27/15.
//  Copyright (c) 2015 Joel Kopelioff. All rights reserved.
//

import UIKit

class PhotoCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    let kItemSpacing:CGFloat = 8.0
    
    var refreshControl:UIRefreshControl!
    var photos:[FlickrPhoto]!
    var imageCache:NSCache!
    
    
    let kPageSize = 20
    var currentPage:Int = 1
    var totalPages:Int!
    var isLoadingMore:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.delegate  = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        
        layout.minimumInteritemSpacing = kItemSpacing
        layout.minimumLineSpacing = kItemSpacing
        
        photos = [FlickrPhoto]()
        FlickrService.loadRecent(1, perPage: 20, completion: didLoadPhotos)
        
        //Add the refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshPhotos", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        
        imageCache = NSCache()
    }
    
    func refreshPhotos() {
        currentPage = 1
        FlickrService.loadRecent(currentPage, perPage: kPageSize, completion: didLoadPhotos)
    }
    
    func didLoadPhotos(photos:[FlickrPhoto]?, totalPages:Int, error:NSError?) {
        if error == nil && photos != nil {
            if isLoadingMore {
                self.photos = self.photos + photos!
            } else {
                self.photos = photos
            }
            self.totalPages = totalPages
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.reloadData()
            })
        }
        //TODO: Report error to the user.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl.endRefreshing()
            self.isLoadingMore = false
        })
    }
    
    //- MARK: Async Image loading
    
    func asyncPhotoDownload(photo:FlickrPhoto, imageView:UIImageView) {
        
        if photo.imageUrl == nil { return }
        
        if let image = imageCache.objectForKey(photo.id) as? UIImage {
            imageView.image = image
            return
        }
        
        let queue = dispatch_queue_create("com.Flickr.photoDownload", nil)
        
        dispatch_async(queue) { () -> Void in
            
            var data = NSData(contentsOfURL: NSURL(string: photo.imageUrl!)!)
            
            var image:UIImage?
            if data != nil {
                image = UIImage(data: data!)!
                self.imageCache.setObject(image!, forKey: photo.id)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                imageView.image = image!
            }
        }
        
    }

}

// MARK: -
// MARK: UICollectionViewDataSource

extension PhotoCollectionViewController: UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:PhotoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photo:FlickrPhoto = self.photos[indexPath.row]
        
        cell.titleLabel.text = photo.title
        asyncPhotoDownload(photo, imageView: cell.imageView)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == self.photos.count - 1 {
            if ++currentPage <= totalPages {
                isLoadingMore = true
                FlickrService.loadRecent(currentPage, perPage: kPageSize, completion: didLoadPhotos)
            }
        }
    }
}


// MARK: -
// MARK: UICollectionViewDelegateFlowLayout

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout
{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let maxWidth:CGFloat = self.collectionView.frame.width/2 - (2 * kItemSpacing)
       
        return CGSizeMake(maxWidth, maxWidth)
        
        
    }
    
    
}

