//
//  ContentView.swift
//  StudyTimer
//
//  Created by Caleb Atchison on 3/14/25.
//

import SwiftUI
import AppKit

@main
struct StudyTimerApp: App {
    @StateObject var timerModel = TimerModel()
    
    var body: some Scene {
        MenuBarExtra {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondary)
                            .font(.system(size: 12))
                            .opacity(0.8)
                    }
                    .buttonStyle(.borderless)
                }
                // The main popover content
                TimerView()
                    .environmentObject(timerModel)
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 240)
            .background(.ultraThinMaterial)
        } label: {
            // The label in the menu bar
            HStack {
                Image(systemName: "timer")
                    .frame(width: 20, alignment: .center)
                
                // Display the countdown in the menu bar
                Text(timerModel.timerString)
                    .font(.custom("Menlo", size: 12))
                    .animation(nil, value: timerModel.timerString)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

struct TimerView: View {
    @EnvironmentObject var timerModel: TimerModel
    @State private var minutesText = ""
    @State private var secondsText = ""
    @FocusState private var isMinutesFocused: Bool
    @FocusState private var isSecondsFocused: Bool
    
    var body: some View {
        VStack {
            // HStack for the two entry fields and a static colon
            HStack(alignment: .center, spacing: 4) {
                // Minutes numeric text field
                NumericTextField(
                    text: $minutesText,
                    placeholder: "00",
                    showCursor: !timerModel.isTimerRunning,
                    font: NSFont.monospacedSystemFont(ofSize: 80, weight: .regular),
                    onCommit: nil,
                    onArrowLeft: nil,
                    onArrowRight: {
                        // Move focus to seconds field when right arrow is pressed
                        isMinutesFocused = false
                        isSecondsFocused = true
                    }
                )
                .frame(width: 100, height: 100)
                .focusable(true)
                
                // Static colon
                Text(":")
                    .font(.system(size: 80, design: .monospaced))
                
                // Seconds numeric text field
                NumericTextField(
                    text: $secondsText,
                    placeholder: "00",
                    showCursor: !timerModel.isTimerRunning,
                    font: NSFont.monospacedSystemFont(ofSize: 80, weight: .regular),
                    onCommit: nil,
                    onArrowLeft: {
                        // Move focus to minutes field when left arrow is pressed
                        isSecondsFocused = false
                        isMinutesFocused = true
                    },
                    onArrowRight: nil
                )
                .frame(width: 100, height: 100)
                .focusable(true)
            }
            .onAppear {
                // Split the current timer string (assumed to be in "MM:SS" format)
                let components = timerModel.timerString.split(separator: ":")
                if components.count == 2 {
                    minutesText = String(components[0])
                    secondsText = String(components[1])
                }
            }
            .onChange(of: timerModel.timerString) { oldValue, newVal in
                let comps = newVal.split(separator: ":")
                if comps.count == 2 {
                    minutesText = String(comps[0])
                    secondsText = String(comps[1])
                }
            }
            
            // Buttons to control the timer remain unchanged...
            HStack {
                Button {
                    if timerModel.isTimerRunning {
                        timerModel.pauseTimer()
                        let comps = timerModel.timerString.split(separator: ":")
                        if comps.count == 2 {
                            minutesText = String(comps[0])
                            secondsText = String(comps[1])
                        }
                    } else {
                        // Commit the current fields before starting
                        commitTimerValue()
                        timerModel.startTimer()
                    }
                } label: {
                    if timerModel.isTimerRunning {
                        Image(systemName: "pause.circle.fill")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 30))
                    } else {
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 30))
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button {
                    timerModel.cancelTimer()
                    let comps = timerModel.timerString.split(separator: ":")
                    if comps.count == 2 {
                        minutesText = String(comps[0])
                        secondsText = String(comps[1])
                    }
                } label: {
                    if timerModel.isTimerRunning {
                        Image(systemName: "stop.circle.fill")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 30))
                    } else {
                        Image(systemName: "stop.circle.fill")
                            .foregroundStyle(Color.secondary)
                            .font(.system(size: 30))
                            .opacity(0.5)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .frame(width: 250, height: 150)
        .padding()
    }
    
    private func commitTimerValue() {
        if let m = Int(minutesText.trimmingCharacters(in: .whitespaces)),
           let s = Int(secondsText.trimmingCharacters(in: .whitespaces)) {
            timerModel.setTime(minutes: m, seconds: s)
        } else {
            print("Invalid input format")
        }
    }
}

class CustomNSTextField: NSTextField {
    var onArrowLeft: (() -> Void)?
    var onArrowRight: (() -> Void)?
    
    override func keyDown(with event: NSEvent) {
        // Left arrow key code: 123, Right arrow key code: 124
        if event.keyCode == 123 {
            onArrowLeft?()
        } else if event.keyCode == 124 {
            onArrowRight?()
        } else {
            super.keyDown(with: event)
        }
    }
}

struct NumericTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var showCursor: Bool = true
    var font: NSFont = NSFont.monospacedSystemFont(ofSize: 80, weight: .regular)
    var onCommit: (() -> Void)? = nil
    var onArrowLeft: (() -> Void)? = nil
    var onArrowRight: (() -> Void)? = nil

    func makeNSView(context: Context) -> CustomNSTextField {
        let textField = CustomNSTextField(frame: .zero)
        textField.placeholderString = placeholder
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.font = font
        textField.delegate = context.coordinator
        textField.isEditable = true
        textField.isSelectable = true
        textField.onArrowLeft = onArrowLeft
        textField.onArrowRight = onArrowRight
        return textField
    }
    
    func updateNSView(_ nsView: CustomNSTextField, context: Context) {
        nsView.stringValue = text
        nsView.font = font

        // Fetch the field editor (NSTextView) if the text field is being edited.
        if let fieldEditor = nsView.currentEditor() as? NSTextView {
            fieldEditor.insertionPointColor = showCursor ? NSColor.controlAccentColor : NSColor.clear
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NumericTextField
        init(_ parent: NumericTextField) {
            self.parent = parent
        }
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                // Filter out non-numeric characters
                parent.text = textField.stringValue.filter { $0.isNumber }
            }
        }
        func controlTextDidEndEditing(_ obj: Notification) {
            parent.onCommit?()
        }
    }
}
