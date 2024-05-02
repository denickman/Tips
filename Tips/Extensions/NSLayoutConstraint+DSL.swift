//
//  NSLayoutConstraint+DSL.swift
//  Tips
//
//  Created by Denis Yaremenko on 01.04.2024.
//

import UIKit

extension NSLayoutConstraint {
    
    /// Abstraction that can be used to define a comparison with any layout anchor
    struct LayoutAttributes<A: AnyObject> {
        let anchor: NSLayoutAnchor<A>
        let constant: CGFloat
        
        init(anchor: NSLayoutAnchor<A>, constant: CGFloat) {
            self.anchor = anchor
            self.constant = constant
        }
    }
    
    /// Abstraction that can be used to define a comparison with any dimension anchors
    struct DimensionAttributes {
        let anchor: NSLayoutDimension
        let constant: CGFloat
        let multiplier: CGFloat
        
        init(anchor: NSLayoutDimension, constant: CGFloat, multiplier: CGFloat) {
            self.anchor = anchor
            self.constant = constant
            self.multiplier = multiplier
        }
    }
    
    @resultBuilder
    struct ConstraintsBuilder {
        public static func buildBlock(_ components: ConstraintConvervible...) -> [NSLayoutConstraint] {
            components.flatMap(\.constraints)
        }
        
        public static func buildOptional(_ component: [ConstraintConvervible]?) -> [NSLayoutConstraint] {
            component?.flatMap(\.constraints) ?? []
        }
        
        public static func buildEither(first component: [ConstraintConvervible]) -> [NSLayoutConstraint] {
            component.flatMap(\.constraints)
        }
        
        public static func buildEither(second component: [ConstraintConvervible]) -> [NSLayoutConstraint] {
            component.flatMap(\.constraints)
        }
    }
    
    /// Activates each constraint passed in the build block.
    ///
    /// The build block of this method can accept single constraints, arrays of constraints, values of `SizeConstrains` type,
    /// supports conditional checks and unwrapping optional values. See example below.
    ///
    ///     NSLayoutConstraint.activate {
    ///         // single constraint
    ///         field.centerXAnchor == centerXAnchor
    ///         field.topAnchor >= topAnchor + padding
    ///
    ///         // array of constraints
    ///         rightView.constraints
    ///
    ///         // SizeConstraints
    ///         field.makeSizeConstraints(equalToConstant: fieldSize)
    ///
    ///         // conditional constrains
    ///         if hasInsets {
    ///             field.trailingAnchor <= trailingAnchor - insets
    ///         } else {
    ///             field.trailingAnchor == trailingAnchor
    ///         }
    ///
    ///         // unwrapping optional
    ///         if let leftView == leftView {
    ///             field.leadingAnchor == leftView.trailingAnchor
    ///         }
    ///
    ///         // multipliers
    ///         topView.widthAnchor == bottomView.widthAnchor * 0.5
    ///
    ///         // you can also use division operator and add or subtract constants
    ///         topView.widthAnchor == bottomView.widthAnchor / 2 + 100
    ///
    ///         // use ~ to specify constraint priority
    ///         topView.heightAnchor == 50 ~ .defaultHigh
    ///         topView.heightAnchor >= bottomView.heightAnchor * 0.8 ~ 999
    ///
    ///     }
    ///
    /// - Parameter constraints: A `ConstraintsBuilder` build block.
    /// - Returns activated constraints
    @discardableResult
    static func activate(@ConstraintsBuilder _ constraints: () -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        let layoutConstraints = constraints()
        Self.activate(layoutConstraints)
        return layoutConstraints
    }
    
    /// Use for arrays where you have to asssign constraints Parameter constraints: A `ConstraintsBuilder` build block.
    static func makeConstraints(@ConstraintsBuilder _ constraints: () -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        constraints()
    }
}

// MARK: - NSLayoutConstraint extentions for arrays

extension Array where Element == NSLayoutConstraint {
    mutating func append(@NSLayoutConstraint.ConstraintsBuilder _ constraints: () -> [NSLayoutConstraint]) {
        append(contentsOf: constraints())
    }
}

// MARK: - UIView Constraint Maker

