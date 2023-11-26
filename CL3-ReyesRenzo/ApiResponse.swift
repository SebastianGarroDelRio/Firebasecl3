//
//  ApiResponse.swift
//  CL3-ReyesRenzo
//
//  Created by DAMII on 20/11/23.
//

import UIKit

struct ApiResponse : Decodable {

    var error:String
    var total:String
    var page:String
    var books:[Libro]
    
}
