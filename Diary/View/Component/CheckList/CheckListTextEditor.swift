//
//  CheckListTextEditor.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/01.
//

import SwiftUI

struct CheckListTextEditor: View {
    @EnvironmentObject private var bannerState: BannerState

    @FocusState var focused: Bool

    @State var title: String = ""
    @Binding var isPresented: Bool

    let editState: CheckListEditState

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear

            VStack(alignment: .trailing, spacing: 0) {
                if case let .editCurrentItem(item) = editState {
                    Button(actionWithHapticFB: {
                        delete(item)
                    }) {
                        Text("削除")
                    }
                }
                inputProgress
                Spacer(minLength: 24).fixedSize()
                itemEditor
            }
            .padding()
            .padding(.bottom)
            .background {
                Rectangle()
                    .fill(Color.adaptiveBackground)
            }

        }
        .ignoresSafeArea(.container, edges: [.bottom]) // .container を指定しキーボードを回避
        .onAppear {
            if case let .editCurrentItem(item) = editState {
                title = item.title ?? ""
            }
            focused = true
        }
    }
}

private extension CheckListTextEditor {
    var isValidTitle: Bool {
        Item.titleRange.contains(title.count)
    }

    var progressColor: Color {
        title.count > Item.titleRange.upperBound
        ? .red
        : .adaptiveBlack
    }

    var background: some View {
        Color.gray.opacity(0.2)
            .blur(radius: 10)
            .onTapGesture {
                withAnimation {
                    isPresented = false
                }
            }
    }

    var inputProgress: some View {
        ProgressView(
            "\(title.count) / \(CheckListItem.titleRange.upperBound)",
            value: Double(title.count),
            total: Double(CheckListItem.titleRange.upperBound)
        )
        .accentColor(progressColor)
        .foregroundColor(.gray)
    }

    var itemEditor: some View {
        HStack(spacing: 16) {
            TextField("", text: $title)
                .focused($focused)
                .foregroundStyle(Color.adaptiveBlack)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                }
                .ignoresSafeArea(.container, edges: [.bottom]) // .container を指定しキーボードを回避
                .onAppear {
                    focused = true
                }

            Button(actionWithHapticFB: {
                send(with: editState)
            }) {
                Text("OK")
            }
        }
    }

    func circleIcon(imageName: String) -> some View {
        Circle()
            .foregroundColor(.adaptiveWhite)
            .frame(width: 48)
            .adaptiveShadow()
            .overlay {
                Image(systemName: imageName)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
    }

    // MARK: Action

    func send(with editState: CheckListEditState) {
        switch editState {
        case .createNewItem:
            addNewItem(title: title)
        case .editCurrentItem(let item):
            update(item: item, title: title)
        }
    }

    func delete(_ item: CheckListItem) {
        do {
            try item.delete()
            isPresented = false
            bannerState.show(of: .success(message: "削除しました"))
        } catch {
            bannerState.show(with: error)
        }
    }

    func addNewItem(title: String) {
        guard isValidTitle else {
            return
        }

        do {
            try CheckListItem.create(title: title)
            isPresented = false
            bannerState.show(of: .success(message: "新しいチェックリストを追加しました"))
        } catch {
            print(error.localizedDescription)
            bannerState.show(with: error)
        }
    }

    func update(item: CheckListItem, title: String) {
        guard isValidTitle else {
            return
        }

        do {
            try item.update(title: title)
            isPresented = false
            bannerState.show(of: .success(message: "更新しました"))
        } catch {
            print(error.localizedDescription)
            bannerState.show(with: error)
        }
    }
}

#if DEBUG

struct CheckListTextEditor_Previews: PreviewProvider {
    static var content: some View {
        NavigationStack {
            VStack {
                CheckListTextEditor(
                    isPresented: .constant(true),
                    editState: .createNewItem
                )

                CheckListTextEditor(
                    isPresented: .constant(true),
                    editState: .editCurrentItem(item: .makeRandom())
                )
            }
        }
    }

    static var previews: some View {
        Group {
            content
                .environment(\.colorScheme, .light)
            content
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif

