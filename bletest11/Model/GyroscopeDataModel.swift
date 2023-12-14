//
//  GyroscopeDataModel.swift
//  bletest11
//
//  Created by User on 2023-12-14.
//

import Foundation

class GyroscopeDataModel: ObservableObject {
    @Published var xDps: Float = 0.0
    @Published var yDps: Float = 0.0
    @Published var zDps: Float = 0.0
}
