import AppKit
import CoreText

let workspace = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let fontURL = workspace.appendingPathComponent("Potential Scanner/Resources/Fonts/Sam3KRFont.ttf")
let outputURL = workspace.appendingPathComponent("Brand/yowenomo-studio-logo.png")

guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil) else {
    fputs("Could not register Sam3KRFont.ttf\n", stderr)
    exit(1)
}

let candidates = ["Sam3KRFont", "Sam3KR", "Sam3 KR Font"]
guard let logoFont = candidates.compactMap({ NSFont(name: $0, size: 132) }).first else {
    fputs("Could not resolve the registered Sam3 font name\n", stderr)
    exit(1)
}

let canvasSize = NSSize(width: 1600, height: 480)
let image = NSImage(size: canvasSize)
image.lockFocus()

NSColor.clear.setFill()
NSRect(origin: .zero, size: canvasSize).fill()

let phrase = "yowenomo studio"
let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center

let baseAttributes: [NSAttributedString.Key: Any] = [
    .font: logoFont,
    .foregroundColor: NSColor(calibratedRed: 17/255, green: 20/255, blue: 24/255, alpha: 1),
    .paragraphStyle: paragraph,
    .kern: 2
]
let signalAttributes: [NSAttributedString.Key: Any] = [
    .font: logoFont,
    .foregroundColor: NSColor(calibratedRed: 5/255, green: 99/255, blue: 250/255, alpha: 1),
    .paragraphStyle: paragraph,
    .kern: 2
]

let measure = phrase.size(withAttributes: baseAttributes)
let originX = (canvasSize.width - measure.width) / 2
let originY = (canvasSize.height - measure.height) / 2 + 18
let textRect = NSRect(x: originX, y: originY, width: measure.width + 10, height: measure.height + 10)

phrase.draw(in: textRect.offsetBy(dx: 9, dy: -9), withAttributes: signalAttributes)
phrase.draw(in: textRect, withAttributes: baseAttributes)

let underlineY = originY - 26
let underline = NSBezierPath()
underline.move(to: NSPoint(x: originX + 2, y: underlineY))
underline.line(to: NSPoint(x: originX + measure.width - 2, y: underlineY))
underline.lineWidth = 8
NSColor(calibratedRed: 57/255, green: 1, blue: 20/255, alpha: 1).setStroke()
underline.stroke()

let endBlock = NSRect(x: originX + measure.width + 18, y: underlineY - 4, width: 18, height: 18)
NSColor(calibratedRed: 1, green: 138/255, blue: 0, alpha: 1).setFill()
endBlock.fill()

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [.compressionFactor: 1])
else {
    fputs("Could not encode PNG\n", stderr)
    exit(1)
}

try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try png.write(to: outputURL)
print(outputURL.path)
