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

    var body: some View {
        VStack(spacing: 12) {
            ForEach(checkListItems, id: \.objectID) { item in
                checkListItem(item)
            }
            addNewItem
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

    func checkListItem(_ item: CheckListItem) -> some View {
        Button (actionWithHapticFB: {
            diaryDataStore.updateCheckListItemState(of: item)
        }) {
            HStack {
                Text(item.title ?? "no title")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isChecked(item) ? "checkmark.square" : "square")
                    .font(.system(size: 28))
                    .foregroundColor(.green)

            }
        }
        .buttonStyle(PlainButtonStyle())
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
                CheckList(diaryDataStore: DiaryDataStore())
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



