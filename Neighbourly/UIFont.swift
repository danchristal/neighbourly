//
//  UIFont.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-11-02.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import Foundation
extension UIFont {
    class var navbarTitleFont: UIFont
    {
        return UIFont(name: "AmaticSC-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
    }
}
