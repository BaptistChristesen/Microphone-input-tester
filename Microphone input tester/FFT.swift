//
//  FFT.swift
//  Microphone input tester
//
//  Created by Caden Christesen on 10/13/23.
//

import Accelerate
import AVFoundation

class FFT {
    var buffer: AVAudioPCMBuffer
        var real: [Float] // Declare as instance properties
        var imag: [Float]

        init(buffer: AVAudioPCMBuffer) {
            self.buffer = buffer
            real = [Float](repeating: 0.0, count: Int(buffer.frameLength))
            imag = [Float](repeating: 0.0, count: Int(buffer.frameLength))
        }
    
    func calculateFrequency() -> Double {
        guard let floatChannelData = buffer.floatChannelData else {
            return 0.0
        }
        
        let channelData = floatChannelData[0]
        let sampleCount = vDSP_Length(buffer.frameLength)
        
        // Initialize arrays for real and imaginary parts of the signal
        var real = [Float](repeating: 0.0, count: Int(sampleCount))
        var imag = [Float](repeating: 0.0, count: Int(sampleCount))
        
        // Create a complex buffer from the audio signal
        var complexBuffer = [DSPComplex](repeating: DSPComplex(), count: Int(sampleCount))
        for i in 0..<Int(sampleCount) {
            complexBuffer[i].real = channelData[i]
            complexBuffer[i].imag = 0.0
        }
        
        // Initialize a split complex buffer
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)
        
        let log2n = vDSP_Length(log2f(Float(sampleCount)))
        let radix = FFTRadix(kFFTRadix2)
        
        // Create the FFT setup with error handling
        guard let weights = vDSP_create_fftsetup(log2n, radix) else {
            // Handle the case where FFT setup fails
            print("Failed to create FFT setup")
            return 0.0 // Return an appropriate default value or handle the error as needed
        }
        
        // Perform the FFT
        vDSP_fft_zip(weights, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // Compute magnitude of each frequency component
        var magnitudes = [Float](repeating: 0.0, count: Int(sampleCount / 2))
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, sampleCount / 2)
        
        var frequency: Double = 0.0
        var magnitude: Float = -1.0
        
        // Find the frequency with the highest magnitude
        for i in 0..<(sampleCount / 2) {
            if magnitudes[Int(i)] > magnitude {
                magnitude = magnitudes[Int(i)]
                frequency = Double(i)
            }
        }
        
        // Destroy the FFT setup to free resources
        vDSP_destroy_fftsetup(weights)
        
        // Calculate and return the frequency in Hertz
        return Double(frequency * Double(buffer.format.sampleRate) / Double(sampleCount))
    }
}
