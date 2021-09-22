//
//  Number.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 22/9/21.
//

import Foundation

public protocol Descriveable {
    var description : String { get }
}

public protocol Divisible {
    static func / (lhs: Self, rhs: Self) -> Self
    static func /= (lhs: inout Self, rhs: Self)
}

public protocol Number: Numeric, Comparable where Magnitude: Number {
    associatedtype DecimalType: Number
    
    static var one: Self { get }
    
    var isNegative: Bool { get }
    var positive: Self { get }
    var decimalValue: DecimalType { get }
    
    func squareRoot() -> DecimalType
    func complexSqrt() -> Complex<DecimalType>
}

// EXTENSIONS
extension Divisible {
    public static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

extension Numeric {
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

// NUMBER EXTENSIONS
extension Number {
    public func complexSqrt() -> Complex<DecimalType> {
        let sqrt = self.positive.squareRoot()
        return self.isNegative ? Complex<DecimalType>(im: sqrt) : Complex<DecimalType>(re: sqrt)
    }
}

extension Number where Self: UnsignedInteger {
    public var isNegative: Bool {
        return false
    }
    
    public var positive: Self {
        return self
    }
}

extension Number where Self: SignedInteger {
    public var isNegative: Bool {
        return self.signum() == -1
    }
    
    public var positive: Self {
        return isNegative ? -self : self
    }
}

extension Number where Self: BinaryFloatingPoint {
    public var isNegative: Bool {
        return self.isLess(than: 0)
    }
    
    public var positive: Self {
        return isNegative ? -self : self
    }
}
