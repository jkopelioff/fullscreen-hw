//
//  FlickrPhoto.swift
//  FullScreenHW
//
//  Created by Joel Kopelioff on 7/28/15.
//  Copyright (c) 2015 Joel Kopelioff. All rights reserved.
//

import Foundation

struct FlickrPhoto
{
    var id:Int!
    var title:String!
    var imageUrl:String!
    var imageWidth:Int!
    var imageHeight:Int!
    var ownerName:String!
    
    init( photoData:NSDictionary )
    {
        self.id = convertToInt(photoData.valueForKey("id"))
        self.title = photoData.valueForKey("title") as? String
        self.imageUrl = photoData.valueForKey("url_n") as? String
        self.imageWidth = convertToInt(photoData.valueForKey("width_n"))
        self.imageHeight = convertToInt(photoData.valueForKey("height_n"))
        self.ownerName = photoData.valueForKey("ownername") as? String
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