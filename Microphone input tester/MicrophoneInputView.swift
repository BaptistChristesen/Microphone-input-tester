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
    @State private var audioSession = AVAudioSession.sharedInstance()

    var body: some View {
        VStack {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
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

    func startRecording() {
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)

            let audioSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 320000,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0
            ] as [String : Any]

            audioRecorder = try AVAudioRecorder(url: audioFileURL(), settings: audioSettings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            // Handle errors
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    func audioFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsDirectory.appendingPathComponent("recording.m4a")
        return audioFilename
    }
}

struct MicrophoneInputView_Previews: PreviewProvider {
    static var previews: some View {
        MicrophoneInputView()
    }
}
