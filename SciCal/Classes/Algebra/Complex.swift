//
//  Complex.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 22/9/21.
//

import Foundation

final public class Complex<T>: Numeric where T: Number {
    public typealias Magnitude = T.DecimalType
    public typealias IntegerLiteralType = T.IntegerLiteralType
    
    public let re, im : T
    
    public init (re: T = T.zero, im: T = T.zero) {
        self.re = re
        self.im = im
    }
    
    public init?<E>(exactly source: E) where E : BinaryInteger {
        self.re = T(exactly: source) ?? T.zero
        self.im = T.zero
    }
    
    public init(integerLiteral value: T.IntegerLiteralType) {
        self.re = T(integerLiteral: value)
        self.im = T.zero
    }
    
    // ARITHMETIC
    public static func + (lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
        return Complex<T>(re: lhs.re + rhs.re, im: lhs.im + rhs.im)
    }
    
    public static func - (lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
        return Complex<T>(re: lhs.re - rhs.re, im: lhs.im - rhs.im)
    }
    
    public static func * (lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
        return Complex<T>(re: lhs.re * rhs.re - lhs.im * rhs.im, im: lhs.re * rhs.im + lhs.im * rhs.re)
    }
    
    // COMPARE
    public static func == (lhs: Complex<T>, rhs: Complex<T>) -> Bool {
        return lhs.re == rhs.re && lhs.im == rhs.im
    }
    
    // OTHERS
    public static var zero: Complex<T> {
        return Complex<T>()
    }
    
    public var magnitude: T.DecimalType {
        return (self.re * self.re + self.im * self.im).squareRoot()
    }
}

// EXTENSIONS
extension Complex: Descriveable where T: Descriveable {
    public var description: String {
        if (self.im == 0) {
            return self.re.description
        } else if (self.re == 0) {
            return self.im.description + "i"
        }
        
        return self.re.description + (self.im.isNegative ? " - " : " + ") + self.im.positive.description + "i"
    }
}
