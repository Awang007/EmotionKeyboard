//
//  UIColor+category.swift
//  AWXinLangWeiBo
//
//  Created by 125154454 on 17/1/2.
//  Copyright © 2017年 aWangLong. All rights reserved.
//

import UIKit

extension  UIColor {

    class func randomColor() -> UIColor{
    
        return UIColor(red: random_Number(), green: random_Number(), blue: random_Number(), alpha: 1)
    }
    
    private class func random_Number() -> CGFloat{
    
        let random = arc4random_uniform(256)
        return CGFloat( CGFloat(random) / CGFloat(255))
    }
}
