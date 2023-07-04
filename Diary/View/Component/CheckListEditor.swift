//
//  CheckListEditor.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/28.
//

import SwiftUI

struct CheckListEditor: View {
    @EnvironmentObject private var bannerState: BannerState

    @FetchRequest(fetchRequest: CheckListItem.all)
    private var checkListItems: FetchedResults<CheckListItem>

    @State private var editState: CheckListEditState?
    @State private var editingItemTitle = ""
    @State private var isPresentedTextEditor = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .appLanguageLocale
        return formatter
    }()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(checkListItems, id: \.objectID) { item in
                        checkListItem(item)
                    }

                    addNewItem
                        .padding(.top)
                }
            }
            .padding()

            if let editState, isPresentedTextEditor  {
                CheckListTextEditor(
                    isPresented: $isPresentedTextEditor,
                    editState: editState
                )
            }
        }
    }
}

enum CheckListEditState {
    case createNewItem
    case editCurrentItem(item: CheckListItem)
}

private extension CheckListEditor {

    // MARK: View

    var addNewItem: some View {
        Button (actionWithHapticFB: {
            editState = .createNewItem
            isPresentedTextEditor = true
        }) {
            HStack {
                Image(systemName:"plus")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.adaptiveBlack)
                    .bold()

                Text("新しいチェックリストを追加")
                    .font(.system(size: 16))
                    .foregroundColor(.adaptiveBlack)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.appSecondary)
                    .adaptiveShadow(size: .small)
            }
        }
    }

    func checkListItem(_ item: CheckListItem) -> some View {
        Button (actionWithHapticFB: {
            editState = .editCurrentItem(item: item)
            isPresentedTextEditor = true
        }) {
            HStack {
                Text(item.title ?? "no title")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let createdAt = item.createdAt {
                    Text(createdAt, formatter: dateFormatter)
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.gray)
                }

            }
            .contentShape(Rectangle()) // タップ領域をコンテナー全体に設定
        }
        .buttonStyle(.plain)
    }
    // MARK: Action
}

#if DEBUG

struct CheckListEditor_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            CheckListEditor()
                .environment(
                    \.managedObjectContext,
                     CoreDataProvider.preview.container.viewContext
                )
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
