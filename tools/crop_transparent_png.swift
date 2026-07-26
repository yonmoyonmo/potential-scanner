import AppKit

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: crop_transparent_png <input.png> <output.png>\n", stderr)
    exit(1)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard
    let inputData = try? Data(contentsOf: inputURL),
    let source = NSBitmapImageRep(data: inputData)
else {
    fputs("Could not read input PNG\n", stderr)
    exit(1)
}

var minX = source.pixelsWide
var minY = source.pixelsHigh
var maxX = -1
var maxY = -1

for y in 0..<source.pixelsHigh {
    for x in 0..<source.pixelsWide {
        guard let color = source.colorAt(x: x, y: y), color.alphaComponent > 0 else { continue }
        minX = min(minX, x)
        minY = min(minY, y)
        maxX = max(maxX, x)
        maxY = max(maxY, y)
    }
}

guard maxX >= minX, maxY >= minY else {
    fputs("Input PNG is fully transparent\n", stderr)
    exit(1)
}

let cropWidth = maxX - minX + 1
let cropHeight = maxY - minY + 1

guard let cropped = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: cropWidth,
    pixelsHigh: cropHeight,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Could not create output bitmap\n", stderr)
    exit(1)
}

for y in 0..<cropHeight {
    for x in 0..<cropWidth {
        if let color = source.colorAt(x: minX + x, y: minY + y) {
            cropped.setColor(color, atX: x, y: y)
        }
    }
}

guard let png = cropped.representation(using: .png, properties: [.compressionFactor: 1]) else {
    fputs("Could not encode cropped PNG\n", stderr)
    exit(1)
}

try png.write(to: outputURL)
print("\(source.pixelsWide)x\(source.pixelsHigh), bbox=(\(minX),\(minY))–(\(maxX),\(maxY)) -> \(cropWidth)x\(cropHeight)")
