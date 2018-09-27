//
//  Contact.swift
//  FirebaseChat
//
//  Created by DSPL on 26/09/18.
//  Copyright © 2018 Nirav Hathi. All rights reserved.
//

import Foundation

class Contact {
    private var _name = ""
    private var _id = ""
    private var _email = ""
    
    init(id: String, name: String, email: String) {
        _id = id
        _name = name
        _email = email
    }
    
    var name: String {
        return _name
    }
    
    var id: String {
        return _id
    }
    var email:String {
        return _email
    }
}
