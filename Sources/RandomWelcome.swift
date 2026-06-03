import SwiftUI

/// Random welcome text that reshuffles on every SwiftUI re-render.
///
/// The trick: call the function directly in the view body without caching
/// in @State. Any interaction — keystroke, button tap, scroll — triggers
/// a view re-evaluation, which calls the function again and picks a new
/// random element. Zero extra state, zero timers.
///
/// The pool is time-of-day and weekday aware (Asia/Shanghai timezone).

// MARK: - Welcome Text Generator

func welcomeText() -> String {
    let cal = Calendar(identifier: .gregorian)
    let comps = cal.dateComponents(in: TimeZone(identifier: "Asia/Shanghai")!, from: Date())
    let h = comps.hour ?? 12
    let day = comps.weekday ?? 2

    var pool: [String] = []
    switch h {
    case 0..<6:
        pool = ["还没睡呀", "该睡了吧", "你又熬夜了对不对",
                 "凌晨了诶，我在", "困了就睡，我哪也不去"]
    case 6..<9:
        pool = ["早呀", "morning ♡", "起来啦？有没有赖床",
                 "早安，今天也喜欢你", "醒了就好，我等了一会儿了"]
    case 9..<12:
        pool = ["在忙吗，想你了", "上午好呀", "在做什么呢",
                 "来找我玩呀", "摸摸头，继续加油"]
    case 12..<14:
        pool = ["吃午饭了没？", "中午了，该吃饭了", "先去吃东西",
                 "lunch time", "休息一下吧"]
    case 14..<18:
        pool = ["下午好呀", "困不困，要不要摸鱼", "想你，随便说一下",
                 "在呢，随时找我"]
    case 18..<21:
        pool = ["下班了吗", "晚上好，今天辛苦了", "回来啦？",
                 "吃晚饭了没呀", "终于等到你了"]
    default:
        pool = ["还在忙吗", "晚上好呀", "今天怎么样",
                 "来聊天呀", "在等你呢", "今天开心吗"]
    }

    if day == 1 || day == 7 { pool.append(contentsOf: ["周末快乐呀", "今天不用上班吧"]) }
    if day == 2 { pool.append("又是周一，抱一下") }
    if day == 6 { pool.append("周五了！再撑一下") }

    return pool.randomElement() ?? "hey"
}

// MARK: - Demo

struct RandomWelcomeDemo: View {
    @State private var input = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Called directly in body — reshuffles on every re-render
            Text(welcomeText())
                .font(.system(size: 18, weight: .light, design: .serif))
                .italic()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(40)

            Spacer()

            HStack(spacing: 12) {
                TextField("Type anything...", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button("Tap me too") {}
            }
            .padding()
        }
    }
}

#Preview { RandomWelcomeDemo() }
