import Foundation

final public class Integer: Comparable, SignedInteger, Strideable {
    public typealias Words = [UInt]
    public typealias Stride = Integer
    public typealias Magnitude = IntegerMagnitude
    public typealias IntegerLiteralType = UInt64
    
    public let sign : Bool
    public let magnitude : IntegerMagnitude
    
    public var words: [UInt] {
        get {
            self.magnitude.words
        }
    }
    
    public var hashValue: Int {
        return 123
    }
    
    public init (sign: Bool, mag: IntegerMagnitude) {
        self.sign = sign
        self.magnitude = mag
    }
    
    public init (sign: Bool, words: [UInt64]) {
        self.sign = sign
        self.magnitude = IntegerMagnitude(words)
    }
    
    public init(integerLiteral value: UInt64) {
        self.sign = false
        self.magnitude = IntegerMagnitude([value])
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.sign = source.signum() < 0
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.sign = source.signum() < 0
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.sign = source.signum() < 0
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.sign = source.signum() < 0
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.sign = source.isLess(than: 0)
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init<T>(clamping source: T) where T : BinaryFloatingPoint {
        self.sign = source.isLess(than: 0)
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryFloatingPoint {
        self.sign = source.isLess(than: 0)
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.sign = source.isLess(than: 0)
        self.magnitude = IntegerMagnitude.zero // TODO
    }
    
    public var isZero : Bool {
        return magnitude.isZero
    }
    
    // BITWISE
    public var bitWidth: Int {
        return magnitude.bitWidth
    }
    
    public var trailingZeroBitCount: Int {
        return magnitude.trailingZeroBitCount
    }
    
    public static prefix func ~ (x: Integer) -> Integer {
        return Integer(sign: !x.sign, mag: ~x.magnitude)
    }
    
    public static func & (lhs: Integer, rhs: Integer) -> Integer {
        return Integer(sign: lhs.sign && rhs.sign, mag: lhs.magnitude & rhs.magnitude)
    }
    
    public static func | (lhs: Integer, rhs: Integer) -> Integer {
        return Integer(sign: lhs.sign || rhs.sign, mag: lhs.magnitude | rhs.magnitude)
    }
    
    public static func ^ (lhs: Integer, rhs: Integer) -> Integer {
        return Integer(sign: lhs.sign != rhs.sign, mag: lhs.magnitude ^ rhs.magnitude)
    }
    
    public static func >> (lhs: Integer, _ rhs: Int) -> Integer {
        return Integer(sign: lhs.sign, mag: lhs.magnitude >> rhs)
    }
    
    public static func << (lhs: Integer, _ rhs: Int) -> Integer {
        return Integer(sign: lhs.sign, mag: lhs.magnitude << rhs)
    }
    
    public static func >>= <RHS>(lhs: inout Integer, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs >> rhs
    }
    
    public static func <<= <RHS>(lhs: inout Integer, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << rhs
    }
    
    // ARITHMETIC
    public func negate () -> Integer {
        return Integer(sign: !self.sign, mag: self.magnitude)
    }
    
    public static func + (lhs: Integer, rhs: Integer) -> Integer {
        if (lhs.isZero) {
            return rhs
        } else if (rhs.isZero) {
            return lhs
        } else if (lhs.sign == rhs.sign) { // a + b, -a - b
            return Integer(sign: lhs.sign, mag: lhs.magnitude + rhs.magnitude)
        } else if (!lhs.sign && rhs.sign) {
            // a - b
            return Integer(sign: rhs.magnitude > lhs.magnitude, mag: lhs.magnitude - rhs.magnitude)
        }
        
        // b - a
        return Integer(sign: lhs.magnitude > rhs.magnitude, mag: rhs.magnitude - lhs.magnitude)
    }
    
    public static func - (lhs: Integer, rhs: Integer) -> Integer {
        return lhs + rhs.negate()
    }
    
    public static func * (lhs: Integer, rhs: Integer) -> Integer {
        return Integer(sign: lhs.sign != rhs.sign, mag: lhs.magnitude * rhs.magnitude)
    }
    
    public static func *= (lhs: inout Integer, rhs: Integer) {
        lhs = lhs * rhs
    }
    
    public static func / (lhs: Integer, rhs: Integer) -> Integer {
        return Integer(sign: lhs.sign != rhs.sign, mag: lhs.magnitude / rhs.magnitude)
    }
    
    public static func /= (lhs: inout Integer, rhs: Integer) {
        lhs = lhs / rhs
    }
    
    public static func % (lhs: Integer, rhs: Integer) -> Integer {
        return Integer(sign: false, mag: lhs.magnitude % rhs.magnitude)
    }
    
    public static func %= (lhs: inout Integer, rhs: Integer) {
        lhs = lhs % rhs
    }
    
    public static func &= (lhs: inout Integer, rhs: Integer) {
        // TODO
    }
    
    public static func |= (lhs: inout Integer, rhs: Integer) {
        // TODO
    }
    
    public static func ^= (lhs: inout Integer, rhs: Integer) {
        // TODO
    }
    
    // STRIDE
    public func distance(to other: Integer) -> Integer {
        return other - self
    }
    
    public func advanced(by n: Integer) -> Integer {
        return self + n
    }
    
    // COMPARE
    public static func compare (lhs: Integer, rhs: Integer) -> Int {
        if (lhs.isZero && rhs.isZero) {
            return 0
        }
        
        if (lhs.sign == rhs.sign) {
            let comp : Int = IntegerMagnitude.compare(lhs: lhs.magnitude, rhs: rhs.magnitude)
            return lhs.sign ? -comp : comp
        }
        
        return lhs.sign ? -1 : 1
    }
    
    public static func == (lhs: Integer, rhs: Integer) -> Bool {
        return (lhs.isZero && rhs.isZero) || (lhs.magnitude == rhs.magnitude && lhs.sign == rhs.sign)
    }
    
    public static func < (lhs: Integer, rhs: Integer) -> Bool {
        return compare(lhs: lhs, rhs: rhs) < 0
    }
    
    public static func <= (lhs: Integer, rhs: Integer) -> Bool {
        return compare(lhs: lhs, rhs: rhs) <= 0
    }
    
    public static func > (lhs: Integer, rhs: Integer) -> Bool {
        return compare(lhs: lhs, rhs: rhs) > 0
    }
    
    public static func >= (lhs: Integer, rhs: Integer) -> Bool {
        return compare(lhs: lhs, rhs: rhs) >= 0
    }
    
    // INITIALIZERS (UNSIGNED)    
    public static func valueOf (sign: Bool = false, ubyte: UInt8) -> Integer {
        return Integer(sign: sign, words: [UInt64(ubyte)]);
    }
    
    public static func valueOf (sign: Bool = false, ushort: UInt16) -> Integer {
        return Integer(sign: sign, words: [UInt64(ushort)]);
    }
    
    public static func valueOf (sign: Bool = false, uint: UInt32) -> Integer {
        return Integer(sign: sign, words: [UInt64(uint)]);
    }
    
    public static func valueOf (sign: Bool = false, ulong: UInt64) -> Integer {
        return Integer(sign: sign, words: [ulong]);
    }
    
    // INITIALIZERS (SIGNED)
    public static func valueOf (byte: Int8) -> Integer {
        return valueOf(sign: byte < 0, ubyte: byte.magnitude)
    }
    
    public static func valueOf (short: Int16) -> Integer {
        return valueOf(sign: short < 0, ushort: short.magnitude)
    }
    
    public static func valueOf (int: Int32) -> Integer {
        return valueOf(sign: int < 0, uint: int.magnitude)
    }
    
    public static func valueOf (long: Int64) -> Integer {
        return valueOf(sign: long < 0, ulong: long.magnitude)
    }
}
