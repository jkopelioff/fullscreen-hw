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
    @IBOutlet var searchButton: UIBarButtonItem!
    
    var searchController:UISearchController!
    var searchBar:UISearchBar!
    var refreshControl:UIRefreshControl!

    let kItemSpacing:CGFloat = 10.0
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)

    var photos:[FlickrPhoto]!
    var imageCache:NSCache!
    
    let kPageSize = 20
    var currentPage:Int = 1
    var totalPages:Int!
    var isLoadingMore:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recent"
        
        //Setup CollectionView
        collectionView.delegate  = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clearColor()
        
        
        layout.minimumInteritemSpacing = kItemSpacing
        layout.minimumLineSpacing = kItemSpacing
        
        //Load initial elements
        photos = [FlickrPhoto]()
        FlickrService.recent(1, perPage: 20, completion: didLoadPhotos)
        
        //Add the refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshPhotos", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        
        //Create Cache
        imageCache = NSCache()
        
        //Add Search
        addSearchController()
    }
    
    func addSearchController() {
        //Initialize Search Controller
        
        self.searchController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            controller.automaticallyAdjustsScrollViewInsets = false
            controller.searchResultsUpdater = self
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            
            controller.searchBar.delegate = self
            controller.searchBar.placeholder = "Search"
            controller.searchBar.showsScopeBar = false
            controller.searchBar.sizeToFit()
            controller.searchBar.returnKeyType = UIReturnKeyType.Search
            controller.searchBar.translucent = true
            
            self.searchBar = controller.searchBar
            self.definesPresentationContext = true
            
            return controller
        })()
    }
    
    func refreshPhotos() {
        currentPage = 1
        FlickrService.recent(currentPage, perPage: kPageSize, completion: didLoadPhotos)
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
    
    //- MARK: Actions
    
    @IBAction func searchTapped(sender: AnyObject) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = self.searchBar
        self.searchBar.becomeFirstResponder()
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
        
        cell.idLabel.text = String(photo.id)
        asyncPhotoDownload(photo, imageView: cell.imageView)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == self.photos.count - 1 {
            if ++currentPage <= totalPages {
                isLoadingMore = true
                FlickrService.recent(currentPage, perPage: kPageSize, completion: didLoadPhotos)
            }
        }
    }
}


// MARK: -
// MARK: UICollectionViewDelegateFlowLayout

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout
{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let photo:FlickrPhoto = self.photos[indexPath.row]
        
        if let size = photo.size() {
            return size
        } else {
            return CGSizeMake(100.0, 100.0)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
}

// MARK: -
// MARK: UISearchBarDelegate

extension PhotoCollectionViewController: UISearchBarDelegate
{
    func removeSearchBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = self.searchButton
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        removeSearchBar()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        removeSearchBar()
    }
    
}

// MARK: -
// MARK: UISearchResultsUpdating

extension PhotoCollectionViewController: UISearchResultsUpdating
{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let text = searchController.searchBar.text where count(searchController.searchBar.text) > 0 {
            FlickrService.search(1, perPage: 20, text: text, completion: didLoadPhotos)
        } else  {
            FlickrService.recent(1, perPage: 20, completion: didLoadPhotos)
        }
    }

}


