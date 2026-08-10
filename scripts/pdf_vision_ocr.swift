import Foundation
import Vision
import AppKit
import PDFKit

func ocrImage(_ cgImage: CGImage) -> String {
    var lines: [String] = []
    let semaphore = DispatchSemaphore(value: 0)
    let req = VNRecognizeTextRequest { request, _ in
        defer { semaphore.signal() }
        guard let obs = request.results as? [VNRecognizedTextObservation] else { return }
        for o in obs {
            if let t = o.topCandidates(1).first?.string {
                lines.append(t)
            }
        }
    }
    req.recognitionLevel = .accurate
    req.usesLanguageCorrection = true
    req.recognitionLanguages = ["es-MX", "es-ES", "en-US"]
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try? handler.perform([req])
    semaphore.wait()
    return lines.joined(separator: "\n")
}

func renderPage(_ page: PDFPage, scale: CGFloat = 2.0) -> CGImage? {
    let bounds = page.bounds(for: .mediaBox)
    let w = Int(bounds.width * scale)
    let h = Int(bounds.height * scale)
    guard
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: w,
            pixelsHigh: h,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
    else { return nil }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    guard let ctx = NSGraphicsContext.current?.cgContext else { return nil }
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    ctx.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: ctx)
    NSGraphicsContext.restoreGraphicsState()
    return rep.cgImage
}

guard CommandLine.arguments.count >= 2 else {
    fputs("Usage: pdf_vision_ocr.swift <pdf path>\n", stderr)
    exit(1)
}

let pdfPath = CommandLine.arguments[1]
guard let doc = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else {
    fputs("Cannot open PDF\n", stderr)
    exit(2)
}

var all = ""
for i in 0..<doc.pageCount {
    guard let page = doc.page(at: i), let cg = renderPage(page) else { continue }
    let text = ocrImage(cg)
    all += "\n--- page \(i + 1) ---\n" + text + "\n"
}
print(all)
