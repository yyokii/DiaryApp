import SwiftUI

struct CalendarContainer<Content: View>: View {
    @Binding var selectedMonth: Date
    @State private var selectedDate: Date = .now
    @State private var animation: Bool = false

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

    /// カレンダー上部の年月表示の高さ
    let calendarTitleViewHeight: CGFloat = 28
    /// 曜日表示の高さ
    let weekLabelHeight: CGFloat = 30
    /// 日にち表示1つの高さ
    let dayHeight: CGFloat = 40
    let horizontalPadding: CGFloat = 16
    let topPadding: CGFloat = 8
    let bottomPadding: CGFloat = 12

    private let safeArea: EdgeInsets
    private let dateItemCount: [Date: Int]
    private let content: () -> Content

    init(selectedMonth: Binding<Date>, safeAreaInsets: EdgeInsets, dateItemCount: [Date: Int], content: @escaping () -> Content) {
        self.safeArea = safeAreaInsets
        self.dateItemCount = dateItemCount
        self.content = content
        self._selectedMonth = selectedMonth
    }

    var body: some View {
        // どれだけスクロールしたら自動拡大しないかの閾値
        let autoScrollThreshold = heightReductionAmount - 20

        ScrollView(.vertical) {
            VStack(spacing: 0) {
                CalendarView()
                content()
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(CustomScrollBehavior(minHeight: autoScrollThreshold))
    }

    /// Calendar View
    @ViewBuilder
    func CalendarView() -> some View {
        GeometryReader {
            /// カレンダーViewのサイズ
            let size = $0.size
            /// スクロールView内での座標. 初期位置から上スクロールで「-」、下スクロールで「+」の値
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY

            // miYが「-」になる = 上にスワイプした時にカレンダーViewが縮小するのでprogressが増加する
            let progress = max(min((-minY / heightReductionAmount), 1), 0)

            VStack(alignment: .leading, spacing: 0, content: {
                // 年月表記
                HStack(alignment: .center, spacing: 0) {
                    Text(selectedMonth.formatted(.dateTime.year().month()))
                        .animation(.spring, value: selectedMonth)
                        .foregroundStyle(Color.black)
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
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(height: weekLabelHeight - (weekLabelHeight * progress), alignment: .center)
                    // viewのframe外を表示しないために設定（設定しないとheightを縮めてもTextの表示は残る）
                    .clipped()
                    .opacity(1 - progress)

                    // Calendar View
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
                        ForEach(selectedMonthDates) { day in
                            VStack(alignment: .center, spacing: 0) {
                                Text(day.shortSymbol)
                                    .font(.callout)
                                    .foregroundStyle(day.ignored ? Color.gray : Color.black)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        selectedDate = day.date
                                    }
                                itemsCountView(count: itemCount(for: day.date) ?? 0)
                                    .frame(height: 8)
                            }
                            .frame(height: dayHeight)
                        }
                    })
                    .frame(
                        height:  minY > 0
                           ? calendarGridHeight + minY
                           : calendarGridHeight - (calendarGridHeight * progress),
                        alignment: .center
                    )
                    .clipped()
                    .opacity(1 - progress)
                    .animation(.spring, value: selectedMonth)
                }
            })
            .foregroundStyle(Color.adaptiveWhite)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.top, safeArea.top)
            .padding(.bottom, bottomPadding)
            .frame(height: size.height - (heightReductionAmount * progress), alignment: .top)
            .frame(
                height: minY > 0
                   ? size.height + minY
                   : size.height - (heightReductionAmount * progress),
                alignment: .top
            )
            .background(
                RoundedRectangle(
                    cornerRadius: (1 - progress) * 24,
                    style: .continuous
                )
                .fill(.white)
            )
            .offset(y: -minY) // 「-」に設定することでカレンダーのメイン部分を常に上部に設定する
            .compositingGroup()
            .adaptiveShadow(size: .medium)
        }
        .frame(height: calendarHeight)
        .zIndex(100)
        .animation(.spring, value: calendarHeight)
    }
}

private extension CalendarContainer {
    struct CustomScrollBehavior: ScrollTargetBehavior {
        var minHeight: CGFloat
        func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
            // target.rect.minY はスクロールコンテンツの上部の座標（0以上の値）
            if target.rect.minY < minHeight {
                // 最小サイズを超えるまでスクロールされなかった場合は初期位置に戻す
                target.rect = .zero
            }
        }
    }

    func itemCount(for date: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let startOfDay = calendar.date(from: components) else {
            return nil
        }
        return dateItemCount[startOfDay]
    }

    func itemsCountView(count: Int) -> some View {
        HStack(alignment: .center, spacing: 2) {
            if count <= 2 {
                ForEach(0..<count, id: \.self) { _ in
                    Circle()
                        .foregroundStyle(Color.black.opacity(0.7))
                        .frame(width: 3)
                }
            } else {
                HStack(alignment: .center, spacing: 2) {
                    ForEach(0..<2, id: \.self) { _ in
                        Circle()
                            .frame(width: 3, height: 3)
                    }
                    Image(systemName: "plus")
                        .font(.system(size: 4))
                        .bold()
                }
                .foregroundStyle(Color.black.opacity(0.7))
            }
        }
    }
}

#Preview {
    struct ContentView: View {
        var body: some View {
            GeometryReader { proxy in
                let safeArea = proxy.safeAreaInsets
                CalendarContainer(selectedMonth: .constant(.currentMonthFirstDate), safeAreaInsets: safeArea, dateItemCount: [:]) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<10, id: \.self) { index in
                                VStack(spacing: 15) {
                                    ForEach(1...10, id: \.self) { _ in
                                        card
                                    }
                                }
                                .frame(width: proxy.size.width - 40)
                                .padding(.vertical, 32)
                                .padding(.horizontal, 20)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                }
                .ignoresSafeArea(.container, edges: .top)
            }
        }

        var card: some View {
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.gradient)
                .frame(height: 70)
                .adaptiveShadow()
        }
    }

    return ContentView()
}
