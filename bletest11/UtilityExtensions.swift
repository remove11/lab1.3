//
//  UtilityExtensions.swift
//  bletest11
//
//  Created by User on 2023-12-14.
//

import Foundation

extension BluetoothViewModel {
    
    func parseTiltData(from data: Data) -> [String: Any] {
        var tiltInfo = [String: Any]()
        
        let xTilt = extractTiltValue(from: data, for: .xAxis)
        let yTilt = extractTiltValue(from: data, for: .yAxis)
        let zTilt = extractTiltValue(from: data, for: .zAxis)
        
        tiltInfo["x"] = xTilt
        tiltInfo["y"] = yTilt
        tiltInfo["z"] = zTilt

        return tiltInfo
    }
    
    func extractTiltValue(from data: Data, for axis: Axis) -> Int {
        let startIndex: Int
        let length = 2

        switch axis {
            case .xAxis:
                startIndex = 0
            case .yAxis:
                startIndex = 2
            case .zAxis:
                startIndex = 4
        }

        // Ensure the data contains enough bytes for the specified axis
        guard startIndex + length <= data.count else {
            print("Data does not contain enough bytes for axis \(axis)")
            return 0
        }

        // Extract the 2 bytes for the specified axis
        let range = startIndex..<startIndex + length
        let axisData = data.subdata(in: range)

        // Convert the 2 bytes into a 16-bit signed integer
        let tiltValue = axisData.withUnsafeBytes { $0.load(as: Int16.self) }

        // Return the tilt value as an integer
        return Int(tiltValue)
    }
    
    
}


