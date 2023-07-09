import Foundation
import Path
import ZIPFoundation
import Combine
import StableDiffusion
import CoreML

class PipelineLoader {
    static let models = Path.applicationSupport / "hf-diffusion-models"
    
    let model: ModelInfo
    let computeUnits: ComputeUnits
    let maxSeed: UInt32
    
    private(set) var downloader: Downloader? = nil
    private var downloadSubscriber: Cancellable?
    
    init(model: ModelInfo, computeUnits: ComputeUnits? = nil, maxSeed: UInt32 = UInt32.max) {
        self.model = model
        self.computeUnits = computeUnits ?? .cpuAndNeuralEngine
        self.maxSeed = maxSeed
    }
    
    func prepare() async throws -> Pipeline {
        do {
            try PipelineLoader.models.mkdir(.p)
            try await download()
            try await unzip()
            let pipeline = try await load(url: compiledPath.url)
            return Pipeline(pipeline, maxSeed: maxSeed)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func download() async throws -> URL {
        if ready || downloaded { return downloadedURL }
        let downloader = Downloader(from: url, to: downloadedURL)
        self.downloader = downloader
        downloadSubscriber = downloader.downloadState.sink { state in
            if case .downloading(let progress) = state {
                print("trm progress", progress)
                print("trm state", state)
            }
        }
        try downloader.waitUntilDone()
        return downloadedURL
    }
    
    func unzip() async throws {
        guard downloaded else { return }
        do {
            try FileManager().unzipItem(at: downloadedURL, to: uncompressPath.url)
        } catch {
            // Cleanup if error occurs while unzipping
            try uncompressPath.delete()
            throw error
        }
        try downloadedPath.delete()
    }
    
    func load(url: URL) async throws -> StableDiffusionPipeline {
        let beginDate = Date()
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        let pipeline = try StableDiffusionPipeline(resourcesAt: url,
                                                   controlNet: [],
                                                   configuration: configuration,
                                                   disableSafety: false,
                                                   reduceMemory: model.reduceMemory)
        try pipeline.loadResources()
        print("trm: Pipeline loaded in \(Date().timeIntervalSince(beginDate))")
        
        return pipeline
    }
}

extension PipelineLoader {
    var url: URL {
        return model.modelURL
    }
    
    var filename: String {
        return url.lastPathComponent
    }
    
    var downloadedPath: Path { PipelineLoader.models / filename }
    var downloadedURL: URL { downloadedPath.url }
    
    var uncompressPath: Path { downloadedPath.parent }

    var packagesFilename: String { downloadedPath.basename(dropExtension: true) }
    var compiledPath: Path { downloadedPath.parent/packagesFilename }
    
    var downloaded: Bool {
        return downloadedPath.exists
    }
    
    var ready: Bool {
        return compiledPath.exists
    }
}
