//
//  CustomTabView.swift
//  GangwonDoranDoran
//
//  Created by 임재현 on 7/11/24.
//

import UIKit
import Combine

class CustomTabView: UIView {
    var buttonTappedPublisher = PassthroughSubject<Int, Never>()
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let startY: CGFloat = 0  // y축 위치 설정
        let totalWidth = rect.width  // 전체 너비
        let numberOfSegments = 5  // 세그먼트 수
        let arcRadiusSmall: CGFloat = 20  // 작은 호의 반지름
        let arcRadiusLarge: CGFloat = 32  // 큰 호의 반지름

        // 각 세그먼트의 너비를 계산 (작은 호와 큰 호를 고려하여 계산)
        let totalArcWidths = (arcRadiusSmall * 2 * 4) + (arcRadiusLarge * 2)
        let segmentWidth = (totalWidth - totalArcWidths) / CGFloat(numberOfSegments + 1) // 간격을 조금 줄이기 위해 +1

        // 시작점 설정
        path.move(to: CGPoint(x: 0, y: startY))

        var arcCenters: [CGPoint] = []

        // 패턴 반복 설정
        for i in 0..<numberOfSegments {
            // 직선 그리기
            path.addLine(to: CGPoint(x: path.currentPoint.x + segmentWidth, y: startY))
            
            // 호 그리기
            let arcRadius = (i == 2) ? arcRadiusLarge : arcRadiusSmall  // 세 번째 호는 크게 설정
            let arcCenterX = path.currentPoint.x + arcRadius

            // 호 그리기
            path.addArc(withCenter: CGPoint(x: arcCenterX, y: startY), radius: arcRadius, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
            arcCenters.append(CGPoint(x: arcCenterX, y: startY))
        }

        // 마지막에 끝내는 직선 추가
        path.addLine(to: CGPoint(x: path.currentPoint.x + segmentWidth, y: startY))
        path.lineJoinStyle = .round
        path.lineCapStyle = .round

        // 경로 그리기
        UIColor.black.set()
        path.lineWidth = 1
        path.stroke()
        
        // 버튼 추가
        addButtons(arcCenters: arcCenters, arcRadiusSmall: arcRadiusSmall, arcRadiusLarge: arcRadiusLarge)
    }
    
    private func addButtons(arcCenters: [CGPoint], arcRadiusSmall: CGFloat, arcRadiusLarge: CGFloat) {
        let smallButtonDiameter: CGFloat = 32
        let largeButtonDiameter: CGFloat = 58
        let titles = ["Home", "Search", "", "Settings", "More"]

        for i in 0..<arcCenters.count {
            let arcRadius = (i == 2) ? arcRadiusLarge : arcRadiusSmall
            let buttonDiameter = (i == 2) ? largeButtonDiameter : smallButtonDiameter
            let arcCenter = arcCenters[i]

            // 버튼 X, Y 위치 조정
            let buttonX = arcCenter.x - buttonDiameter / 2
            let buttonY = arcCenter.y - buttonDiameter / 2

            let button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonDiameter, height: buttonDiameter))
            button.backgroundColor = .red
            button.setImage(UIImage(systemName: "person.fill"), for: .normal)
            button.layer.cornerRadius = buttonDiameter / 2
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            // 라벨 위치 조정
            let label = UILabel()
            label.text = titles[i]
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            label.frame = CGRect(x: buttonX - 10, y: buttonY + buttonDiameter + 5, width: buttonDiameter + 20, height: 20)
            label.textColor = .black

            self.addSubview(button)
            self.addSubview(label)
        }
    }
    

    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button \(sender.tag) tapped")
        buttonTappedPublisher.send(sender.tag)
    }
}

class CustomButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = bounds.width / 2
        let distance = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
        return distance <= radius
    }
}
