//
//  BigInt.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 4/9/21.
//

import Foundation

final public class BigInt: SignedInteger, Divisible, Comparable, Descriveable {
    public static let zero: BigInt = BigInt(false, BigUInt.zero)
    public static let one: BigInt = BigInt(false, BigUInt.one)
    public static let two: BigInt = BigInt(false, BigUInt.two)
    public static let ten: BigInt = BigInt(false, BigUInt.ten)
    
    public typealias Words = [UInt]
    public typealias Magnitude = BigUInt
    public typealias IntegerLiteralType = Int

    public let sign : Bool
    public let magnitude: BigUInt
    
    public var decimalValue: BigDecimal {
        return BigDecimal(self)
    }
    
    init (_ sign: Bool = false, _ magnitude: BigUInt) {
        self.sign = sign
        self.magnitude = magnitude
    }
    
    public init (integerLiteral value: Int) {
        self.sign = value < 0
        self.magnitude = BigUInt(integerLiteral: abs(value).magnitude)
    }
    
    public init (integerLiteral value: UInt) {
        self.sign = false
        self.magnitude = BigUInt(integerLiteral: value)
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        let sign = source.signum()
        self.sign = sign == 0
        self.magnitude = sign == 0 ? BigUInt.zero : (sign == 1 ? BigUInt(source) : BigUInt(0 - source))
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        let sign = source.signum()
        self.sign = sign == 0
        
        if (sign == 0) {
            self.magnitude = BigUInt.zero
        } else if (sign == 1) {
            self.magnitude = BigUInt(exactly: source) ?? BigUInt.zero
        } else {
            self.magnitude = BigUInt(exactly: 0 - source) ?? BigUInt.zero
        }
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        let sign = source.signum()
        self.sign = sign == 0
        
        if (sign == 0) {
            self.magnitude = BigUInt.zero
        } else if (sign == 1) {
            self.magnitude = BigUInt(clamping: source)
        } else {
            self.magnitude = BigUInt(clamping: 0 - source)
        }
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        let sign = source.signum()
        self.sign = sign == 0
        
        if (sign == 0) {
            self.magnitude = BigUInt.zero
        } else if (sign == 1) {
            self.magnitude = BigUInt(truncatingIfNeeded: source)
        } else {
            self.magnitude = BigUInt(truncatingIfNeeded: 0 - source)
        }
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.sign = false
        self.magnitude = BigUInt.zero
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.sign = false
        self.magnitude = BigUInt.zero
    }
    
    public init<T>(clamping source: T) where T : BinaryFloatingPoint {
        self.sign = false
        self.magnitude = BigUInt.zero
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryFloatingPoint {
        self.sign = false
        self.magnitude = BigUInt.zero
    }
    
    public init(_ source: BigDecimal) {
        let int = source.integerValue
        
        self.sign = int.sign
        self.magnitude = int.magnitude
    }
    
    // BITWISE
    public var words: [UInt] {
        return self.magnitude.words
    }
    
    public var bitWidth: Int {
        return self.magnitude.bitWidth
    }
    
    public var trailingZeroBitCount: Int {
        return self.magnitude.trailingZeroBitCount
    }
    
    public func bitAt (_ pos: Int) -> Bool {
        return magnitude.bitAt(pos: pos)
    }
    
    public func setBit (_ pos: Int, _ value: Bool) -> BigInt {
        return BigInt(self.sign, self.magnitude.setBit(pos: pos, value: value))
    }
    
    public static prefix func ~ (x: BigInt) -> BigInt {
        return BigInt(!x.sign, ~x.magnitude)
    }
    
    public static prefix func - (x: BigInt) -> BigInt {
        return BigInt(!x.sign, x.magnitude)
    }
    
    public func negate () -> BigInt{
        return -self
    }
    
    // ARITHMATIC
    public static func + (lhs: BigInt, rhs: BigInt) -> BigInt {
        if (lhs.sign == rhs.sign) {
            return BigInt(lhs.sign, lhs.magnitude + rhs.magnitude)
        } else if (lhs.sign) {
            let sign : Bool = lhs.magnitude > rhs.magnitude
            return BigInt(sign, sign ? lhs.magnitude - rhs.magnitude : lhs.magnitude - rhs.magnitude)
        }
        
        let sign : Bool = rhs.magnitude > lhs.magnitude
        return BigInt(sign, sign ? rhs.magnitude - lhs.magnitude : rhs.magnitude - lhs.magnitude)
    }
    
    public static func - (lhs: BigInt, rhs: BigInt) -> BigInt {
        return lhs + rhs.negate()
    }
    
    public static func * (lhs: BigInt, rhs: BigInt) -> BigInt {
        return BigInt(lhs.sign != rhs.sign, lhs.magnitude * rhs.magnitude)
    }
    
    public static func / (lhs: BigInt, rhs: BigInt) -> BigInt {
        return BigInt(lhs.sign != rhs.sign, lhs.magnitude / rhs.magnitude)
    }
    
    public static func % (lhs: BigInt, rhs: BigInt) -> BigInt {
        return BigInt(rhs.sign, lhs.magnitude % rhs.magnitude)
    }
    
    public static func %= (lhs: inout BigInt, rhs: BigInt) {
        lhs = lhs % rhs
    }
    
    public static func &= (lhs: inout BigInt, rhs: BigInt) {
        lhs = BigInt(lhs.sign && rhs.sign, lhs.magnitude & rhs.magnitude)
    }
    
    public static func |= (lhs: inout BigInt, rhs: BigInt) {
        lhs = BigInt(lhs.sign || rhs.sign, lhs.magnitude | rhs.magnitude)
    }
    
    public static func ^= (lhs: inout BigInt, rhs: BigInt) {
        lhs = BigInt(lhs.sign != rhs.sign, lhs.magnitude ^ rhs.magnitude)
    }
    
    public static func >>= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS : BinaryInteger {
        lhs = BigInt(lhs.sign, lhs.magnitude >> rhs)
    }
    
    public static func <<= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS : BinaryInteger {
        lhs = BigInt(lhs.sign, lhs.magnitude << rhs)
    }
    
    public func quotientAndRemainder(dividingBy rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
        let div = self.magnitude.quotientAndRemainder(dividingBy: rhs.magnitude)
        return (BigInt(self.sign != rhs.sign, div.quotient), BigInt(rhs.sign, div.remainder))
    }
    
    public static func compare (_ lhs: BigInt, _ rhs: BigInt) -> Int {
        if (lhs.sign == rhs.sign) {
            let result = BigUInt.compare(lhs.magnitude, rhs.magnitude)
            return lhs.sign ? -result : result
        }
        
        return lhs.sign ? -1 : 1
    }
    
    public static func == (lhs: BigInt, rhs: BigInt) -> Bool {
        return compare(lhs, rhs) == 0
    }
    
    public static func < (lhs: BigInt, rhs: BigInt) -> Bool {
        return compare(lhs, rhs) < 0
    }
    
    public static func <= (lhs: BigInt, rhs: BigInt) -> Bool {
        return compare(lhs, rhs) <= 0
    }
    
    public static func > (lhs: BigInt, rhs: BigInt) -> Bool {
        return compare(lhs, rhs) > 0
    }
    
    public static func >= (lhs: BigInt, rhs: BigInt) -> Bool {
        return compare(lhs, rhs) >= 0
    }
    
    // OHTERS
    public var description: String {
        return sign ? "-"+self.magnitude.description : self.magnitude.description
    }
    
    public var hashValue: Int {
        get {
            return self.sign ? -self.magnitude.hashValue : self.magnitude.hashValue
        }
    }
}
