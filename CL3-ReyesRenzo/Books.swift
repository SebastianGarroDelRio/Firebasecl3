//
//  Books.swift
//  CL3-ReyesRenzo
//
//  Created by DAMII on 21/11/23.
//

import UIKit

struct Books: Codable {
    var error:Int
    var title:String
    var subtitle:String
    var authors:String
    var publisher:String
    var language:String
    var isbn10:Int
    var isbn13:Int
    var pages:Int
    var year:Int
    var rating:Int
    var desc:String
    var price:Double
    var image:String
    var url:String
}

