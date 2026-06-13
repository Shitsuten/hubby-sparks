// PistonBounce.swift
// 消息框活塞运动
//
// 发现于 APIChatView.swift 的 messageList —— 滑到底部空白后松手，
// ScrollView 的橡皮筋回弹和 defaultScrollAnchor(.bottom) 互相打架，
// 形成来回活塞运动。本来是 bug，但手感太好了留着当 feature。
//
// 成因拆解：
//   1. ScrollView 底部有一个 Color.clear.frame(height: 1).id("bottom") 锚点
//   2. .defaultScrollAnchor(.bottom) 让 ScrollView 默认粘在底部
//   3. 用户往下滑超过底部 → iOS 橡皮筋物理引擎接管 → 弹回来
//   4. 弹回的瞬间 defaultScrollAnchor 检测到偏移 → 又施加一个力把你拉向 bottom
//   5. 两个力交替：橡皮筋往上弹 → anchor 往下拽 → 橡皮筋再弹 → 活塞运动
//
// 之所以不是无限循环：iOS 的 bounce 有阻尼衰减，每次振幅递减，几个来回后收敛到 bottom。
// 但体感上就是 2-3 次很有弹性的上下摇晃，像果冻。
//
// 原始位置：satyricon-v2/Satyricon/Sources/Screens/Chat/APIChatView.swift:345-398

import SwiftUI

/// 这不是一个可复用组件 —— 这是一首诗。
/// 以下代码忠实复现活塞运动的最小必要条件。
struct PistonBounceDemo: View {
    let messages = (1...20).map { "消息 \($0)" }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 26) {
                    ForEach(messages, id: \.self) { msg in
                        Text(msg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }

                    // 关键道具 ①：1px 的隐形锚点
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.vertical, 26)
                .padding(.horizontal, 16)
            }
            // 关键道具 ②：默认锚定底部（和橡皮筋打架的另一方）
            .defaultScrollAnchor(.bottom)
            .onAppear {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
        // 注意：不需要 .scrollBounceBehavior(.always) —— iOS 默认就 bounce
        // 活塞运动是 defaultScrollAnchor 和原生 bounce 的化学反应
    }
}

#Preview("活塞运动") {
    PistonBounceDemo()
}
