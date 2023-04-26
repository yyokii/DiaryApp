//
//  View+AsyncState.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/26.
//

import SwiftUI

public enum AsyncStatePhase {
    case initial
    case loading
    case empty
    case success(Date)
    case failure(Error)

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    public var lastUpdated: Date? {
        if case let .success(date) = self {
            return date
        }

        return nil
    }

    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }

        return nil
    }
}

public extension View {
    /**
     データの状態を`AsyncStatePhase`を用いて独自に管理している場合に利用できる、データ状態に対応して適当なViewを返すViewBuilder
     */
    @ViewBuilder
    func asyncState<InitialContent: View,
                           LoadingContent: View,
                           EmptyContent: View,
                           FailureContent: View>(_ phase: AsyncStatePhase,
                                                 initialContent: InitialContent = ProgressView(),
                                                 loadingContent: LoadingContent = ProgressView(),
                                                 emptyContent: EmptyContent = Text("データが存在しません"),
                                                 failureContent: FailureContent = Text("読み込みに失敗しました。")
                           ) -> some View {
        switch phase {
        case .initial:
            initialContent
        case .loading:
            loadingContent
        case .empty:
            emptyContent
        case .success:
            self
        case .failure:
            failureContent
        }
    }

    /**
     データの状態を`AsyncState` Property Wrapper を用いて管理している場合に利用できる、データ状態に対応して適当なViewを返すViewBuilder
     */
    @ViewBuilder
    func asyncState<T: Codable,
                           InitialContent: View,
                           LoadingContent: View,
                           EmptyContent: View,
                           FailureContent: View>(_ state: AsyncState<T>,
                                                 initialContent: InitialContent = ProgressView(),
                                                 loadingContent: LoadingContent = ProgressView(),
                                                 emptyContent: EmptyContent = Text("データが存在しません"),
                                                 failureContent: FailureContent = Text("読み込みに失敗しました。")
                           ) -> some View {
        asyncState(state.phase,
                   initialContent: initialContent,
                   loadingContent: loadingContent,
                   emptyContent: emptyContent,
                   failureContent: failureContent)
    }
}

