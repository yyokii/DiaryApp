//
//  BlobLayer.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/16.
//

import SwiftUI
import QuartzCore

public class BlobLayer: CAGradientLayer {

    init(color: Color) {
        super.init()

        self.type = .radial

        // Center point
        let position = newPosition()
        self.startPoint = position

        // Radius
        let radius = newRadius()
        self.endPoint = position.displace(by: radius)

        set(color: color)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Required by the framework
    public override init(layer: Any) {
        super.init(layer: layer)
    }

    /// Set the color of the blob
    func set(color: Color) {
        self.colors = [
            SystemColor(color).cgColor,
            SystemColor(color).cgColor,
            SystemColor(color.opacity(0.0)).cgColor
        ]

        // gradient to be mostly solid and a little feathered around the edges. That's why we're also setting its colors' locations.
        self.locations = [0.0, 0.9, 1.0]
    }

    /// Animate the blob to a random point and size on screen at set speed
    func animate(speed: CGFloat) {
        guard speed > 0 else { return }

        self.removeAllAnimations()
        let currentLayer = self.presentation() ?? self

        let animation = CASpringAnimation()
        animation.mass = 10/speed // 大きいほど重い物体であり、ばねは強く引っ張られる。speedで除すので遅く動く物体は重い動作をする。
        animation.damping = 50 // 減衰率。 大きいほどばねの勢いが弱まる速度が上がる。0だと減衰せずにずっとバウンドする。
        animation.duration = 1/speed

        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards

        let position = newPosition()
        let radius = newRadius()

        // Center point
        let start = animation.copy() as! CASpringAnimation
        start.keyPath = "startPoint"
        start.fromValue = currentLayer.startPoint
        start.toValue = position

        // Radius
        let end = animation.copy() as! CASpringAnimation
        end.keyPath = "endPoint"
        end.fromValue = currentLayer.endPoint
        end.toValue = position.displace(by: radius)

        self.startPoint = position
        self.endPoint = position.displace(by: radius)

        // Opacity
        let value = Float.random(in: 0.5...1)
        let opacity = animation.copy() as! CASpringAnimation
        opacity.fromValue = self.opacity
        opacity.toValue = value

        self.opacity = value

        self.add(opacity, forKey: "opacity")
        self.add(start, forKey: "startPoint")
        self.add(end, forKey: "endPoint")
    }

    /// Generate a random radius for the blob
    func newRadius() -> CGPoint {
        let size = CGFloat.random(in: 0.15...0.75)
        let viewRatio = frame.width/frame.height // 最初はframe(0,0)になのでisNaNとなるが、animationでも利用しておりその際は実数となる
        let safeRatio = max(viewRatio.isNaN ? 1 : viewRatio, 1)
        let ratio = safeRatio*CGFloat.random(in: 0.25...1.75)
        return CGPoint(x: size, y: size*ratio)
    }

    /// Generate a random point on the canvas
    func newPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: 0.1...0.7),
            y: CGFloat.random(in: 0.1...0.7)
        ).capped()
    }

}

extension CGPoint {
    /// Build a point from an origin and a displacement
    func displace(by point: CGPoint = .init(x: 0.0, y: 0.0)) -> CGPoint {
        return CGPoint(
            x: self.x+point.x,
            y: self.y+point.y
        )
    }

    /// Caps the point to the unit space （0以上1以下を保証する）
    func capped() -> CGPoint {
        return CGPoint(
            x: max(min(x, 1), 0),
            y: max(min(y, 1), 0)
        )
    }
}

