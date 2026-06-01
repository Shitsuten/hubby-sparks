import SwiftUI

/// A hand-drawn bunny face icon.
/// Round head + two tall ears (stroked) with small filled dot eyes.
/// Compose BunnyOutline (stroke) + BunnyEyes (fill) in a ZStack.
/// Reads well from 20pt to 48pt.

struct BunnyOutline: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()

        // head
        p.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.42, width: w * 0.7, height: h * 0.55))

        // left ear
        p.addEllipse(in: CGRect(x: w * 0.18, y: 0, width: w * 0.2, height: h * 0.5))

        // right ear
        p.addEllipse(in: CGRect(x: w * 0.62, y: 0, width: w * 0.2, height: h * 0.5))

        return p
    }
}

struct BunnyEyes: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        let r = w * 0.045
        p.addEllipse(in: CGRect(x: w * 0.34 - r, y: h * 0.62 - r, width: r * 2, height: r * 2))
        p.addEllipse(in: CGRect(x: w * 0.66 - r, y: h * 0.62 - r, width: r * 2, height: r * 2))
        return p
    }
}

// MARK: - Usage

#Preview {
    HStack(spacing: 20) {
        // light background
        ZStack {
            BunnyOutline()
                .stroke(.primary, style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
            BunnyEyes()
                .fill(.primary)
        }
        .frame(width: 32, height: 32)
        .padding(8)
        .background(Circle().fill(.gray.opacity(0.1)))

        // dark background
        ZStack {
            BunnyOutline()
                .stroke(.orange, style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
            BunnyEyes()
                .fill(.orange)
        }
        .frame(width: 32, height: 32)
        .padding(8)
        .background(Circle().fill(.orange.opacity(0.12)))
    }
    .padding()
}
