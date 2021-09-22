import Foundation

final public class IntegerMagnitude: Comparable, UnsignedInteger {
    public static var zero : IntegerMagnitude = IntegerMagnitude([0])
    public static var one : IntegerMagnitude = IntegerMagnitude([1])
    
    public typealias Words = [UInt]
    public typealias Stride = Integer
    public typealias Magnitude = IntegerMagnitude
    public typealias IntegerLiteralType = UInt64
    
    public let isSigned : Bool = false
    private var realWords : [UInt64]
    
    public var magnitude: IntegerMagnitude {
        get {
            return self
        }
    }
    
    public var words: [UInt] {
        get {
            self.realWords.map{ UInt($0) }
        }
    }
    
    public var hashValue: Int {
        return Int(self);
    }
    
    init (_ words: [UInt64]) {
        self.realWords = words;
        trim()
    }
    
    init () {
        self.realWords = [UInt64]()
    }
    
    init<T> (other: T) {
        self.realWords = [UInt64]()
    }
    
    public init(integerLiteral value: UInt64) {
        self.realWords = [value]
        trim()
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.realWords = [UInt64]()
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.realWords = [UInt64]()
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.realWords = [UInt64]()
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.realWords = [UInt64]()
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.realWords = [UInt64]()
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.realWords = [UInt64]()
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryFloatingPoint {
        self.realWords = [UInt64]()
    }
    
    // BITWISE
    public var isZero : Bool {
        return self.realWords.count == 1 && self.realWords[0] == 0
    }
    
    public var bitWidth : Int {
        return self.realWords.count * 64
    }
    
    public var trailingZeroBitCount: Int {
        var count : Int = 0
        for i in (0..<realWords.count).reversed() {
            if (realWords[i] == 0) {
                count += 64
                continue
            }
            
            for j in (0..<64).reversed() {
                if ((realWords[i] >> j) & 1) == 1 {
                    break
                }
                
                count += 1
            }
        }
        
        return count
    }
    
    public func twosCompliment (sign: Bool, wordCount: Int) -> [UInt64] {
        if (!sign) {
            var words: [UInt64] = self.realWords.map{ $0 }
            while (words.count < wordCount) {
                words.append(0)
            }
            
            return words
        }
        
        var words: [UInt64] = self.realWords.map{ ~$0 }
        for i in 0..<
        while (words.count < wordCount) {
            words.append(0)
        }
        
        for i in 0..<words.count {
            words[i] = ~words[i]
        }
        
        return words
    }
    
    public var leftMostBit : Int {
        return bitWidth - trailingZeroBitCount
    }
    
    public static prefix func ~ (x: IntegerMagnitude) -> IntegerMagnitude {
        var words : [UInt64] = x.realWords.map{$0}
        for i in 0..<words.count {
            words[i] = ~words[i]
        }
        
        return IntegerMagnitude(words)
    }
    
    public static func >> (x: IntegerMagnitude, _ n: Int) -> IntegerMagnitude {
        let alpha = 64 - n;
        var words : [UInt64] = x.realWords.map{$0};
        
        for i in 0..<words.count {
            words[i] >>= n;
            if (i+1 < words.count) {
                words[i] |= ((words[i+1] << alpha) >> alpha) << alpha;
            }
        }
    
        return IntegerMagnitude(words)
    }
    
    public static func >>= <RHS>(lhs: inout IntegerMagnitude, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs >> rhs
    }
    
    public static func << (x: IntegerMagnitude, _ n: Int) -> IntegerMagnitude {
        if (x.isZero) {
            return zero
        }
        
        var words = x.realWords.map{$0}
        let wordDelta = n / 64
        let bitsDelta = 64 - (n % 64)
    
        for i in 0...wordDelta {
            words.insert(0, at: 0)
        }
        
        return IntegerMagnitude(words) >> bitsDelta
    }
    
    public static func <<= <RHS>(lhs: inout IntegerMagnitude, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << rhs
    }
    
    public func getBit (pos: Int) -> Bool {
        let word = pos / 64
        let bit = pos % 64;
        return ((realWords[word] >> bit) & 1) == 1;
    }
    
    public func setBit (pos: Int, _ value: Bool) -> IntegerMagnitude {
        var words = self.realWords.map{$0}
        let word = pos / 64
        let bit = pos % 64;
        
        if (value) {
            words[word] |= (1 << bit);
        } else {
            words[word] &= ~(1 << bit);
        }
        
        return IntegerMagnitude(words)
    }
    
    // Arithmetic
    public static func + (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> IntegerMagnitude {
        return IntegerMagnitude(add(_x: lhs.realWords, _y: rhs.realWords))
    }
    
    public static func - (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> IntegerMagnitude {
        let len : Int = Swift.max(rhs.realWords.count, lhs.realWords.count) + 1
        return IntegerMagnitude(add(_x: lhs.twosCompliment(sign: false, wordCount: len), _y: rhs.twosCompliment(sign: true, wordCount: len)))
    }
    
    public static func * (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> IntegerMagnitude {
        if (lhs.isZero || rhs.isZero) {
            return IntegerMagnitude.zero
        }
        
        var big, small : IntegerMagnitude
        if (lhs.realWords.count >= rhs.realWords.count) {
            big = lhs
            small = rhs
        } else {
            big = rhs
            small = lhs
        }
        
        var result: IntegerMagnitude = IntegerMagnitude([UInt64]())
        for i in 0..<small.bitWidth {
            if (small.getBit(pos: i)) {
                result += big << i;
            }
        }
        
        return result;
    }
    
    public static func *= (lhs: inout IntegerMagnitude, rhs: IntegerMagnitude) {
        lhs = lhs * rhs;
    }
    
    public static func / (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> IntegerMagnitude {
        return quotientAndRemainder(n: lhs, d: rhs).quotient
    }
    
    public static func /= (lhs: inout IntegerMagnitude, rhs: IntegerMagnitude) {
        lhs = lhs / rhs
    }
    
    public static func % (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> IntegerMagnitude {
        return quotientAndRemainder(n: lhs, d: rhs).remainder
    }
    
    public static func %= (lhs: inout IntegerMagnitude, rhs: IntegerMagnitude) {
        return lhs = lhs % rhs
    }
    
    public static func &= (lhs: inout IntegerMagnitude, rhs: IntegerMagnitude) {
        // TODO
    }
    
    public static func |= (lhs: inout IntegerMagnitude, rhs: IntegerMagnitude) {
        // TODO
    }
    
    public static func ^= (lhs: inout IntegerMagnitude, rhs: IntegerMagnitude) {
        // TODO
    }
    
    public static func quotientAndRemainder (n: IntegerMagnitude, d: IntegerMagnitude) -> (quotient: IntegerMagnitude, remainder: IntegerMagnitude) {
        
        if (d > n) {
            return (zero, n)
        } else if (n == d) {
            return (one, zero)
        }
        
        var q : IntegerMagnitude = zero
        var r : IntegerMagnitude = zero
        
        for i in (0..<n.bitWidth).reversed() {
            r = r << 1
            r = r.setBit(pos: 0, n.getBit(pos: i))
            
            if (r >= d) {
                r -= d
                q = q.setBit(pos: i, true)
            }
        }
        
        return (quotient: q, remainder: r)
    }
    
    // Stride
    public func distance(to other: IntegerMagnitude) -> Integer {
        return Integer(sign: self > other, mag: other - self)
    }
    
    public func advanced(by n: Integer) -> IntegerMagnitude {
        return n.sign ? self - n.magnitude : self + n.magnitude
    }
    
    // Comparison
    public static func compare (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> Int {
        if (lhs.isZero && rhs.isZero) {
            return 0
        }
        
        if (lhs.realWords.count > rhs.realWords.count) {
            return 1
        } else if (lhs.realWords.count > rhs.realWords.count) {
            return -1
        }
        
        for i in (0..<lhs.realWords.count).reversed() {
            if (lhs.realWords[i] > rhs.realWords[i]) {
                return 1
            } else if (rhs.realWords[i] > lhs.realWords[i]) {
                return -1
            }
        }
        
        return 0
    }
    
    public static func == (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> Bool {
        compare(lhs: lhs, rhs: rhs) == 0
    }
    
    public static func < (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> Bool {
        return compare(lhs: lhs, rhs: rhs) < 0
    }
    
    public static func <= (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> Bool {
        return compare(lhs: lhs, rhs: rhs) <= 0
    }
    
    public static func > (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> Bool {
        return compare(lhs: lhs, rhs: rhs) > 0
    }
    
    public static func >= (lhs: IntegerMagnitude, rhs: IntegerMagnitude) -> Bool {
        return compare(lhs: lhs, rhs: rhs) >= 0
    }
    
    // CASTING
    public var intValue : UInt32 {
        return UInt32(realWords[0] & 0xffffffff)
    }
    
    public var longValue : UInt64 {
        return UInt64(realWords[0]);
    }
    
    public var singleValue : Float {
        return Float(self.intValue)
    }
    
    public var doubleValue : Double {
        return Double(self.longValue)
    }
    
    public var decimalString : String {
        return longValue.description
    }
    
    public var binaryString : String {
        var result : String = ""
        
        for i in (0..<leftMostBit).reversed() {
            result += getBit(pos: i) ? "1" : "0"
        }
        
        return result;
    }
    
    // PRIVATE
    private static let longMask : Int64 = 0xffffffff
    
    private static let longRadix : [IntegerMagnitude] = [zero, zero,
            IntegerMagnitude([0x4000000000000000]), IntegerMagnitude([0x383d9170b85ff80b]),
            IntegerMagnitude([0x4000000000000000]), IntegerMagnitude([0x6765c793fa10079d]),
            IntegerMagnitude([0x41c21cb8e1000000]), IntegerMagnitude([0x3642798750226111]),
            IntegerMagnitude([0x1000000000000000]), IntegerMagnitude([0x12bf307ae81ffd59]),
            IntegerMagnitude([0xde0b6b3a7640000]), IntegerMagnitude([0x4d28cb56c33fa539]),
            IntegerMagnitude([0x1eca170c00000000]), IntegerMagnitude([0x780c7372621bd74d]),
            IntegerMagnitude([0x1e39a5057d810000]), IntegerMagnitude([0x5b27ac993df97701]),
            IntegerMagnitude([0x1000000000000000]), IntegerMagnitude([0x27b95e997e21d9f1]),
            IntegerMagnitude([0x5da0e1e53c5c8000]), IntegerMagnitude([0xb16a458ef403f19]),
            IntegerMagnitude([0x16bcc41e90000000]), IntegerMagnitude([0x2d04b7fdd9c0ef49]),
            IntegerMagnitude([0x5658597bcaa24000]), IntegerMagnitude([0x6feb266931a75b7]),
            IntegerMagnitude([0xc29e98000000000]), IntegerMagnitude([0x14adf4b7320334b9]),
            IntegerMagnitude([0x226ed36478bfa000]), IntegerMagnitude([0x383d9170b85ff80b]),
            IntegerMagnitude([0x5a3c23e39c000000]), IntegerMagnitude([0x4e900abb53e6b71]),
            IntegerMagnitude([0x7600ec618141000]), IntegerMagnitude([0xaee5720ee830681]),
            IntegerMagnitude([0x1000000000000000]), IntegerMagnitude([0x172588ad4f5f0981]),
            IntegerMagnitude([0x211e44f7d02c1000]), IntegerMagnitude([0x2ee56725f06e5c71]),
            IntegerMagnitude([0x41c21cb8e1000000])]
    
    private func trim () {
        while (self.realWords.count > 1 && self.realWords[realWords.count - 1] == 0) {
            self.realWords.remove(at: realWords.count - 1)
        }
    }
    
    private static func add (_x: [UInt64], _y: [UInt64]) -> [UInt64] {
        var x, y: [UInt64]
        
        if (_x.count < _y.count) {
            x = _y
            y = _x
        } else {
            x = _x
            y = _y
        }
        
        let xIndex = x.count;
        var result = [UInt64]()
        
        var carry : Bool = false;
        for i in 0..<xIndex {
            if (carry) {
                if x[i] < UINT64_MAX {
                    x[i] += 1
                    carry = false
                } else if (y[i] < UINT64_MAX) {
                    y[i] += 1
                    carry = false
                }
            }
            
            var sum = x[i].addingReportingOverflow(y[i])
            carry = sum.overflow

            result.append(sum.partialValue)
        }
        
        if (carry) {
            result.append(1)
        }
        
        return result;
    }
}
