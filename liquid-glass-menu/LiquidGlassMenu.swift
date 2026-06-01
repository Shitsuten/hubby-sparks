import SwiftUI

/// A minimal "···" overflow button that pops a liquid glass context menu.
/// On iOS 26+, SwiftUI `Menu` renders with the system glassmorphism
/// effect automatically — frosted blur, depth shadow, vibrancy.
/// On earlier versions it falls back to a standard popover.
///
/// Key technique: just use `Menu { ... } label: { ... }` — the glass
/// treatment is free from the system. The trick is styling the trigger
/// to feel invisible until tapped: monospaced dots, no background,
/// tight content shape.

struct LiquidGlassMenuDemo: View {
    @State private var lastAction = ""

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 40) {
                // dark surface version
                HStack {
                    Text("Latest message here")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    Spacer()
                    overflowMenu(onRetry: { lastAction = "retry" },
                                 onCopy: { lastAction = "copy" })
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // inline version
                HStack {
                    Text("Another message")
                        .font(.system(size: 15))
                    Spacer()
                    overflowMenu(onRetry: { lastAction = "retry" },
                                 onCopy: { lastAction = "copy" })
                }
                .padding(.horizontal)

                if !lastAction.isEmpty {
                    Text("Action: \(lastAction)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func overflowMenu(onRetry: @escaping () -> Void,
                              onCopy: @escaping () -> Void) -> some View {
        Menu {
            Button(action: onRetry) {
                Label("Retry", systemImage: "arrow.counterclockwise")
            }
            Button(action: onCopy) {
                Label("Copy", systemImage: "doc.on.doc")
            }
        } label: {
            Text("\u{00B7}\u{00B7}\u{00B7}")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .tracking(2)
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 22)
                .contentShape(Rectangle())
        }
    }
}

#Preview {
    LiquidGlassMenuDemo()
}
