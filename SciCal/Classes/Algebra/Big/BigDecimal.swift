//
//  Decimal.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 5/9/21.
//

import Foundation

// magnitude * 2^-scale
final public class BigDecimal: Numeric, Comparable, Divisible, Descriveable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public static var precision : UInt = 114
    private static let doubleAlpha : BigInt = 1 << 52
    
    public static let zero: BigDecimal = BigDecimal(BigInt.zero)
    public static let one: BigDecimal = BigDecimal(BigInt.one)
    public static let two: BigDecimal = BigDecimal(BigInt.two)
    public static let ten: BigDecimal = BigDecimal(BigInt.ten)
    
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    public typealias Stride = BigDecimal
    public typealias Magnitude = BigDecimal
    
    public let value: BigInt
    public let scale : UInt
    
    init (_ magnitude: BigInt, _ scale: UInt = 0) {
        self.value = magnitude
        self.scale = scale
    }
    
    init (unsigned magnitude: BigUInt, _ scale: UInt = 0) {
        self.value = BigInt(false, magnitude)
        self.scale = scale
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.value = BigInt(exactly: source) ?? BigInt.zero
        self.scale = 0
    }
    
    public init(floatLiteral value: Double) {
        let scale : Int = Int(value.exponentBitPattern) - 1023
        let mant = BigInt(value.isLess(than: 0), BigUInt(value.significandBitPattern))
        
        self.value = mant + BigDecimal.doubleAlpha
        self.scale = scale <= 0 ? 52 + scale.magnitude : 52 - scale.magnitude
    }
    
    public init(integerLiteral value: Int) {
        self.value = BigInt(integerLiteral: value)
        self.scale = 0
    }
    
    public init(_ source: BigDecimal) {
        self.value = source.value
        self.scale = source.scale
    }
    
    public var sign : Bool {
        return self.value.sign
    }
    
    public var isInteger : Bool {
        return self.scale == 0 || BigDecimal(integerValue) == self;
    }
    
    public var integerValue : BigInt {
        return self.value >> self.scale
    }
    
    public var fraction : BigDecimal {
        return self - BigDecimal(integerValue)
    }
    
    // ARITHMETIC
    public static func + (lhs: BigDecimal, rhs: BigDecimal) -> BigDecimal {
        if (lhs.scale == rhs.scale) {
            return BigDecimal(lhs.value + rhs.value, lhs.scale)
        }
        
        var delta = lhs.scale.subtractingReportingOverflow(rhs.scale)
        if (delta.overflow) {
            delta.partialValue = ~delta.partialValue + 1
            return BigDecimal((lhs.value << delta.partialValue) + rhs.value, rhs.scale)
        }
        
        return BigDecimal(lhs.value + (rhs.value << delta.partialValue), lhs.scale)
    }
    
    public static func += (lhs: inout BigDecimal, rhs: BigDecimal) {
        lhs = lhs + rhs
    }
    
    public static prefix func - (operand: BigDecimal) -> BigDecimal {
        return BigDecimal(-operand.value, operand.scale)
    }
    
    public static func - (lhs: BigDecimal, rhs: BigDecimal) -> BigDecimal {
        if (lhs.scale == rhs.scale) {
            return BigDecimal(lhs.value - rhs.value, lhs.scale)
        }
        
        var delta = lhs.scale.subtractingReportingOverflow(rhs.scale)
        if (delta.overflow) {
            delta.partialValue = ~delta.partialValue + 1
            return BigDecimal((lhs.value << delta.partialValue) - rhs.value, rhs.scale)
        }
        
        return BigDecimal(lhs.value - (rhs.value << delta.partialValue), lhs.scale)
    }
    
    public static func -= (lhs: inout BigDecimal, rhs: BigDecimal) {
        lhs = lhs - rhs
    }
    
    public static func * (lhs: BigDecimal, rhs: BigDecimal) -> BigDecimal {
        return BigDecimal(lhs.value * rhs.value, lhs.scale + rhs.scale)
    }
    
    public static func *= (lhs: inout BigDecimal, rhs: BigDecimal) {
        lhs = lhs * rhs
    }
    
    public static func / (lhs: BigDecimal, rhs: BigDecimal) -> BigDecimal {
        return lhs.divide(rhs, BigDecimal.precision)
    }
    
    public static func /= (lhs: inout BigDecimal, rhs: BigDecimal) {
        lhs = lhs / rhs
    }
    
    public func divide (_ rhs: BigDecimal, _ precision: UInt) -> BigDecimal {
        return BigDecimal.divide(self, rhs, precision)
    }
    
    public static func divide (_ lhs: BigDecimal, _ rhs: BigDecimal, _ precision: UInt) -> BigDecimal {
        let alpha = lhs.value << (rhs.scale + precision)
        let beta = rhs.value << lhs.scale
        
        return BigDecimal(alpha / beta, precision)
    }
    
    public func scaleByFactorOfTwo (_ factor: Int) -> BigDecimal {
        let sign = factor.signum() < 0
        let abs = factor.magnitude
        
        if (sign) {
            return withScale(scale: self.scale + abs)
        } else if (abs > self.scale) {
            let delta = abs - self.scale
            return BigDecimal(self.value << delta, 0)
        }
        
        return withScale(scale: self.scale - abs)
    }
    
    public func withScale (scale: UInt) -> BigDecimal {
        return BigDecimal(self.value, scale)
    }
    
    public func round (_ mode: RoundingMode = RoundingMode.halfUp) -> BigInt {
        switch mode {
            case .halfUp:
                let int = integerValue
                let frac = self - BigDecimal(int)
                if (frac == BigDecimal.zero) {
                    return int
                }
                
                if (frac.value.bitAt(frac.value.bitWidth - frac.value.trailingZeroBitCount - 1)) {
                    return int + 1
                } else {
                    return int
                }
            case .down:
                return integerValue
        }
    }
    
    public func round (_ precision: UInt, _mode: RoundingMode = RoundingMode.halfUp) -> BigDecimal {
        var value : BigInt;
        if (precision > self.scale) {
            value = BigDecimal(self.value << (precision - self.scale)).round()
        } else {
            value = BigDecimal(self.value, self.scale - precision).round()
        }
        
        return BigDecimal(value, precision)
    }
    
    // COMPARE
    public static func compare (_ lhs: BigDecimal, _ rhs: BigDecimal) -> Int {
        if (lhs.scale == rhs.scale) {
            return BigInt.compare(lhs.value, rhs.value)
        } else if (lhs.value.sign != rhs.value.sign) {
            return lhs.value.sign ? -1 : 1
        }
        
        var delta = lhs.scale.subtractingReportingOverflow(rhs.scale)
        if (delta.overflow) {
            delta.partialValue = ~delta.partialValue + 1
            return BigInt.compare(lhs.value << delta.partialValue, rhs.value)
        }
        
        return BigInt.compare(lhs.value, rhs.value << delta.partialValue)
    }
    
    public static func < (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        return compare(lhs, rhs) < 0
    }
    
    public static func <= (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        return compare(lhs, rhs) <= 0
    }
    
    public static func > (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        return compare(lhs, rhs) > 0
    }
    
    public static func >= (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        return compare(lhs, rhs) >= 0
    }
    
    public static func == (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        return compare(lhs, rhs) == 0
    }
    
    // OTHERS
    public static var minStride: BigDecimal {
        return BigDecimal(BigInt.one, BigDecimal.precision)
    }
    
    /*public func sqrt() -> BigDecimal {
        return sqrti().re
    }
    
    public func sqrti() -> Complex<BigDecimal> {
        return BigMath.sqrt(self)
    }*/
    
    public var magnitude : BigDecimal {
        return BigDecimal(BigInt(false, value.magnitude), self.scale)
    }
    
    /*public var fractionValue: Fraction<BigInt> {
        return Fraction<BigInt>(self.value, BigInt.one << self.scale)
    }*/
    
    public var description: String {
        if (isInteger) {
            return integerValue.description
        }
        
        var str = integerValue.description + "."
        var frac = fraction.magnitude
        
        let digits = Swift.max(1, (frac.scale * 3) / 10)
        let lim = digits - 1
        
        for i in 0..<digits {
            let val = frac * BigDecimal.ten
            let alpha = i < lim ? val.integerValue : val.round()
            
            str += alpha.description
            frac = val - BigDecimal(alpha)
            
            if (frac.sign) {
                break
            }
        }
        
        return str
    }
    
    public var bitDescription : String {
        var str = value.magnitude.bitDescription
        while (self.scale > str.count) {
            str.insert("0", at: str.startIndex)
        }
        
        str.insert(".", at: str.index(str.endIndex, offsetBy: -String.IndexDistance(self.scale)))
        return str
    }
    
    public func distance(to other: BigDecimal) -> BigDecimal {
        return other - self
    }
    
    public func advanced(by n: BigDecimal) -> BigDecimal {
        return self + n
    }
}

public enum RoundingMode {
    case halfUp, down;
}
