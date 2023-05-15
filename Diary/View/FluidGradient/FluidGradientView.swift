//
//  FluidGradientView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/16.
//

import Combine
import SwiftUI

import UIKit
public typealias SystemColor = UIColor
public typealias SystemView = UIView

protocol FluidGradientDelegate: AnyObject {
    func updateBlur(_ value: CGFloat)
}

/**
 A system view that presents an animated gradient with ``CoreAnimation``
 
 ViewRepresentableを用いて利用する対象となる、ベースの実装
 */
public class FluidGradientView: SystemView {
    var speed: CGFloat
    var cancellables = Set<AnyCancellable>()
    
    weak var delegate: FluidGradientDelegate?
    
    let baseLayer = ResizableLayer()
    let highlightLayer = ResizableLayer()
    init(
        blobs: [Color] = [],
        highlights: [Color] = [],
        speed: CGFloat = 1.0
    ) {
        self.speed = speed
        super.init(frame: .zero)
        
        // filter list https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
        if let compositingFilter = CIFilter(name: "CIOverlayBlendMode") {
            highlightLayer.compositingFilter = compositingFilter
        }
        self.layer.addSublayer(baseLayer)
        self.layer.addSublayer(highlightLayer)
        
        create(blobs, layer: baseLayer)
        create(highlights, layer: highlightLayer)
        DispatchQueue.main.async {
            self.update(speed: speed)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func create(_ colors: [Color], layer: CALayer) {
        // Remove blobs at the end if colors are removed
        let sublayersCount = layer.sublayers?.count ?? 0
        
        if sublayersCount > 0 {
            let removeCount = sublayersCount - colors.count
            if removeCount > 0 {
                layer.sublayers?.removeLast(removeCount)
            }
        }
        
        for (index, color) in colors.enumerated() {
            if index < sublayersCount {
                if let existing = layer.sublayers?[index] as? BlobLayer {
                    existing.set(color: color)
                } else {
                    print("⚠️ not found BlobLayer to update color")
                }
            } else {
                layer.addSublayer(BlobLayer(color: color))
            }
        }
    }
    
    public override func layoutSubviews() {
        layer.frame = self.bounds
        baseLayer.frame = self.bounds
        highlightLayer.frame = self.bounds
        
        updateBlur()
    }
    
    /// Compute and update new blur value
    private func updateBlur() {
        delegate?.updateBlur(min(frame.width, frame.height))
    }
    
    /// Update sublayers and set speed and blur levels
    public func update(speed: CGFloat) {
        cancellables.removeAll()
        self.speed = speed
        guard speed > 0 else { return }
        
        let layers = (baseLayer.sublayers ?? []) + (highlightLayer.sublayers ?? [])
        for layer in layers {
            if let layer = layer as? BlobLayer {
                Timer.publish(
                    every: .random(in: 0.8/speed...1.2/speed),
                    on: .main,
                    in: .common
                )
                .autoconnect()
                .sink { _ in
                    layer.animate(speed: speed)
                }
                .store(in: &cancellables)
            }
        }
    }
}
