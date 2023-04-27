//
//  ContentView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/23.
//

import CoreData
import PhotosUI
import SwiftUI
import UIKit
import WeatherKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject var weatherData = WeatherData()
    let notificationService = NotificationService()

    @FetchRequest(fetchRequest: Item.thisMonth)
    private var items: FetchedResults<Item>

    @FetchRequest(fetchRequest: Item.favorites)
    private var favorites: FetchedResults<Item>

    var body: some View {
        NavigationView {
            VStack {
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

                Divider()

                List {
                    ForEach(favorites) { item in
                        Text(item.createdAt!, formatter: itemFormatter)
                    }
                    .onDelete(perform: deleteItems)
                }

                Divider()

                todayWeather
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
        }
        .onAppear{
            weatherData.requestLocationAuth()
            notificationService.requestAuth()
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

    var todayWeather: some View {
        VStack {
            if let todayWeather = weatherData.todayWeather {
                Text(todayWeather.date, format: Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)).day())
                Image(systemName: todayWeather.symbolName)
                Text(todayWeather.lowTemperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
                Text(todayWeather.highTemperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
            }
        }
        .asyncState(weatherData.phase)
    }
}

struct DiaryDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Diary editable contents
    @State var emoji: String
    @State var diaryBody: String
    @State var isFavorite: Bool

    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    /*
     このViewで入力を行い、保存しないで他の画面に遷移し再度本Viewを開いた際に値は元に戻っていてほしい。
     従って編集項目はStateで管理している。
     また、Core DataのEntityはClassでありObservableObjectではないので、Stateで管理しても状態更新は正常にされない。
     自動生成のものをそのまま利用したいのでバインドするものに関してはプロパティを用意し、更新タイミングでEntityを変更するようにしている
     */
    private let item: Item

    private let imageSize: CGSize = .init(width: 300, height: 300)

    init(item: Item) {
        self.item = item

        _emoji = State(initialValue: item.emoji ?? "")
        _diaryBody = State(initialValue: item.body ?? "")
        _isFavorite = State(initialValue: item.isFavorite)
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

            if let imageData = item.imageData,
               let uiImage: UIImage = .init(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
            }

            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
            }

            PhotosPicker("Select image", selection: $selectedPickerItem, matching: .images)

            Button("Save") {
                item.emoji = emoji
                item.body = diaryBody
                item.isFavorite = isFavorite
                if let selectedImage,
                   let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                    item.imageData = imageData
                }

                do {
                    try item.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        .onChange(of: selectedPickerItem) { _ in
            Task {
                if let data = try? await selectedPickerItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let resizedImage = uiImage.resizeImage(to: imageSize),
                   let rotatedImage = resizedImage.reorientToUp() {
                    selectedImage = rotatedImage
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, CoreDataProvider.preview.container.viewContext)
    }
}
