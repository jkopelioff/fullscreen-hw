//
//  FlickrPhoto.swift
//  FullScreenHW
//
//  Created by Joel Kopelioff on 7/28/15.
//  Copyright (c) 2015 Joel Kopelioff. All rights reserved.
//

import UIKit

enum FlickrPhotoType:String {
    case Photo = "photo"
    case Video = "video"
}

struct FlickrPhoto
{
    var id:Int!
    var title:String!
    var imageUrl:String!
    var imageWidth:Int!
    var imageHeight:Int!
    var type:FlickrPhotoType!
    var ownerName:String!
    
    init( photoData:NSDictionary )
    {
        self.id = convertToInt(photoData.valueForKey("id"))
        self.title = photoData.valueForKey("title") as? String
        self.imageUrl = photoData.valueForKey("url_n") as? String
        self.imageWidth = convertToInt(photoData.valueForKey("width_n"))
        self.imageHeight = convertToInt(photoData.valueForKey("height_n"))
        self.type = FlickrPhotoType(rawValue: photoData.valueForKey("media") as! String)
        self.ownerName = photoData.valueForKey("ownername") as? String
    }
    
    
    func size() -> CGSize?
    {
        if self.imageHeight != nil && self.imageWidth != nil {
            return CGSizeMake(CGFloat(self.imageWidth/2), CGFloat(self.imageHeight/2))
        } else {
            return nil
        }
    }
    
    
    private func convertToInt(value:AnyObject?) -> Int?
    {
        if value is NSNumber {
            return value as? Int
        }
        
        if value is NSString {
            return (value as! String).toInt()
        }
        
        return nil
    }
}