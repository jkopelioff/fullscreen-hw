//
//  FlickrService.swift
//  FullScreenHW
//
//  Created by Joel Kopelioff on 7/28/15.
//  Copyright (c) 2015 Joel Kopelioff. All rights reserved.
//

import Foundation

enum FlickrServiceMethod:String {
    case Recent = "flickr.photos.getRecent"
    case Search = "flickr.photos.search"
    
}

class FlickrService {
    
    static func recent(page:Int, perPage:Int, completion: (photos: [FlickrPhoto]?, totalPages:Int, error:NSError?) -> Void)
    {
        makeRequest(FlickrServiceMethod.Recent, page: page, perPage: perPage, text: nil, completion: completion)
    }
    
    static func search(page:Int, perPage:Int, text:String, completion: (photos: [FlickrPhoto]?, totalPages:Int, error:NSError?) -> Void)
    {
        makeRequest(FlickrServiceMethod.Search, page: page, perPage: perPage, text:text, completion: completion)
    }
    
    static func makeRequest(method:FlickrServiceMethod, page:Int, perPage:Int, text:String?, completion: (photos: [FlickrPhoto]?, totalPages:Int, error:NSError?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        var params:String = "?method=\(method.rawValue)&api_key=\(kFlickrKey)&extras=url_n,owner_name,media&per_page=\(perPage)&page=\(page)&format=json&nojsoncallback=1"
        
        if text != nil {
            // TODO: Validate incoming text to not contain malicious characters.
            params += "&text=" + text!
        }
        
        
        if let flickrUrl = NSURL(string: kFlickrUrl + params) {
            
            var task = session.dataTaskWithURL(flickrUrl) {
                (data, response, error) -> Void in
                
                if error != nil {
                    NSLog("Error in response: %@", error.localizedDescription)
                    completion(photos: nil, totalPages: 0, error: error)
                } else  {
                    var jsonError:NSError?
                    let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
                    
                    if let jsonDict = json as? NSDictionary where jsonError == nil {
                        
                        let total = jsonDict.valueForKeyPath("photos.pages") as? NSNumber
                        var flickrPhotos = [FlickrPhoto]()
                        
                        if let photos = jsonDict.valueForKeyPath("photos.photo") as? NSArray {
                            
                            for photo in photos {
                                let photo = FlickrPhoto(photoData: photo as! NSDictionary)
                                flickrPhotos.append(photo)
                            }
                        }
                        
                        completion(photos: flickrPhotos, totalPages: total!.integerValue, error: nil)
                    } else if jsonError != nil {
                        NSLog("Error with JSON: %@", jsonError!.localizedDescription)
                        completion(photos: nil, totalPages: 0, error: error)
                    }
                }
            }
            
            task.resume()
            
        } else {
            NSLog("Error with Flickr URL: %@", kFlickrUrl + params)
            completion(photos: nil, totalPages: 0, error: nil)
        }
        
        
    }
}