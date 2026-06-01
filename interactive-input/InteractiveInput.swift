import SwiftUI

/// A chat input bar where swiping down on the message list
/// interactively dismisses the keyboard — and the text cursor
/// follows the gesture smoothly instead of snapping.
///
/// Key techniques:
/// - `.scrollDismissesKeyboard(.interactively)` on the ScrollView
///   makes the keyboard track the drag gesture in real time.
/// - `TextEditor` with `.fixedSize(horizontal: false, vertical: true)`
///   auto-grows up to a max height as the user types multi-line.
/// - A `ZStack` placeholder overlay disappears when text is non-empty
///   (TextEditor doesn't support native placeholder).
/// - `@FocusState` lets you programmatically grab/release focus,
///   e.g. scroll-to-bottom when the keyboard appears.

struct InteractiveInputDemo: View {
    @State private var messages: [String] = [
        "hey", "what's up", "not much, just vibing",
        "nice", "want to grab coffee?", "sure, when?",
        "tomorrow morning?", "sounds good", "see you then"
    ]
    @State private var input = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { i, msg in
                            let isUser = i % 2 == 0
                            HStack {
                                if isUser { Spacer(minLength: 60) }
                                Text(msg)
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(isUser ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(isUser ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                if !isUser { Spacer(minLength: 60) }
                            }
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(12)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) {
                    withAnimation { proxy.scrollTo("bottom") }
                }
                .onChange(of: inputFocused) {
                    if inputFocused {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation { proxy.scrollTo("bottom") }
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    if input.isEmpty {
                        Text("Message...")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                    }
                    TextEditor(text: $input)
                        .focused($inputFocused)
                        .frame(minHeight: 36, maxHeight: 120)
                        .fixedSize(horizontal: false, vertical: true)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                    let text = input.trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { return }
                    messages.append(text)
                    input = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(input.isEmpty ? .secondary : .blue)
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    InteractiveInputDemo()
}