extension UIView {
    
    func activateConstraints(@NSLayoutConstraint.ConstraintsBuilder _ constraints: (UIView) -> [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint.activate(constraints(self))
    }
    
    func makeConstraints(@NSLayoutConstraint.ConstraintsBuilder _ constraints: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        constraints(self)
    }
}

// MARK: - Protocols

/// Abstraction used by `NSLayoutConstraint.ConstraintsBuilder`
/// to allow passing single values, arrays, conditional values and `SizeConstraints` into one build block.
protocol ConstraintConvervible {
    var constraints: [NSLayoutConstraint] { get }
}

extension NSLayoutConstraint: ConstraintConvervible {
    public var constraints: [NSLayoutConstraint] { [self] }
}

extension Array: ConstraintConvervible where Element == NSLayoutConstraint {
    public var constraints: [NSLayoutConstraint] { self }
}

// MARK: - Arithmetic Operators

func +<A: AnyObject>(lhs: NSLayoutAnchor<A>, rhs: CGFloat) -> NSLayoutConstraint.LayoutAttributes<A> {
    .init(anchor: lhs, constant: rhs)
}

func -<A: AnyObject>(lhs: NSLayoutAnchor<A>, rhs: CGFloat) -> NSLayoutConstraint.LayoutAttributes<A> {
    .init(anchor: lhs, constant: -rhs)
}

func +(lhs: NSLayoutConstraint.DimensionAttributes, rhs: CGFloat) -> NSLayoutConstraint.DimensionAttributes {
    .init(anchor: lhs.anchor, constant: lhs.constant + rhs, multiplier: lhs.multiplier)
}

func -(lhs: NSLayoutConstraint.DimensionAttributes, rhs: CGFloat) -> NSLayoutConstraint.DimensionAttributes {
    .init(anchor: lhs.anchor, constant: lhs.constant - rhs, multiplier: lhs.multiplier)
}

func *(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint.DimensionAttributes {
    .init(anchor: lhs, constant: .zero, multiplier: rhs)
}

func /(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint.DimensionAttributes {
    .init(anchor: lhs, constant: .zero, multiplier: 1/rhs)
}

// MARK: - Equality Operators

func ==<A: AnyObject>(
    lhs: NSLayoutAnchor<A>,
    rhs: NSLayoutConstraint.LayoutAttributes<A>
) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
}

func ==(lhs: NSLayoutDimension, rhs: NSLayoutConstraint.DimensionAttributes) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
}

func ==(lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

func ==(lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

func ==(lhs: NSLayoutDimension, rhs: NSLayoutDimension) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

func ==(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalToConstant: rhs)
}

// MARK: - Comparison Operators

func >=<A: AnyObject>(lhs: NSLayoutAnchor<A>, rhs: NSLayoutAnchor<A>) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs, constant: .zero)
}

func >=<A: AnyObject>(
    lhs: NSLayoutAnchor<A>,
    rhs: NSLayoutConstraint.LayoutAttributes<A>
) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
}

func >=(lhs: NSLayoutDimension, rhs: NSLayoutConstraint.DimensionAttributes) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
}

func >=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualToConstant: rhs)
}

func <=<A: AnyObject>(lhs: NSLayoutAnchor<A>, rhs: NSLayoutAnchor<A>) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs, constant: .zero)
}

func <=<A: AnyObject>(
    lhs: NSLayoutAnchor<A>,
    rhs: NSLayoutConstraint.LayoutAttributes<A>
) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
}

func <=(lhs: NSLayoutDimension, rhs: NSLayoutConstraint.DimensionAttributes) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
}

func <=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualToConstant: rhs)
}

// MARK: - Priority Operators

precedencegroup LayoutPriorityPrecedence {
    lowerThan: ComparisonPrecedence
}

infix operator ~: LayoutPriorityPrecedence

func ~(lhs: NSLayoutConstraint, rhs: UILayoutPriority) -> NSLayoutConstraint {
    lhs.withPriority(rhs)
}

func ~(lhs: NSLayoutConstraint, rhs: Float) -> NSLayoutConstraint {
    lhs ~ UILayoutPriority(rawValue: rhs)
}

