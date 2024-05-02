//
//  tip.swift
//  Tips
//
//  Created by Denis Yaremenko on 01.04.2024.
//

import Foundation

enum Tip {
    case none
    case ten
    case fifteen
    case twenty
    case custom(value: Int)
    
    var stringValue: String {
        switch self {
        case .none: ""
        case .ten: "10%"
        case .fifteen: "15%"
        case .twenty: "20%"
        case .custom(value: let value): String(value)
        }
    }
}

