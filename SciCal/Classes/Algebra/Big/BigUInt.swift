//
//  BigInt.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 3/9/21.
//

import Foundation

final public class BigUInt: UnsignedInteger, Divisible, Comparable, Descriveable {
    public typealias Words = [UInt]
    public typealias IntegerLiteralType = UInt
    
    public static let byteSize : Int = UInt.bitWidth
    private static let maxValue : UInt = ~0
    
    public static let zero: BigUInt = BigUInt(0)
    public static let one: BigUInt = BigUInt(1)
    public static let two: BigUInt = BigUInt(2)
    public static let ten: BigUInt = BigUInt(10)
    
    public let words: [UInt]
    
    // INITS
    public init (_ words: [UInt]) {
        self.words = BigUInt.trim(words)
    }
    
    public init (integerLiteral value: UInt) {
        self.words = [value]
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        if source.bitWidth <= BigUInt.byteSize {
            self.words = [UInt(source)]
        } else {
            self.words = [UInt]() // TODO
        }
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        if source.bitWidth <= BigUInt.byteSize {
            self.words = [UInt(source)]
        } else {
            self.words = [UInt]() // TODO
        }
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        if source.bitWidth <= BigUInt.byteSize {
            self.words = [UInt(source)]
        } else {
            self.words = [UInt]() // TODO
        }
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        if source.bitWidth <= BigUInt.byteSize {
            self.words = [UInt(source)]
        } else {
            self.words = [UInt]() // TODO
        }
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.words = [UInt]()
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.words = [UInt]()
    }
    
