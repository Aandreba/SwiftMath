//
//  Fraction.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 22/9/21.
//

import Foundation

final public class Fraction<T>: Numeric, Divisible where T: Numeric {
    public typealias Magnitude = Fraction<T.Magnitude>
    public typealias IntegerLiteralType = T.IntegerLiteralType
    
    public let num, denom: T
    
    public init (_ num: T = T.zero, _ denom: T = 1) {
        self.num = num
        self.denom = denom
    }
    
    public init(integerLiteral value: T.IntegerLiteralType) {
        self.num = T(integerLiteral: value)
        self.denom = 1
    }
    
    public init?<E>(exactly source: E) where E : BinaryInteger {
        self.num = T(exactly: source) ?? T.zero
        self.denom = 1
    }
    
    // ARITHMETIC
    public static func + (lhs: Fraction<T>, rhs: Fraction<T>) -> Fraction<T> {
        if (lhs.denom == rhs.denom) {
            return Fraction<T>(lhs.num + rhs.num, lhs.denom)
        }
        
        return Fraction<T>(lhs.num * rhs.denom + rhs.num * lhs.denom, rhs.denom * lhs.denom)
    }
    
    public static func - (lhs: Fraction<T>, rhs: Fraction<T>) -> Fraction<T> {
        if (lhs.denom == rhs.denom) {
            return Fraction<T>(lhs.num - rhs.num, lhs.denom)
        }
        
        return Fraction<T>(lhs.num * rhs.denom - rhs.num * lhs.denom, rhs.denom * lhs.denom)
    }
    
    public static func * (lhs: Fraction<T>, rhs: Fraction<T>) -> Fraction<T> {
        return Fraction<T>(lhs.num * rhs.num, lhs.denom * rhs.denom)
    }
    
    public static func / (lhs: Fraction<T>, rhs: Fraction<T>) -> Fraction<T> {
        return Fraction<T>(lhs.num * rhs.denom, lhs.denom * rhs.num)
    }
    
    // COMPARE
    public static func == (lhs: Fraction<T>, rhs: Fraction<T>) -> Bool {
        return lhs.num * rhs.denom == lhs.denom * rhs.num
    }
    
    // OTHERS
    public var magnitude: Fraction<T.Magnitude> {
        return Fraction<T.Magnitude>(self.num.magnitude, self.denom.magnitude)
    }
}

// EXTENSION
extension Fraction: Number where T: Number {
    public typealias DecimalType = Fraction<T.DecimalType>
    
    public static var one: Fraction<T> {
        return Fraction<T>(T.one, T.one)
    }
    
    public var isNegative: Bool {
        return self.num.isNegative != self.denom.isNegative
    }
    
    public var positive: Fraction<T> {
        return Fraction<T>(self.num.positive, self.denom.positive)
    }
    
    public var decimalValue: Fraction<T.DecimalType> {
        return Fraction<T.DecimalType>(self.num.decimalValue, self.denom.decimalValue)
    }
    
    public func squareRoot() -> Fraction<T.DecimalType> {
        return Fraction<T.DecimalType>(self.num.squareRoot(), self.denom.squareRoot())
    }
}

extension Fraction: Comparable where T: Comparable {
    public static func < (lhs: Fraction<T>, rhs: Fraction<T>) -> Bool {
        return lhs.num * rhs.denom < lhs.denom * rhs.num
    }
    
    public static func <= (lhs: Fraction<T>, rhs: Fraction<T>) -> Bool {
        return lhs.num * rhs.denom <= lhs.denom * rhs.num
    }
    
    public static func > (lhs: Fraction<T>, rhs: Fraction<T>) -> Bool {
        return lhs.num * rhs.denom > lhs.denom * rhs.num
    }
    
    public static func >= (lhs: Fraction<T>, rhs: Fraction<T>) -> Bool {
        return lhs.num * rhs.denom >= lhs.denom * rhs.num
    }
}

extension Fraction where T: Divisible {
    public var value: T {
        return self.num / self.denom
    }
}

extension Fraction: Descriveable where T: Descriveable {
    public var description: String {
        return self.num.description + "/" + self.denom.description
    }
}
