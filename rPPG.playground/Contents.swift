import Foundation
import Accelerate

//load file
let fileURL = Bundle.main.url(forResource: "colorSignal", withExtension: "txt")!
let data = try! String(contentsOf: fileURL, encoding: .utf8)

let rgbStrings = data.components(separatedBy: "\n")
let xs = rgbStrings.map{$0.components(separatedBy: ";").compactMap{Float($0)}}.filter{!$0.isEmpty}

let red = xs.map{$0[0]}
let green = xs.map{$0[1]}
let blue = xs.map{$0[2]}

let n = red.count

func fft(signal:[Float]) -> (real:[Float], imaginary:[Float]) {
    let count = n / 2
    var realParts = [Float](repeating: 0,
                            count: count)
    var imagParts = [Float](repeating: 0,
                            count: count)

    realParts.withUnsafeMutableBufferPointer { realPtr in
        imagParts.withUnsafeMutableBufferPointer { imagPtr in
            
            var complexSignal = DSPSplitComplex(realp: realPtr.baseAddress!,
                                                imagp: imagPtr.baseAddress!)
                   
            signal.withUnsafeBytes {
                vDSP.convert(interleavedComplexVector: [DSPComplex]($0.bindMemory(to: DSPComplex.self)),
                             toSplitComplexVector: &complexSignal)
            }
            
            let log2n = vDSP_Length(log2(Float(n)))
            let fft = vDSP.FFT(log2n: log2n,
                               radix: .radix2,
                               ofType: DSPSplitComplex.self)
            
            fft?.forward(input: complexSignal,
                         output: &complexSignal)
        }
    }
    return (realParts, imagParts)
}
red.map{$0}
fft(signal: red).imaginary.map{abs($0).squareRoot()}

let window = vDSP.window(ofType: Float.self,
                         usingSequence: .hanningDenormalized,
                         count: n,
                         isHalfWindow: false) //?
let windowed = vDSP.multiply(red, window)
windowed.map{$0}
fft(signal: windowed).imaginary.map{abs($0).squareRoot()}

