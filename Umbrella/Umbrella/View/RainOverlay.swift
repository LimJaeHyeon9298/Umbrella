//
//  RainOverlay.swift
//  Umbrella
//

import SwiftUI

/// 정지 이미지 위에 내리는 빗줄기를 그린다.
struct RainOverlay: View {
    private let dropCount = 140

    var body: some View {
        // 오래 켜 두는 화면이라 초당 30번만 그린다.
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            Canvas { canvas, size in
                let time = context.date.timeIntervalSinceReferenceDate
                for i in 0..<dropCount {
                    let speed = 700 + Self.random(i, 1) * 500
                    let length = 18 + Self.random(i, 2) * 26
                    let travel = size.height + length
                    let y = (time * speed + Self.random(i, 3) * travel).truncatingRemainder(dividingBy: travel) - length
                    let x = Self.random(i, 4) * (size.width + 60) - 30
                    var drop = Path()
                    drop.move(to: CGPoint(x: x, y: y))
                    drop.addLine(to: CGPoint(x: x - length * 0.15, y: y + length))
                    canvas.stroke(drop, with: .color(.white.opacity(0.12 + Self.random(i, 5) * 0.2)), lineWidth: 1)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// 빗방울마다 고정된 0~1 값. 매 프레임 같은 값이 나와야 같은 빗방울이 이어서 떨어진다.
    private static func random(_ index: Int, _ salt: Int) -> Double {
        let value = sin(Double(index) * 12.9898 + Double(salt) * 78.233) * 43_758.5453
        return value - value.rounded(.down)
    }
}
