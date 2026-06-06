// Renders the .dmg window background at a given scale: app name, a
// drag-to-install arrow, and a hint line. Designed in 540x400 points with the
// title and hint given equal padding from the top and bottom edges. Pass a
// scale (1 or 2) to render 1x (540x400) or 2x (1080x800) for a HiDPI TIFF.
// Run: swift make-background.swift <output.png> [scale]
import AppKit

let W = 540.0, H = 400.0
let PAD = 40.0   // equal gap from the top edge (to the title) and bottom edge (to the hint)
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "background.png"
let scale = CommandLine.arguments.count > 2 ? (Double(CommandLine.arguments[2]) ?? 1.0) : 1.0
let pw = Int(W * scale), ph = Int(H * scale)

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!

NSGraphicsContext.saveGraphicsState()
let gctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = gctx
gctx.cgContext.scaleBy(x: scale, y: scale)   // design in points, render at scale
let ctx = gctx.cgContext

// Soft vertical gradient background (light gray -> white)
let cs = CGColorSpaceCreateDeviceRGB()
let grad = CGGradient(colorsSpace: cs,
    colors: [CGColor(srgbRed: 0.957, green: 0.957, blue: 0.969, alpha: 1),
             CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)] as CFArray,
    locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])

let brand = NSColor(srgbRed: 0.913, green: 0.420, blue: 0.169, alpha: 1)
func centerX(_ s: NSAttributedString) -> Double { (W - s.size().width) / 2 }

// Title: its top edge sits PAD below the top of the canvas.
// draw(at:) places the text's bottom-left, so bottom-y = top - lineHeight.
let title = NSAttributedString(string: "HarvestPlus", attributes: [
    .font: NSFont.systemFont(ofSize: 26, weight: .semibold),
    .foregroundColor: NSColor(white: 0.13, alpha: 1)])
title.draw(at: NSPoint(x: centerX(title), y: H - PAD - title.size().height))

// Hint: its bottom edge sits PAD above the bottom of the canvas.
let hint = NSAttributedString(string: "To install, drag the app onto the Applications folder", attributes: [
    .font: NSFont.systemFont(ofSize: 12, weight: .regular),
    .foregroundColor: NSColor(white: 0.46, alpha: 1)])
hint.draw(at: NSPoint(x: centerX(hint), y: PAD))

// Drag arrow, aligned with the icon row (icons sit at window-y 185 = CG-y 215)
let y = 215.0
brand.setStroke(); brand.setFill()
let shaft = NSBezierPath()
shaft.lineWidth = 7
shaft.lineCapStyle = .round
shaft.move(to: NSPoint(x: 226, y: y))
shaft.line(to: NSPoint(x: 300, y: y))
shaft.stroke()
let head = NSBezierPath()
head.move(to: NSPoint(x: 296, y: y + 13))
head.line(to: NSPoint(x: 322, y: y))
head.line(to: NSPoint(x: 296, y: y - 13))
head.close()
head.fill()

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to encode PNG\n".data(using: .utf8)!)
    exit(1)
}
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath) (\(pw)x\(ph))")
