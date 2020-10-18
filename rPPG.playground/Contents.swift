import Foundation

//load file
let fileURL = Bundle.main.url(forResource: "colorSignal", withExtension: "txt")!
let data = try! String(contentsOf: fileURL, encoding: .utf8)

let rgbStrings = data.components(separatedBy: "\n")
let xs = rgbStrings.map{$0.components(separatedBy: ";").compactMap{Float($0)}}.filter{!$0.isEmpty}
print(xs)
let red = xs.map{$0[0]}
let green = xs.map{$0[1]}
let blue = xs.map{$0[2]}
