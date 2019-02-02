//
//  Extensions.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

extension UIView {
    
    func anchor( top: NSLayoutYAxisAnchor?, paddingTop: CGFloat?,
                 left: NSLayoutXAxisAnchor?, paddingLeft: CGFloat?,
                 right: NSLayoutXAxisAnchor?, paddingRight: CGFloat?,
                 bottom: NSLayoutYAxisAnchor?, paddingBottom: CGFloat?,
                 width: CGFloat?,
                 height: CGFloat?) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
        if let left = left  {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft!).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight!).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom!).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
    }
    
}

