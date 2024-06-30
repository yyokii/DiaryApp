import SwiftUI

struct Demo: View {
    @State private var selectedMonth: Date = .currentMonthFirstDate
    @State private var selectedDate: Date = .now

    /// スクロールにより表示領域が小さくなった時に最大どれだけ小さくするか（元のカレンダー画面からこの値を引いた値が小さくなった時の高さ）
    var heightReductionAmount: CGFloat {
        weekLabelHeight + dayHeight * CGFloat(selectedMonthDates.count/7)
    }
    /// カレンダーの日にち表示全体の高さ
    var calendarGridHeight: CGFloat {
        return CGFloat(selectedMonthDates.count / 7) * dayHeight
    }
    /// Selected Month Dates
    var selectedMonthDates: [Day] {
        return Day.makeForMonth(of: selectedMonth)
    }
    var calendarHeight: CGFloat {
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + safeArea.top + topPadding + bottomPadding
    }

    let safeArea: EdgeInsets
    /// カレンダー上部の年月表示の高さ
    let calendarTitleViewHeight: CGFloat = 28
    /// 曜日表示の高さ
    let weekLabelHeight: CGFloat = 30.0
    /// 日にち表示1つの高さ
    let dayHeight: CGFloat = 40
    let horizontalPadding: CGFloat = 16
    let topPadding: CGFloat = 8
    let bottomPadding: CGFloat = 8

    init(safeAreaInsets: EdgeInsets) {
        self.safeArea = safeAreaInsets
    }

    var body: some View {
        // どれだけスクロールしたら自動拡大しないかの閾値
        let autoScrollThreshold = heightReductionAmount - 20

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
            /// カレンダーViewのサイズ
            let size = $0.size
            /// スクロールView内での座標. 初期位置から上スクロールで「-」、下スクロールで「+」の値
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY

//            let _ = print("📝 minY: \(minY)")
            // miYが「-」になる = 上にスワイプした時にカレンダーViewが縮小するのでprogressが増加する
            let progress = max(min((-minY / heightReductionAmount), 1), 0)

//            let _ = print("📝 frame height: \( size.height - (heightReductionAmount * progress))")

            VStack(alignment: .leading, spacing: 0, content: {
                // 年月表記
                HStack(alignment: .center, spacing: 0) {
                    Text(selectedMonth.formatted(.dateTime.year().month()))
                }
                .font(.title)
                .fontWeight(.bold)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .frame(height: calendarTitleViewHeight)

                VStack(spacing: 0) {
                    // 曜日
                    HStack(spacing: 0) {
                        ForEach(Calendar(identifier: .gregorian).weekdaySymbols, id: \.self) { symbol in
                            Text(symbol.prefix(3))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: weekLabelHeight - (weekLabelHeight * progress), alignment: .bottom)
                    // viewのframe外を表示しないために設定（設定しないとheightを縮めてもTextの表示は残る）
                    .clipped()
                    .opacity(1 - progress)

                    // Calendar View
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
                        ForEach(selectedMonthDates) { day in
                            Text(day.shortSymbol)
                                .font(.callout)
                                .foregroundStyle(day.ignored ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: dayHeight)
                                .overlay(alignment: .bottom, content: {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 5, height: 5)
                                        .opacity(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? 1 : 0)
                                })
                                .contentShape(.rect)
                                .onTapGesture {
                                    selectedDate = day.date
                                }
                        }
                    })
                    // 日にち表示全体を割合で変化させる
                    .frame(height: calendarGridHeight - (calendarGridHeight * progress), alignment: .top)
                    .clipped()
                    .opacity(1 - progress)
                }
            })
            .foregroundStyle(Color.adaptiveWhite)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.top, safeArea.top)
            .padding(.bottom, bottomPadding)
            .frame(height: size.height - (heightReductionAmount * progress), alignment: .top)
            .background(.cyan.gradient)
            .offset(y: -minY) // 「-」に設定することで常に上部に設定する
        }
        .frame(height: calendarHeight)
        .zIndex(100)
    }


    /// Month Increment/Decrement
    func monthUpdate(_ increment: Bool = true) {
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedMonth) else { return }
        guard let date = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedDate) else { return }
        selectedMonth = month
        selectedDate = date
    }
}

private extension Demo {}

/// Custom Scroll Behaviour
struct CustomScrollBehaviour: ScrollTargetBehavior {
    var minHeight: CGFloat
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
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

            Demo(safeAreaInsets: safeArea)
                .ignoresSafeArea(.container, edges: .top)
        }
    }
}

#Preview {
    ContentView()
}
