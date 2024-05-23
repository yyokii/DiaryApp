import SwiftUI

struct Demo: View {
    /// View Properties
    @State private var selectedMonth: Date = .currentMonthFirstDate
    @State private var selectedDate: Date = .now
    var safeArea: EdgeInsets
    var body: some View {
        // どれだけスクロールしたら自動拡大しないかの閾値
        let autoScrollThreshold = calendarTitleViewHeight + weekLabelHeight + safeArea.top + 50 + topPadding + bottomPadding
//        let _ = print(autoScrollThreshold)

        ScrollView(.vertical) {
            VStack(spacing: 0) {
                CalendarView()

                VStack(spacing: 15) {
                    ForEach(1...10, id: \.self) { _ in
                        CardView()
                    }
                }
                .padding(15)
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(CustomScrollBehaviour(minHeight: autoScrollThreshold))
    }

    /// Test Card View (For Scroll Content)
    @ViewBuilder
    func CardView() -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.blue.gradient)
            .frame(height: 70)
    }

    /// Calendar View
    @ViewBuilder
    func CalendarView() -> some View {
        GeometryReader {
            // カレンダーViewのサイズ
            let size = $0.size
            // スクロールView内での座標
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY

            // スクロールにより表示領域が小さくなった時のサイズ
            let minHeight = safeArea.top + topPadding + calendarTitleViewHeight + weekLabelHeight + dayHeight + bottomPadding
            // miYが「-」になる = 上にスワイプした時にカレンダーViewが縮小するのでprogressが増加する
            let progress = max(min((-minY / minHeight), 1), 0)

            VStack(alignment: .leading, spacing: 0, content: {
                // 年月表記
                Text(currentMonth)
                    .font(.system(size: 35 - (10 * progress)))
                    .offset(y: -50 * progress)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .overlay(alignment: .topLeading, content: {
                        GeometryReader {
                            let size = $0.size

                            Text(year)
                                .font(.system(size: 25 - (10 * progress)))
                                .offset(x: (size.width + 5) * progress, y: progress * 3)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .border(.black)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .topTrailing, content: {
                        HStack(spacing: 15) {
                            Button("", systemImage: "chevron.left") {
                                /// Update to Previous Month
                                monthUpdate(false)
                            }
                            .contentShape(.rect)

                            Button("", systemImage: "chevron.right") {
                                /// Update to Next Month
                                monthUpdate(true)
                            }
                            .contentShape(.rect)
                        }
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .offset(x: 150 * progress)
                    })
                    .frame(height: calendarTitleViewHeight)

                VStack(spacing: 0) {
                    /// Day Labels
                    HStack(spacing: 0) {
                        ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                            Text(symbol.prefix(3))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: weekLabelHeight, alignment: .bottom)

                    /// Calendar Grid View
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
                        ForEach(selectedMonthDates) { day in
                            Text(day.shortSymbol)
                                .foregroundStyle(day.ignored ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(alignment: .bottom, content: {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 5, height: 5)
                                        .opacity(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? 1 : 0)
                                        .offset(y: progress * -2)
                                })
                                .contentShape(.rect)
                                .onTapGesture {
                                    selectedDate = day.date
                                }
                        }
                    })
                    // 日にち表示は最小で1行になるので、日にち表示全体から1行分の高さ（50pt）を引いた分を割合で変化させる
                    .frame(height: calendarGridHeight - ((calendarGridHeight - dayHeight) * progress), alignment: .top)
                    .offset(y: (monthProgress * -dayHeight) * progress)
                    .contentShape(.rect)
                    .clipped()
                }
                .offset(y: progress * -50)
            })
            .foregroundStyle(Color.adaptiveWhite)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.top, safeArea.top)
            .padding(.bottom, bottomPadding)
            .frame(height: size.height - (minHeight * progress), alignment: .top)
            .background(.cyan.gradient)
            .offset(y: -minY) // 「-」に設定することで常に上部に設定する
        }
        .frame(height: calendarHeight)
        .zIndex(100)
    }

    // FIXME: performance
    /// Date Formatter
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: selectedMonth)
    }

    /// Month Increment/Decrement
    func monthUpdate(_ increment: Bool = true) {
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedMonth) else { return }
        guard let date = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedDate) else { return }
        selectedMonth = month
        selectedDate = date
    }

    /// Selected Month Dates
    var selectedMonthDates: [Day] {
        return Day.makeForMonth(of: selectedMonth)
    }

    /// Current Month String
    var currentMonth: String {
        return format("MMMM")
    }

    /// Selected Year
    var year: String {
        return format("YYYY")
    }

    // 0.0 ~ 1.0
    var monthProgress: CGFloat {
        let calendar = Calendar.current
        if let index = selectedMonthDates.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            // TODO: なぜこれ四捨五入でうまくいってるかわからない
            return CGFloat(index / 7).rounded()
        }

        return 1.0
    }

    /// View Heights & Paddings
    ///
    /// 赤色部分の最大サイズ
    var calendarHeight: CGFloat {
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + safeArea.top + topPadding + bottomPadding
    }

    /// カレンダー上部の年月表示の高さ
    let calendarTitleViewHeight: CGFloat = 75.0

    /// 曜日表示の高さ
    let weekLabelHeight: CGFloat = 30.0

    /// カレンダーの日にち表示全体の高さ
    var calendarGridHeight: CGFloat {
        return CGFloat(selectedMonthDates.count / 7) * 50
    }

    /// 日にち表示1つの高さ
    let dayHeight: CGFloat = 50

    let horizontalPadding: CGFloat = 15.0

    let topPadding: CGFloat = 15.0

    let bottomPadding: CGFloat = 5.0
}

/// Custom Scroll Behaviour
struct CustomScrollBehaviour: ScrollTargetBehavior {
    var minHeight: CGFloat
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
//        let _ = print("📝 minHeight: \(minHeight)")
//        let _ = print("📝 target.rect.minY: \(target.rect.minY)")
        // target.rect.minY はスクロールコンテンツの上部の座標（0以上の値）
        if target.rect.minY < minHeight {
            // 最小サイズを超えるまでスクロールされなかった場合は初期位置に戻す
            target.rect = .zero
        }
    }
}

struct ContentView: View {
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets

            Demo(safeArea: safeArea)
                .ignoresSafeArea(.container, edges: .top)
        }
    }
}

#Preview {
    ContentView()
}
