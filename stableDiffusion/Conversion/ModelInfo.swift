
import CoreML

struct ModelInfo {
    
    let modelURL: URL = URL(string: "https://huggingface.co/apple/coreml-stable-diffusion-2-1-base-palettized/resolve/main/coreml-stable-diffusion-2-1-base-palettized_split_einsum_v2_compiled.zip") ?? URL(fileURLWithPath: "")
    
    var reduceMemory: Bool {
        // Enable on iOS devices, except when using quantization
        //return !(quantized && deviceHas6GBOrMore)
        return true
    }
    
}
