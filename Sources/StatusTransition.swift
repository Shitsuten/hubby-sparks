import SwiftUI

/// A connection status indicator that transitions between states
/// with a rolling `.numericText()` animation. The prefix symbol
/// and label text morph smoothly instead of cutting.
///
/// Key technique: `.contentTransition(.numericText())` on both
/// the prefix and the label, with `.animation(.easeInOut)` keyed
/// on the text value. SwiftUI cross-fades each character slot.

struct StatusBar: View {
    let isConnected: Bool
    let isThinking: Bool
    let reconnectAttempts: Int

    var body: some View {
        HStack(spacing: 0) {
            Text(prefix)
                .fontWeight(.medium)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .tracking(2)
                .contentTransition(.numericText())
        }
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(color)
        .animation(.easeInOut(duration: 0.3), value: label)
        .animation(.easeInOut(duration: 0.3), value: isConnected)
    }

    private var prefix: String {
        isConnected ? "+ " : "— "
    }

    private var label: String {
        if !isConnected {
            if reconnectAttempts > 3 { return "network error" }
            if reconnectAttempts > 0 { return "reconnecting" }
            return "connecting"
        }
        if isThinking { return "thinking" }
        return "connected"
    }

    private var color: Color {
        if !isConnected { return .secondary }
        return .green
    }
}

// MARK: - Demo

#Preview {
    @Previewable @State var connected = false
    @Previewable @State var thinking = false
    @Previewable @State var attempts = 0

    VStack(spacing: 30) {
        StatusBar(
            isConnected: connected,
            isThinking: thinking,
            reconnectAttempts: attempts
        )

        HStack(spacing: 12) {
            Button("Toggle Connection") {
                connected.toggle()
                if !connected { attempts += 1 }
            }
            Button("Toggle Thinking") {
                thinking.toggle()
            }
        }
        .font(.caption)
    }
    .padding()
}
