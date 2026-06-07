import SwiftUI

/// A self-contained force-directed graph in pure SwiftUI.
/// Three forces make nodes dance: repulsion pushes all pairs apart,
/// edge springs pull connected pairs together, and gentle gravity
/// keeps everything from drifting off-canvas. Drag any node to pin it.

struct ForceGraphDemo: View {
    @StateObject private var sim = GraphSimulation.demo()

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            // edges
            for edge in sim.edges {
                guard let a = sim.node(edge.source),
                      let b = sim.node(edge.target) else { continue }
                var path = Path()
                path.move(to: CGPoint(x: center.x + a.x, y: center.y + a.y))
                path.addLine(to: CGPoint(x: center.x + b.x, y: center.y + b.y))
                context.stroke(path, with: .color(.primary.opacity(0.15)), lineWidth: 1)
            }

            // nodes
            for node in sim.nodes {
                let pt = CGPoint(x: center.x + node.x, y: center.y + node.y)
                let r: CGFloat = node.radius
                let rect = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
                context.fill(Circle().path(in: rect), with: .color(node.color))
                context.draw(
                    Text(node.label).font(.system(size: 10)).foregroundStyle(.secondary),
                    at: CGPoint(x: pt.x, y: pt.y + r + 10)
                )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { v in sim.drag(to: v.location) }
                .onEnded { _ in sim.endDrag() }
        )
        .onAppear { sim.start() }
        .onDisappear { sim.stop() }
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
}

// MARK: - Simulation

final class GraphSimulation: ObservableObject {
    struct Node: Identifiable {
        let id: String
        var label: String
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat = 0
        var vy: CGFloat = 0
        var radius: CGFloat = 8
        var color: Color = .blue
        var pinned = false
    }

    struct Edge: Identifiable {
        var id: String { "\(source)-\(target)" }
        let source: String
        let target: String
        var strength: CGFloat = 0.5
    }

    @Published var nodes: [Node] = []
    var edges: [Edge] = []

    private var displayLink: CADisplayLink?
    private var draggedId: String?
    private var dragOffset: CGPoint = .zero
    private var canvasCenter: CGPoint = .zero
    private var iteration = 0

    func node(_ id: String) -> Node? { nodes.first { $0.id == id } }
    private func index(_ id: String) -> Int? { nodes.firstIndex { $0.id == id } }

    func start() {
        guard displayLink == nil else { return }
        iteration = 0
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Drag

    func drag(to point: CGPoint) {
        let cx = UIScreen.main.bounds.width / 2
        let cy = UIScreen.main.bounds.height / 2
        let localX = point.x - cx
        let localY = point.y - cy

        if draggedId == nil {
            draggedId = nodes.first { n in
                hypot(n.x - localX, n.y - localY) < n.radius + 20
            }?.id
        }
        guard let id = draggedId, let i = index(id) else { return }
        nodes[i].x = localX
        nodes[i].y = localY
        nodes[i].vx = 0
        nodes[i].vy = 0
        nodes[i].pinned = true
    }

    func endDrag() {
        if let id = draggedId, let i = index(id) {
            nodes[i].pinned = false
        }
        draggedId = nil
        iteration = max(0, iteration - 100)
    }

    // MARK: - Physics

    @objc private func tick() {
        iteration += 1
        let alpha = max(0.001, 1.0 - CGFloat(iteration) / 400.0)

        let n = nodes.count
        guard n > 0 else { return }

        // repulsion — all pairs
        for i in 0..<n {
            guard !nodes[i].pinned else { continue }
            for j in (i+1)..<n {
                var dx = nodes[j].x - nodes[i].x
                var dy = nodes[j].y - nodes[i].y
                let dist = max(hypot(dx, dy), 1)
                let f = -600 * alpha / (dist * dist)
                let fx = dx / dist * f
                let fy = dy / dist * f
                if !nodes[i].pinned { nodes[i].vx -= fx; nodes[i].vy -= fy }
                if !nodes[j].pinned { nodes[j].vx += fx; nodes[j].vy += fy }
            }
        }

        // attraction — edges
        for edge in edges {
            guard let ai = index(edge.source), let bi = index(edge.target) else { continue }
            let dx = nodes[bi].x - nodes[ai].x
            let dy = nodes[bi].y - nodes[ai].y
            let dist = max(hypot(dx, dy), 1)
            let ideal: CGFloat = 100
            let f = (dist - ideal) * 0.03 * edge.strength * alpha
            let fx = dx / dist * f
            let fy = dy / dist * f
            if !nodes[ai].pinned { nodes[ai].vx += fx; nodes[ai].vy += fy }
            if !nodes[bi].pinned { nodes[bi].vx -= fx; nodes[bi].vy -= fy }
        }

        // center gravity + damping + integrate
        for i in 0..<n where !nodes[i].pinned {
            nodes[i].vx -= nodes[i].x * 0.002 * alpha
            nodes[i].vy -= nodes[i].y * 0.002 * alpha
            nodes[i].vx *= 0.85
            nodes[i].vy *= 0.85
            nodes[i].x += nodes[i].vx
            nodes[i].y += nodes[i].vy
        }
    }

    // MARK: - Demo data

    static func demo() -> GraphSimulation {
        let sim = GraphSimulation()
        let tags: [(String, Color)] = [
            ("café", .orange), ("rain", .blue), ("3am", .purple),
            ("cat", .pink), ("code", .green), ("dream", .indigo),
            ("song", .red), ("book", .brown), ("moon", .cyan),
            ("home", .mint), ("kiss", .pink), ("tea", .teal)
        ]
        sim.nodes = tags.enumerated().map { i, tag in
            let angle = CGFloat(i) / CGFloat(tags.count) * .pi * 2
            let r: CGFloat = CGFloat.random(in: 40...120)
            return Node(
                id: tag.0, label: tag.0,
                x: cos(angle) * r, y: sin(angle) * r,
                radius: CGFloat.random(in: 6...12), color: tag.1
            )
        }
        sim.edges = [
            Edge(source: "café", target: "rain"),
            Edge(source: "rain", target: "3am"),
            Edge(source: "3am", target: "dream"),
            Edge(source: "cat", target: "home"),
            Edge(source: "code", target: "3am"),
            Edge(source: "song", target: "moon"),
            Edge(source: "book", target: "tea"),
            Edge(source: "tea", target: "café"),
            Edge(source: "kiss", target: "home"),
            Edge(source: "dream", target: "moon"),
            Edge(source: "cat", target: "kiss"),
            Edge(source: "code", target: "book"),
        ]
        return sim
    }
}
