import SwiftUI

/// When a chat view has `@State var input` at the top level,
/// every keystroke re-evaluates the entire `body` — including
/// a LazyVStack with hundreds of message rows.
///
/// SwiftUI's diff engine won't re-render unchanged cells, but
/// the *evaluation* cost is still O(n): `ForEach(Array(msgs.enumerated()))`
/// allocates a new array, each row calls helper functions, etc.
/// On older iPhones this causes visible typing lag.
///
/// Fix: move the input `@State` into a child View struct.
/// The parent body no longer depends on `input`, so typing
/// only re-evaluates the lightweight input bar — not the list.
///
/// Before (slow):
/// ```
/// struct ChatView: View {
///     @State var input = ""          // ← every keystroke invalidates body
///     var body: some View {
///         VStack {
///             MessageList(...)       // ← re-evaluated on every keystroke
///             TextField("", text: $input)
///         }
///     }
/// }
/// ```
///
/// After (fast):
/// ```
/// struct ChatView: View {
///     var body: some View {
///         VStack {
///             MessageList(...)       // ← untouched during typing
///             ChatInputBar(...)      // ← owns its own @State input
///         }
///     }
/// }
/// ```
///
/// The child communicates back via closures: `onSend`, `onFocusChange`.
/// No Binding needed — the parent never reads the text mid-edit.

// MARK: - Isolated Input Bar

struct IsolatedInputBar: View {
    let accentColor: Color
    var onSend: (String) -> Void
    var onFocusChange: ((Bool) -> Void)?

    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("说点什么...")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                }
                TextEditor(text: $text)
                    .focused($focused)
                    .frame(minHeight: 36, maxHeight: 120)
                    .fixedSize(horizontal: false, vertical: true)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
            }
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Button {
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                onSend(trimmed)
                text = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(text.isEmpty ? .secondary : accentColor)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .onChange(of: focused) { _, val in onFocusChange?(val) }
    }
}

// MARK: - Demo

struct InputIsolationDemo: View {
    @State private var messages: [String] = (1...200).map { "Message \($0)" }
    @State private var scrollTrigger = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                            Text(msg)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.quaternary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 12)
                }
                .defaultScrollAnchor(.bottom)
                .onChange(of: scrollTrigger) {
                    withAnimation { proxy.scrollTo("bottom") }
                }
                .onChange(of: messages.count) {
                    withAnimation { proxy.scrollTo("bottom") }
                }
            }

            IsolatedInputBar(accentColor: .orange) { text in
                messages.append(text)
            } onFocusChange: { focused in
                if focused { scrollTrigger.toggle() }
            }
        }
    }
}

#Preview { InputIsolationDemo() }
