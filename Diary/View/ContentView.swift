//
//  ContentView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(fetchRequest: Item.thisMonth)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        DiaryDetailView(item: item)
                    } label: {
                        Text(item.createdAt!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item.makeRandom(context: viewContext)

            do {
                try newItem.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private extension ContentView {

}

struct DiaryDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /*
     Core DataのEntityはClassでありObservableObjectではないので、Stateで管理しても状態更新は正常にされない。
     自動生成のものをそのまま利用したいのでバインドするものに関してはプロパティを用意し、更新タイミングでEntityを変更するようにしている
     */
    let item: Item

    // Diary editable contents
    @State var emoji: String
    @State var diaryBody: String
    @State var isFavorite: Bool

    init(item: Item) {
        self.item = item

        self.emoji = item.emoji ?? ""
        self.diaryBody = item.body ?? ""
        self.isFavorite = item.isFavorite
    }

    var body: some View {
        VStack {
            TextField("emoji", text: $emoji)
            Text("weather: \(item.weather ?? "")")
            TextField("body", text: $diaryBody)
            Toggle(isOn: $isFavorite) {
                Text("favorite")
            }
            Text("created at \(item.createdAt!, formatter: itemFormatter)")

            if let updatedAt = item.updatedAt {
                Text("updated at \(updatedAt, formatter: itemFormatter)")
            }

            Button("Save") {
                item.emoji = emoji
                item.body = diaryBody
                item.isFavorite = isFavorite

                do {
                    try item.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

extension Binding {
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            print(newValue)
            self.wrappedValue = newValue
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, CoreDataProvider.preview.container.viewContext)
    }
}
