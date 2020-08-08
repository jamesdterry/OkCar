//
//  Style.swift
//  OkCar
//
//  Created by James Terry on 8/8/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit

class Style {
    var cachedSmallDetailFont: UIFont?
    var cachedLargeDetailFont: UIFont?
    
    static let sharedInstance = Style()
    
    init()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTextSize(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    func smallDetailFont() -> UIFont
    {
        if let smallDetailFont = cachedSmallDetailFont {
            return smallDetailFont
        }
        
        self.cachedSmallDetailFont = UIFont.preferredFont(forTextStyle: .footnote)
        
        return self.cachedSmallDetailFont!
    }
    
    func largeDetailFont() -> UIFont
    {
        if let largeDetailFont = cachedLargeDetailFont {
            return largeDetailFont
        }
        
        self.cachedLargeDetailFont = UIFont.preferredFont(forTextStyle: .body)
        
        return self.cachedLargeDetailFont!
    }
    
    func smallDetailLineHeight() -> CGFloat
    {
        return smallDetailFont().lineHeight
    }
    
    func largeDetailLineHeight() -> CGFloat
    {
        return largeDetailFont().lineHeight
    }

    @objc func didChangeTextSize(_ notification: NSNotification) {
        cachedSmallDetailFont = nil
        cachedLargeDetailFont = nil
    }
}
