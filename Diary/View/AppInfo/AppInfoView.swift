//
//  AppInfoView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/10.
//

import SwiftUI

struct AppInfoView: View {

    var body: some View {
        NavigationStack {
            Form {
                Section("日記の設定") {
                    textOption
                }

                Section("アプリについて") {

                }
            }
            .navigationTitle("設定")
        }
    }
}

private extension AppInfoView {

    // MARK: View

    var textOption: some View {
        NavigationLink("テキストの設定") {
            TextOptionsView()
        }
    }
    
    // MARK: Action
}

#if DEBUG

struct AppInfoView_Previews: PreviewProvider {

    static var content: some View {
        AppInfoView()
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


