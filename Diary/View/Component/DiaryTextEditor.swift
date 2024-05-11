import SwiftUI

struct DiaryTextEditor: View {
    @EnvironmentObject private var textOptions: TextOptions

    @Binding var bodyText: String
    @State private var height: CGFloat = .zero

    var isOverMaxBodyText: Bool {
        bodyText.count > Item.textRange.upperBound
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("文字数: \(bodyText.count) / \(Item.textRange.upperBound)")
                .font(.system(size: 12))
                .foregroundStyle(isOverMaxBodyText ? .red : .gray)
                .padding(.horizontal, 8)

            ZStack(alignment: .topLeading) {
                ZStack(alignment: .leading) {
                    // TextEditorの高さを動的に変えるために裏でTextを透明で表示しその高さをTextEditoに設定する
                    Text(bodyText)
                        .foregroundColor(.clear)
                        .padding(.vertical, 12)
                        .background {
                            GeometryReader {
                                Color.clear.preference(
                                    key: ViewHeightKey.self,
                                    value: $0.frame(in: .local).size.height
                                )
                            }
                        }
                        .textOption(textOptions)
                    TextEditor(text: $bodyText)
                        .frame(minHeight: height)
                        .scrollDisabled(true) // Scrollableなコンテンツの中で編集する前提で、そっちのスクロールのみを効かせるほうがUXとして自然
                        .textOption(textOptions)
                }
                .onPreferenceChange(ViewHeightKey.self) { height = $0 }

                if bodyText.isEmpty {
                    Text("日記の本文") .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .allowsHitTesting(false)
                        .textOption(textOptions)
                }
            }
        }
    }
}

private struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

#if DEBUG

struct DiaryTextEditor_Previews: PreviewProvider {

    struct Demo: View {
        @State var bodyTextEmpty = ""

        @State var bodyText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s\ndemo\ndemo\ndemo\ndemo\n"

        @State var bodyLongText = String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s", count:11)
        var body: some View {
            VStack {
                DiaryTextEditor(
                    bodyText: $bodyTextEmpty
                )

                DiaryTextEditor(
                    bodyText: $bodyText
                )

                DiaryTextEditor(
                    bodyText: $bodyLongText
                )
            }
        }
    }


    static var content: some View {
        ScrollView {
            Demo()
        }
    }

    static var previews: some View {
        Group {
            content
                .environment(\.colorScheme, .light)
            content
                .environment(\.colorScheme, .dark)
        }
        .environmentObject(TextOptions.preview)
    }
}

#endif

