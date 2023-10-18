//
//  ContentView.swift
//  Microphone input tester
//
//  Created by Caden Christesen on 10/13/23.
//

import SwiftUI
import AVFoundation

struct MicrophoneInputView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioEngine = AVAudioEngine()
    @State private var audioPlayerNode = AVAudioPlayerNode()
    @State private var micFrequency: Double = 0.0
    
    var body: some View {
        VStack {
            Text("Microphone Frequency: \(micFrequency) Hz")
                .font(.title)
                .padding()
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    requestMicrophonePermissionAndStartRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func requestMicrophonePermissionAndStartRecording() {
        AVAudioApplication.requestRecordPermission { (granted: Bool) in
            if granted {
                startRecording()
            } else {
                // Handle the case where permission is not granted
            }
        }
    }
    
    func startRecording() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
            
            let inputNode = audioEngine.inputNode
            let format = inputNode.inputFormat(forBus: 0)
            
            audioEngine.attach(audioPlayerNode)
            audioEngine.connect(inputNode, to: audioPlayerNode, format: format)
            
            let audioMixer = audioEngine.mainMixerNode
            let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
            audioEngine.connect(audioPlayerNode, to: audioMixer, format: recordingFormat)
            
            audioPlayerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                let fft = FFT(buffer: buffer)
                let frequency = fft.calculateFrequency()
                micFrequency = frequency
            }
            
            try audioEngine.start()
            
            isRecording = true
        } catch {
            // Handle errors, e.g., if audio permissions are denied
        }
    }
    
    func stopRecording() {
        // Stop the audio engine and remove the tap
        audioEngine.stop()
        audioPlayerNode.removeTap(onBus: 0)
        isRecording = false
    }
}