    public init<T>(clamping source: T) where T : BinaryFloatingPoint {
        self.words = [UInt]()
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryFloatingPoint {
        self.words = [UInt]()
    }
    
    public init(_ source: BigDecimal) {
        self.words = source.integerValue.magnitude.words
    }
    
    // BITWISE
    public var isZero : Bool {
        return self.words.count == 1 && self.words[0] == 0
    }
    
    public var bitWidth: Int {
        return BigUInt.byteSize * words.count
    }
    
    public var trailingZeroBitCount: Int {
        var count : Int = 0
        for i in (0..<bitWidth).reversed() {
            if (bitAt(pos: i)) {
                break
            }
            
            count += 1
        }
        
        return count
    }
    
    public static prefix func ~ (x: BigUInt) -> BigUInt {
        return zero // TODO
    }
    
    public static func << (lhs: BigUInt, rhs: Int) -> BigUInt {
        var result : BigUInt = BigUInt.zero
        for i in 0..<lhs.bitWidth {
            result = result.setBit(pos: i + rhs, value: lhs.bitAt(pos: i))
        }
        
        return result
    }
    
    public static func >> (lhs: BigUInt, rhs: Int) -> BigUInt {
        var result : BigUInt = BigUInt.zero
        let alpha = Swift.max(0, lhs.bitWidth - rhs)
        for i in 0..<alpha {
            result = result.setBit(pos: i, value: lhs.bitAt(pos: i + rhs))
        }
        
        return result
    }
    
    public static func >>= <RHS>(lhs: inout BigUInt, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs >> Int(rhs)
    }
    
    public static func <<= <RHS>(lhs: inout BigUInt, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << Int(rhs)
    }
    
    public func bitAt (pos: Int) -> Bool {
        let div = pos.quotientAndRemainder(dividingBy: BigUInt.byteSize)
        return ((self.words[div.quotient] >> div.remainder) & 1) == 1
    }
    
    public func setBit (pos: Int, value: Bool) -> BigUInt {
        var words : [UInt] = self.words.map { $0 }
        let div = pos.quotientAndRemainder(dividingBy: BigUInt.byteSize)
        if (div.quotient >= words.count) {
            for i in 0..<(div.quotient - words.count + 1) {
                words.append(0)
            }
        }
        
        if (value) {
            words[div.quotient] |= 1 << div.remainder
        } else {
            words[div.quotient] &= ~(1 << div.remainder)
        }
        
        return BigUInt(words)
    }
    
    public static func unsignedBytes (bytes: [UInt], wordCount: Int) -> [UInt] {
        var words: [UInt] = bytes.map{ $0 }
        while words.count < wordCount {
            words.append(0)
        }
        
        return words
    }
    
    public func unsignedBytes (wordCount: Int) -> [UInt] {
        return BigUInt.unsignedBytes(bytes: self.words, wordCount: wordCount)
    }
    
    public static func signedBytes (bytes: [UInt], wordCount: Int) -> [UInt] {
        var words: [UInt] = bytes.map{ ~$0 }
        while words.count < wordCount {
            words.append(BigUInt.maxValue)
        }
        
        var done : Bool = false
        for i in 0..<words.count {
            if words[i] < BigUInt.maxValue {
                words[i] += 1
                done = true
                break
            }
        }
        
        if (!done) {
            words = [UInt](repeating: 0, count: words.count + 1)
            words[words.count - 1] = 1
        }
        
        return words;
    }
    
    public func signedBytes (wordCount: Int) -> [UInt] {
        return BigUInt.signedBytes(bytes: self.words, wordCount: wordCount)
    }
    
    // ARITHMETIC
    public static func + (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
        return BigUInt(add(x: lhs.words, y: rhs.words))
    }
    
    public static func - (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
        let len : Int = Swift.max(lhs.words.count, rhs.words.count)
        var result : [UInt] = add(x: lhs.unsignedBytes(wordCount: len), y: rhs.signedBytes(wordCount: len))
        
        if (rhs > lhs) {
            result = signedBytes(bytes: result, wordCount: len)
        }
        
        return BigUInt(Array(result[0..<len]))
    }
    
    public static func * (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
        if (rhs.isZero || lhs.isZero) {
            return BigUInt.zero
        }
        
        var big, small : BigUInt
        
        if (lhs >= rhs) {
            big = lhs
            small = rhs
        } else {
            big = rhs
            small = lhs
        }
        
        var result : BigUInt = zero
        for i in (0..<(small.bitWidth - small.trailingZeroBitCount)) {
            if (small.bitAt(pos: i)) {
                result += big << i
            }
        }
        
        return result
    }
    
    public static func / (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
        return lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }
    
    public static func % (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
        return lhs.quotientAndRemainder(dividingBy: rhs).remainder
    }
    
    public static func %= (lhs: inout BigUInt, rhs: BigUInt) {
        lhs = lhs % rhs
    }
    
    public static func &= (lhs: inout BigUInt, rhs: BigUInt) {
        let bits = Swift.min(lhs.words.count, rhs.words.count)
        var words : [UInt] = [UInt](repeating: 0, count: bits)
        
        for i in 0..<bits {
            words[i] = lhs.words[i] & rhs.words[i]
        }
        
        lhs = BigUInt(words)
    }
    
    public static func |= (lhs: inout BigUInt, rhs: BigUInt) {
        // TODO
    }
    
    public static func ^= (lhs: inout BigUInt, rhs: BigUInt) {
        // TODO
    }
    
    public func quotientAndRemainder (dividingBy rhs: BigUInt) -> (quotient: BigUInt, remainder: BigUInt) {
        if (self.isZero || rhs.isZero) {
            return (BigUInt.zero, BigUInt.zero)
        }
        
        var q : BigUInt = BigUInt.zero
        var r : BigUInt = BigUInt.zero
        
        for i in (0..<self.bitWidth).reversed() {
            r <<= 1
            r = r.setBit(pos: 0, value: self.bitAt(pos: i))
            
            if (r >= rhs) {
                r -= rhs
                q = q.setBit(pos: i, value: true)
            }
        }
        
        return (q, r)
    }
    
    // COMPARE
    public static func compare (_ lhs: BigUInt, _ rhs: BigUInt) -> Int {
        if (lhs.words.count > rhs.words.count) {
            return 1
        } else if (lhs.words.count < rhs.words.count) {
            return -1
        }
        
        for i in (0..<lhs.words.count).reversed() {
            if (lhs.words[i] > rhs.words[i]) {
                return 1
            } else if (lhs.words[i] < rhs.words[i]) {
                return -1
            }
        }
        
        return 0
    }
    
    public static func == (lhs: BigUInt, rhs: BigUInt) -> Bool {
        return compare(lhs, rhs) == 0
    }
    
    public static func < (lhs: BigUInt, rhs: BigUInt) -> Bool {
        return compare(lhs, rhs) < 0
    }
    
    public static func <= (lhs: BigUInt, rhs: BigUInt) -> Bool {
        return compare(lhs, rhs) <= 0
    }
    
    public static func > (lhs: BigUInt, rhs: BigUInt) -> Bool {
        return compare(lhs, rhs) > 0
    }
    
    public static func >= (lhs: BigUInt, rhs: BigUInt) -> Bool {
        return compare(lhs, rhs) >= 0
    }
    
    // OTHERS
    public var signedValue: BigInt {
        return BigInt(false, self)
    }
    
    public var decimalValue: BigDecimal {
        return BigDecimal(unsigned: self)
    }
    
    public var hashValue: Int {
        get {
           return Int(self)
        }
    }
    
    public var description: String {
        var value : BigUInt = self
        var str = ""
        
        while (value > 0) {
            let div = value.quotientAndRemainder(dividingBy: BigUInt.ten)
            let mod = Int(div.remainder);
            
            value = div.quotient
            str += String(format: "%c", mod + 48)
        }
        
        return str == "" ? "0" : String(str.reversed())
    }
    
    public var bitDescription : String {
        var string : String = ""
        for word in words {
            for i in 0..<BigUInt.byteSize {
                string.append(((word >> i) & 1 == 1) ? "1" : "0")
            }
        }
        
        return String(string.reversed())
    }
    
    // PRIVATE
    private static func trim (_ words: [UInt]) -> [UInt] {
        var clone = words.map{$0}
        while (clone.count > 1 && clone.last == 0) {
            clone.removeLast()
        }
        
        return clone
    }
    
    private static func add (x: [UInt], y: [UInt]) -> [UInt] {
        var X, Y : [UInt]
        
        if (x.count >= y.count) {
            X = x.map{$0}
            Y = y.map{$0}
            for _ in y.count..<x.count {
                Y.append(0)
            }
            
        } else {
            X = y.map{$0}
            Y = x.map{$0}
            for _ in x.count..<y.count {
                Y.append(0)
            }
        }
        
        var result = [UInt]()
        var carry : Bool = false
        
        for i in 0..<X.count {
            if (carry) {
                if (X[i] < BigUInt.maxValue) {
                    X[i] += 1
                    carry = false
                } else if (Y[i] < BigUInt.maxValue) {
                    Y[i] += 1
                    carry = false
                } else {
                    result.append(~1)
                    continue
                }
            }
            
            var sum = X[i].addingReportingOverflow(Y[i])
            carry = sum.overflow
            result.append(sum.partialValue)
        }
        
        if (carry) {
            result.append(1)
        }
        
        return result
    }
}
