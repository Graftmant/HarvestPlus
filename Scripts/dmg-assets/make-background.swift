// Renders the .dmg window background: app name, a drag-to-install arrow, and a
// hint line. Output is a 600x400 PNG matching the dmgbuild window size.
// Run: swift make-background.swift <output.png>
import AppKit

let W = 600.0, H = 400.0
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "background.png"

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(W), pixelsHigh: Int(H),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext

// Soft vertical gradient background (light gray -> white)
let cs = CGColorSpaceCreateDeviceRGB()
let grad = CGGradient(colorsSpace: cs,
    colors: [CGColor(srgbRed: 0.957, green: 0.957, blue: 0.969, alpha: 1),
             CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)] as CFArray,
    locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])

let brand = NSColor(srgbRed: 0.913, green: 0.420, blue: 0.169, alpha: 1)

func drawCentered(_ s: String, font: NSFont, color: NSColor, y: Double) {
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    let str = NSAttributedString(string: s, attributes: attrs)
    let sz = str.size()
    str.draw(at: NSPoint(x: (W - sz.width) / 2, y: y))
}

// Title + hint (CoreGraphics origin is bottom-left)
drawCentered("HarvestPlus", font: .systemFont(ofSize: 30, weight: .semibold),
             color: NSColor(white: 0.13, alpha: 1), y: H - 70)
drawCentered("To install, drag the app onto the Applications folder",
             font: .systemFont(ofSize: 13, weight: .regular),
             color: NSColor(white: 0.46, alpha: 1), y: 38)

// Drag arrow, centered between the two icon slots (icons sit at x=160 and x=440)
let y = 200.0
brand.setStroke(); brand.setFill()
let shaft = NSBezierPath()
shaft.lineWidth = 7
shaft.lineCapStyle = .round
shaft.move(to: NSPoint(x: 250, y: y))
shaft.line(to: NSPoint(x: 330, y: y))
shaft.stroke()
let head = NSBezierPath()
head.move(to: NSPoint(x: 324, y: y + 14))
head.line(to: NSPoint(x: 352, y: y))
head.line(to: NSPoint(x: 324, y: y - 14))
head.close()
head.fill()

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to encode PNG\n".data(using: .utf8)!)
    exit(1)
}
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath) (\(Int(W))x\(Int(H)))")
