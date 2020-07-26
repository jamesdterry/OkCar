//
//  UIColor+Extension.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var systemBackgroundPre13: UIColor {
        return self.white
    }
    
    class var labelColorPre13: UIColor {
        return self.black;
    }
    
    class var secondaryLabelColorPre13: UIColor {
        return self.hexColor(0x3c3c4399);
    }
    
    class var linkColorPre13: UIColor {
        return self.hexColor(0x007affff);
    }

    class func hexColor(_ hexColorNumber:UInt32) -> UIColor {
        let red = (hexColorNumber & 0xff000000) >> 24
        let green = (hexColorNumber & 0x00ff0000) >> 16
        let blue = (hexColorNumber & 0x0000ff00) >> 8
        let alpha = (hexColorNumber & 0x000000ff)

        return self.init(red: CGFloat(red) / 255,
                         green: CGFloat(green) / 255,
                         blue: CGFloat(blue) / 255,
                         alpha: CGFloat(alpha) / 255)
    }
        
}
