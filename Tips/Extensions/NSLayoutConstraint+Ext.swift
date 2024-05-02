//
//  NSLayoutConstraint+Ext.swift
//  Tips
//
//  Created by Denis Yaremenko on 01.04.2024.
//

import UIKit

public struct LayoutDirection: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let top = LayoutDirection(rawValue: 1 << 0)
    public static let bottom = LayoutDirection(rawValue: 1 << 1)
    public static let leading = LayoutDirection(rawValue: 1 << 2)
    public static let trailing = LayoutDirection(rawValue: 1 << 3)
    
    public static let horizontal: LayoutDirection = [.leading, .trailing]
    public static let vertical: LayoutDirection = [.top, .bottom]
    
    public static let all: LayoutDirection = [.horizontal, .vertical]
}

public extension UILayoutPriority {
    static var almostRequired: UILayoutPriority {
        return .required - 1
    }
    
    static var almostNone: UILayoutPriority {
        return .init(1)
    }
}

public extension NSLayoutConstraint {
    func withPriority(_ new: UILayoutPriority) -> NSLayoutConstraint {
        priority = new
        return self
    }
    
    func activate() {
        isActive = true
    }
    
    func deactivate() {
        isActive = false
    }
}

public extension UIView {
    func setContentHuggingPriorities(_ new: UILayoutPriority) {
        setContentHuggingPriority(new, for: .horizontal)
        setContentHuggingPriority(new, for: .vertical)
    }
    
    func setContentCompressionResistancePriorities(_ new: UILayoutPriority) {
        setContentCompressionResistancePriority(new, for: .horizontal)
        setContentCompressionResistancePriority(new, for: .vertical)
    }
    
    func constraints(equalTo other: UIView, directions: LayoutDirection = .all,
                     priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if directions.contains(.top) {
            constraints.append(topAnchor.constraint(equalTo: other.topAnchor).withPriority(priority))
        }
        if directions.contains(.leading) {
            constraints.append(leadingAnchor.constraint(equalTo: other.leadingAnchor).withPriority(priority))
        }
        if directions.contains(.bottom) {
            constraints.append(bottomAnchor.constraint(equalTo: other.bottomAnchor).withPriority(priority))
        }
        if directions.contains(.trailing) {
            constraints.append(trailingAnchor.constraint(equalTo: other.trailingAnchor).withPriority(priority))
        }
        return constraints
    }
    
    func constraints(equalTo layoutGuide: UILayoutGuide, directions: LayoutDirection = .all,
                     priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if directions.contains(.top) {
            constraints.append(topAnchor.constraint(equalTo: layoutGuide.topAnchor).withPriority(priority))
        }
        if directions.contains(.leading) {
            constraints.append(leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).withPriority(priority))
        }
        if directions.contains(.bottom) {
            constraints.append(bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).withPriority(priority))
        }
        if directions.contains(.trailing) {
            constraints.append(trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).withPriority(priority))
        }
        return constraints
    }
    
    /// Returns whether interface is right to left (e.g. Arabic language)
    var isRTL: Bool {
        UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }
    
    /// Flips view when in right-to-left layout (e.g. Arabic language)
    func flipForRightToLeftLayoutDirection() {
        guard isRTL else { return }
        transform = .init(scaleX: -1, y: 1)
    }
    
    /// Returns `.right` in left-to-right (regular) layout, and `.left` when it’s in a right-to-left layout (e.g. Arabic language)
    var mirroredAlignment: NSTextAlignment {
        isRTL ? .left : .right
    }
    
    /// Returns fliped `right` and `left` insets for right-to-left layout (e.g. Arabic language)
    func mirroredEdgeInsets(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) -> UIEdgeInsets {
        .init(top: top, left: isRTL ? right : left, bottom: bottom, right: isRTL ? left : right)
    }
}

extension NSLayoutConstraint {
    static func fullLayoutConstraint(
        view: UIView,
        inset: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        guard let superView = view.superview else { return [] }
        return [
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: inset.left),
            view.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: inset.right),
            view.topAnchor.constraint(equalTo: superView.topAnchor, constant: inset.top),
            view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: inset.bottom)
        ]
    }
    
    /// Top and bottom constraints are set as constants
    static func fullLayoutConstraintInMargins(view: UIView) -> [NSLayoutConstraint] {
        guard let superView = view.superview else { return [] }
        return [
            view.leadingAnchor.constraint(equalTo: superView.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: superView.layoutMarginsGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: superView.topAnchor, constant: superView.layoutMargins.top),
            view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -superView.layoutMargins.bottom)
        ]
    }
    
    static func fullLayoutConstraintInSafeAreaMargins(
        view: UIView,
        inset: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        guard let superView = view.superview else { return [] }
        return [
            view.leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor, constant: inset.left),
            view.trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor, constant: inset.right),
            view.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: inset.top),
            view.bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: inset.bottom)
        ]
    }
    
    static func centerConstraint(view: UIView, offsetY: CGFloat = 0, offsetX: CGFloat = 0) -> [NSLayoutConstraint] {
        guard let superView = view.superview else { return [] }
        return centerConstraint(firstView: view, secondView: superView, offsetY: offsetY, offsetX: offsetX)
    }
    
    static func centerConstraint(
        firstView: UIView,
        secondView: UIView,
        offsetY: CGFloat = 0,
        offsetX: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        [
            firstView.centerXAnchor.constraint(equalTo: secondView.centerXAnchor, constant: offsetX),
            firstView.centerYAnchor.constraint(equalTo: secondView.centerYAnchor, constant: offsetY)
        ]
    }
}

public extension NSLayoutConstraint {
    static func activateFullLayoutConstraint(view: UIView, inset: UIEdgeInsets = .zero) {
        activate(fullLayoutConstraint(view: view, inset: inset))
    }
    
    static func activateFullLayoutConstraintInMargins(view: UIView) {
        activate(fullLayoutConstraintInMargins(view: view))
    }
    
    static func activateFullLayoutConstraintInSafeAreaMargins(view: UIView, inset: UIEdgeInsets = .zero) {
        activate(fullLayoutConstraintInSafeAreaMargins(view: view, inset: inset))
    }
    
    static func activateCenterConstraint(view: UIView) {
        activate(centerConstraint(view: view))
    }
}

extension NSDirectionalEdgeInsets {
    // Same all directions
    static func oneValue(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: value, bottom: -value, trailing: -value)
    }
    
    // Sides
    static func horizontalOnly(leading: CGFloat, trailing: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: leading, bottom: 0, trailing: -trailing)
    }
    
    static func horizontalOnly(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: value, bottom: 0, trailing: -value)
    }
    
    static func verticalOnly(top: CGFloat, bottom: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: top, leading: 0, bottom: -bottom, trailing: 0)
    }
    
    static func verticalOnly(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: 0, bottom: -value, trailing: 0)
    }
    
    // One direction
    static func topOnly(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: 0, bottom: 0, trailing: 0)
    }
    
    static func bottomOnly(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: 0, bottom: -value, trailing: 0)
    }
    
    static func leadingOnly(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: value, bottom: 0, trailing: 0)
    }
    
    static func trailingOnly(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: 0, bottom: 0, trailing: -value)
    }
    
    /// Symmetric
    static func symmetric(vertical: CGFloat, horizontal: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: vertical, leading: horizontal, bottom: -vertical, trailing: -horizontal)
    }
}
