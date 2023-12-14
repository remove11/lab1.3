//
//  LineChartShape.swift
//  bletest11
//
//  Created by User on 2023-12-12.
//

import Foundation
import SwiftUI

struct LineChartShape: Shape {
    var dataPoints: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        guard !dataPoints.isEmpty else { return path }

        let scaleFactor = rect.height / (dataPoints.max() ?? 1)
        let xOffset = rect.width / CGFloat(dataPoints.count - 1)

        let points = dataPoints.enumerated().map { index, dataPoint in
            CGPoint(x: CGFloat(index) * xOffset, y: rect.height - CGFloat(dataPoint) * scaleFactor)
        }

        path.move(to: points.first ?? .zero)
        points.forEach { path.addLine(to: $0) }

        return path
    }
}
