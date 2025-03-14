//
//  ContentView.swift
//  StudyTimer
//
//  Created by Caleb Atchison on 3/14/25.
//

import SwiftUI

import SwiftUI

@main
struct StudyTimerApp: App {
    var body: some Scene {
        MenuBarExtra("Hello World", systemImage: "clock") {
            VStack {
                Text("Hello World!")
                    .font(.headline)
                    .padding()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        }
    }
}
