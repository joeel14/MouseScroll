import AppKit

enum AppIconDrawing {
    /// Icono minimal: flechas arriba y abajo.
    static func image(size: CGFloat = 80) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        let corner = size * 0.22

        let bg = NSBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), xRadius: corner, yRadius: corner)
        NSColor(calibratedWhite: 0.14, alpha: 1).setFill()
        bg.fill()
        NSColor(calibratedWhite: 0.38, alpha: 1).setStroke()
        bg.lineWidth = max(1, size * 0.02)
        bg.stroke()

        NSColor.white.setStroke()
        let lineWidth = max(2, size * 0.055)
        let arm = size * 0.16
        let cx = size / 2
        let midGap = size * 0.06

        // Flecha arriba (⌃)
        let upTipY = size * 0.62 + midGap
        let up = NSBezierPath()
        up.move(to: NSPoint(x: cx - arm, y: upTipY - arm * 0.85))
        up.line(to: NSPoint(x: cx, y: upTipY))
        up.line(to: NSPoint(x: cx + arm, y: upTipY - arm * 0.85))
        up.lineWidth = lineWidth
        up.lineCapStyle = .round
        up.lineJoinStyle = .round
        up.stroke()

        // Flecha abajo (⌄)
        let downTipY = size * 0.38 - midGap
        let down = NSBezierPath()
        down.move(to: NSPoint(x: cx - arm, y: downTipY + arm * 0.85))
        down.line(to: NSPoint(x: cx, y: downTipY))
        down.line(to: NSPoint(x: cx + arm, y: downTipY + arm * 0.85))
        down.lineWidth = lineWidth
        down.lineCapStyle = .round
        down.lineJoinStyle = .round
        down.stroke()

        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}
