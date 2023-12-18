//
//  SensorDataModel.swift
//  bletest11
//
//  Created by User on 2023-12-11.
//

import Foundation
import SwiftUI
import Combine

class SensorDataModel: ObservableObject {
    @Published var xValue: Float = 0.0
    @Published var yValue: Float = 0.0
    @Published var zValue: Float = 0.0
    
    @Published var xAngle: Float = 0.0
    @Published var yAngle: Float = 0.0
    @Published var zAngle: Float = 0.0
    
    @Published var xAngle2: Float = 0.0
    @Published var yAngle2: Float = 0.0
    @Published var zAngle2: Float = 0.0
    
    @Published var xDps: Float = 0.0
    @Published var yDps: Float = 0.0
    @Published var zDps: Float = 0.0
}
