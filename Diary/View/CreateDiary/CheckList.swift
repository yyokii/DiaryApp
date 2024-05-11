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
            if checkListItems.count == 0 {
                Text("現在チェックリストはありません。")
                    .font(.system(size: 16))
                    .padding(.top, 16)
            } else {
                ForEach(checkListItems, id: \.objectID) { item in
                    checkListItem(item)
                }
            }
        }
    }
}

private extension CheckList {

    @ViewBuilder
    func checkListItem(_ item: CheckListItem) -> some View {
        Button (actionWithHapticFB: {
            diaryDataStore.updateCheckListItemState(of: item)
        }) {
            CheckListContent(item: item, isChecked: isChecked(item))
        }
        .buttonStyle(.plain)
    }

    func isChecked(_ item: CheckListItem) -> Bool {
        diaryDataStore.checkListItems.contains { checkedListItem in
            checkedListItem.objectID == item.objectID
        }
    }

    // MARK: Action
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



