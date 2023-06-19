//
//  CheckList.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/07.
//

import SwiftUI

struct CheckList: View {
    @EnvironmentObject private var bannerState: BannerState

    @ObservedObject var diaryDataStore: DiaryDataStore

    @FetchRequest(fetchRequest: CheckListItem.all)
    private var checkListItems: FetchedResults<CheckListItem>

    @State private var newItemTitle = ""

    /*
     チェックリストにおいて、常に（編集モード以外でも）編集可能にする仕様も検討したが、
     その場合は編集モード中は逐次保存ではないようにしないと、保存タイミングが増えてしまい混乱する。
     現状は、仕様のシンプルさを優先し編集モードのみで編集可能であり、保存ボタン押下のタイミングでデータ更新するようにしている。
     */
    @Binding var isEditable: Bool

    var body: some View {
        VStack(spacing: 12) {
            ForEach(checkListItems, id: \.objectID) { item in
                checkListItem(item)
            }

            if isEditable {
                addNewItem
            }
        }
    }
}

private extension CheckList {
    var addNewItem: some View {
        HStack {
            TextField("チェックリスト", text: $newItemTitle)
                .font(.system(size: 20))

            Spacer()

            Button (actionWithHapticFB: {
                addNewItem(title: newItemTitle)
            }) {
                Image(systemName:"plus")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.adaptiveWhite)
                    .bold()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.green)
                    }
            }
        }
    }

    @ViewBuilder
    func checkListItem(_ item: CheckListItem) -> some View {
        if isEditable {
            Button (actionWithHapticFB: {
                diaryDataStore.updateCheckListItemState(of: item)
            }) {
                checkListContent(item)
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            checkListContent(item)
        }
    }

    func checkListContent(_ item: CheckListItem) -> some View {
        HStack {
            Text(item.title ?? "no title")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: isChecked(item) ? "checkmark.square" : "square")
                .font(.system(size: 28))
                .foregroundColor(.green)

        }
    }

    func isChecked(_ item: CheckListItem) -> Bool {
        diaryDataStore.checkListItems.contains { checkedListItem in
            checkedListItem.objectID == item.objectID
        }
    }

    // MARK: Action

    func addNewItem(title: String) {
        do {
            try CheckListItem.create(title: title)
            newItemTitle = ""
        } catch {
            print(error.localizedDescription)
            bannerState.show(with: error)
        }
    }
}

#if DEBUG

struct CheckList_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            VStack {
                CheckList(diaryDataStore: DiaryDataStore(), isEditable: .constant(true))
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



