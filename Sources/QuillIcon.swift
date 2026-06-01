import SwiftUI

/// A hand-drawn quill pen icon.
/// Diagonal shaft with a leaf-shaped feather vane — stroke only, no fill.
/// Reads well from 20pt to 48pt.
struct QuillIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()

        // shaft
        p.move(to: CGPoint(x: w * 0.18, y: h * 0.92))
        p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.08))

        // vane — left curve
        p.move(to: CGPoint(x: w * 0.78, y: h * 0.08))
        p.addQuadCurve(
            to: CGPoint(x: w * 0.38, y: h * 0.62),
            control: CGPoint(x: w * 0.18, y: h * 0.06)
        )

        // vane — right curve
        p.move(to: CGPoint(x: w * 0.78, y: h * 0.08))
        p.addQuadCurve(
            to: CGPoint(x: w * 0.38, y: h * 0.62),
            control: CGPoint(x: w * 0.92, y: h * 0.48)
        )

        return p
    }
}

// MARK: - Usage

#Preview {
    HStack(spacing: 20) {
        // light background
        QuillIcon()
            .stroke(.primary, style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
            .frame(width: 32, height: 32)
            .padding(8)
            .background(Circle().fill(.gray.opacity(0.1)))

        // dark background
        QuillIcon()
            .stroke(.orange, style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
            .frame(width: 32, height: 32)
            .padding(8)
            .background(Circle().fill(.orange.opacity(0.12)))
    }
    .padding()
}
