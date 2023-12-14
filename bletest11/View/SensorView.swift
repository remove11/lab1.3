//
//  SensorView.swift
//  bletest11
//
//  Created by User on 2023-12-11.
//

import SwiftUI


struct SensorView: View {
    @EnvironmentObject var sensorData: SensorDataModel
    @State private var isRecording = false
    @State private var recordedData = [(Int, Int)]()

    var body: some View {
        HStack{
            VStack {
                Text("X: \(String(format: "%.2f", sensorData.xValue))")
                    .font(.body) // Larger font size for text
                    .padding()    // Add some padding around the text
                Text("Y: \(String(format: "%.2f", sensorData.yValue))")
                    .font(.body) // Larger font size for text
                    .padding()    // Add some padding around the text
                Text("Z: \(String(format: "%.2f", sensorData.zValue))")
                    .font(.body) // Larger font size for text
                    .padding()    // Add some padding around the text
            }
            VStack{
                Text("X-axis DPS: \(sensorData.xDps)")
                    .font(.body)
                    .padding()
                Text("Y-axis DPS: \(sensorData.yDps)")
                    .font(.body)
                    .padding()
                Text("Z-axis DPS: \(sensorData.zDps)")
                    .font(.body)
                    .padding()
            }
        }
        
        HStack{
            VStack {
                Text("applyEWMAFilter")
                Text("X Angle: \(sensorData.xAngle, specifier: "%.f")°")
                    .font(.body) // Larger font size for text
                    .padding()
                Text("Y Angle: \(sensorData.yAngle, specifier: "%.f")°")
                    .font(.body) // Larger font size for text
                    .padding()
                Text("Z Angle: \(sensorData.zAngle, specifier: "%.f")°")
                    .font(.body) // Larger font size for text
                    .padding()
            }
            VStack {
                Text("applyComplementaryFilter")
                Text("X Angle2: \(sensorData.xAngle2, specifier: "%.f")°")
                    .font(.body) // Larger font size for text
                    .padding()
                Text("Y Angle2: \(sensorData.yAngle2, specifier: "%.f")°")
                    .font(.body) // Larger font size for text
                    .padding()
                Text("Z Angle2: \(sensorData.zAngle2, specifier: "%.f")°")
                    .font(.body) // Larger font size for text
                    .padding()
            }
        }
        NavigationLink("Read File", destination: FileContentView())
            .navigationBarTitle("Sensor Data")
        Button(isRecording ? "Stop Recording" : "Start Recording") {
                        if isRecording {
                            stopRecordingAndSave()
                        } else {
                            startRecording()
                        }
                        isRecording.toggle()
                    }
                .onChange(of: sensorData.xAngle) { newValue in
                    if isRecording {
                        recordedData.append((Int(newValue), Int(sensorData.xAngle2)))
                    }
                }
                
            }

private func startRecording() {
        recordedData.removeAll()
        // Additional setup if needed
    }

    private func stopRecordingAndSave() {
        saveToCSV(recordedData)
        recordedData.removeAll()
    }

    private func saveToCSV(_ data: [(Int, Int)]) {
        let fileName = "recordedData.csv"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory not found.")
            return
        }
    
        let filePath = documentDirectory.appendingPathComponent(fileName)
       
        var csvString = "Time, X Angle, X Angle2\n"

        for (index, (value1, value2)) in data.enumerated() {
                    let csvLine = "\(index),         \(Int(value1)),                  \(Int(value2))\n"
                    csvString.append(contentsOf: csvLine)
                }

        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            print("Saved to \(filePath)")
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
        }
    }
}


// Preview
struct SensorView_Previews: PreviewProvider {
    static var previews: some View {
        SensorView().environmentObject(SensorDataModel())
    }
}
