import Combine
import SwiftUI
import StableDiffusion
import CoreML

enum GenerationState {
    case startup
    case running(StableDiffusionProgress?)
    case complete(String, CGImage?, UInt32, TimeInterval?)
    case userCanceled
    case failed(Error)
}

// explain this to me like I'm 5
typealias ComputeUnits = MLComputeUnits

class GenerationContext: ObservableObject {
    
    // explore results of changing this setting
    let scheduler = StableDiffusionScheduler.dpmSolverMultistepScheduler
    
    @Published var pipeline: Pipeline? = nil
    @Published var state: GenerationState = .startup
    
    @Published var positivePrompt = ""
    @Published var negativePrompt = ""
    
    // FIXME: Double to support the slider component
    @Published var steps = 3.0
    @Published var numImages = 1.0
    @Published var seed = -1.0
    @Published var guidanceScale = 7.5
    @Published var disableSafety = false
    
    func generate() async throws -> GenerationResult {
        guard let pipeline = pipeline else { throw "No pipeline" }
        let seed = self.seed >= 0 ? UInt32(self.seed) : nil
        return try pipeline.generate(
            prompt: positivePrompt,
            negativePrompt: negativePrompt,
            scheduler: scheduler,
            numInferenceSteps: Int(steps),
            seed: seed,
            guidanceScale: Float(guidanceScale),
            disableSafety: disableSafety
        )
    }
    
}
