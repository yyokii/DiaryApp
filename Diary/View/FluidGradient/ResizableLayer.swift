//
//  ResizableLayer.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/16.
//

import QuartzCore

/// An implementation of ``CALayer`` that resizes its sublayers
public class ResizableLayer: CALayer {
    override init() {
        super.init()

        sublayers = []
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSublayers() {
        super.layoutSublayers()
        sublayers?.forEach { layer in
            layer.frame = self.frame
        }
    }
}
