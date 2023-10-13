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

    init(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer
    }

    func calculateFrequency() -> Double {
        guard let floatChannelData = buffer.floatChannelData else {
            return 0.0
        }

        let channelData = floatChannelData[0]
        let sampleCount = vDSP_Length(buffer.frameLength)

        var real = [Float](repeating: 0.0, count: Int(sampleCount))
        var imag = [Float](repeating: 0.0, count: Int(sampleCount))

        var complexBuffer = [DSPComplex](repeating: DSPComplex(), count: Int(sampleCount))
        
        for i in 0..<Int(sampleCount) {
            complexBuffer[i].real = channelData[i]
            complexBuffer[i].imag = 0.0
        }

        vDSP_ctoz(complexBuffer, 2, UnsafeMutablePointer(&complexBuffer), 1, sampleCount / 2)

        let log2n = vDSP_Length(log2f(Float(sampleCount)))
        let radix = FFTRadix(kFFTRadix2)
        let weights = vDSP_create_fftsetup(log2n, radix)

                                vDSP_fft_zip(weights!, UnsafeMutablePointer(&complexBuffer), 1, log2n, FFTDirection(FFT_FORWARD)) 

        var magnitudes = [Float](repeating: 0.0, count: Int(sampleCount / 2))
        vDSP_zvmags(&complexBuffer, 1, &magnitudes, 1, sampleCount / 2)

        var frequency: Double = 0.0
        var magnitude: Float = -1.0

        for i in 0..<(sampleCount / 2) {
            if magnitudes[Int(i)] > magnitude {
                magnitude = magnitudes[Int(i)]
                frequency = Double(i)
            }
        }

        vDSP_destroy_fftsetup(weights)

        return Double(frequency * Double(buffer.format.sampleRate) / Double(sampleCount))
    }
}
