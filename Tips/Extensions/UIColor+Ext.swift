//
//  UIColor+Ext.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        var formattedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove leading "#" if present
        if formattedString.hasPrefix("#") {
            formattedString.remove(at: formattedString.startIndex)
        }
        
        // Check if the string has a valid length
        guard formattedString.count == 6 else {
            self.init(white: 1.0, alpha: 1.0) // Return white color if invalid hex string
            return
        }
        
        // Separate RGB components
        var rgb: UInt64 = 0
        Scanner(string: formattedString).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


