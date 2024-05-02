//
//  Double+Ext.swift
//  Tips
//
//  Created by Denis Yaremenko on 03.04.2024.
//

import Foundation

extension Double {
    var currencyFormatter: String {
        var isWholeNumber: Bool {
            isZero ? true : !isNormal ? false: self == rounded()
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = isWholeNumber ? .zero : 2
        
        return formatter.string(for: self) ?? ""
    }
}
