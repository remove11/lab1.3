//
//  FileContentView.swift
//  bletest11
//
//  Created by User on 2023-12-12.
//

import SwiftUI

struct FileContentView: View {
    @State private var fileContents = ""

    var body: some View {
        VStack {
            ScrollView {
                Text(fileContents.isEmpty ? "No Data" : fileContents)
                    .padding()
            }
        }
        .navigationBarTitle("File Contents", displayMode: .inline)
        .onAppear(perform: readFile)
    }

    private func readFile() {
        let fileName = "recordedData.csv"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fileContents = "Document directory not found."
            return
        }
        let filePath = documentDirectory.appendingPathComponent(fileName)

        do {
            fileContents = try String(contentsOf: filePath, encoding: .utf8)
        } catch {
            fileContents = "Error reading file: \(error.localizedDescription)"
        }
    }
}



