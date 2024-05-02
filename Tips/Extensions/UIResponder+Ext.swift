//
//  UIResponder+Ext.swift
//  Tips
//
//  Created by Denis Yaremenko on 02.04.2024.
//

import UIKit

extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
