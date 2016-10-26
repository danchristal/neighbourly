//
//  JSONAble.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-25.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import Foundation

protocol JSONAble {
    func toJSON() -> [String:Any]
}

extension JSONAble{
    
    func toJSON() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}
