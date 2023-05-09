//
//  PassThroughWindow.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import UIKit

/**
 - Handle user interactions when the interaction touches something shown in that window
 - Pass the interaction to other windows otherwise

 RootVCのviewと
 同じ → そのまま流す = イベントを透過させる  =  return nil
 違う → そのViewでイベントを捕捉する = return hitView
 */
class PassThroughWindow: UIWindow {

    /*
     タップされたView階層の最も深い位置(root view)からサブビューへ、再帰的に呼び出されることでイベントを受信するViewを見つけるために利用される。
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        let isRootView = rootViewController?.view == hitView
        return isRootView ? nil : hitView
    }
}
