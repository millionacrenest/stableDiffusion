//
//  ContentView.swift
//  stableDiffusion
//
//  Created by Allison McEntire on 6/25/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @StateObject var generation = GenerationContext()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Prompt", text: $generation.positivePrompt)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        submit()
                    }
                Button("Generate") {
                    submit()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            ImageWithPlaceholder(state: $generation.state)
                .scaledToFit()
            Spacer()
        }
        .environmentObject(generation)
        .onAppear {
            Task.init {
                let loader = PipelineLoader(model: ModelInfo())
                do {
                    generation.pipeline = try await loader.prepare()
                } catch {
                    print("trm error", error)
                }
            }
        }
        .padding()
    }

    func submit() {
        Task {
            do {
                let result = try await generation.generate()
                generation.state = .complete(generation.positivePrompt, result.image, result.lastSeed, result.interval)
                print("trm image", result.image.debugDescription)
            } catch {
                print("trm error", error)
            }
        }
    }
}

struct ImageWithPlaceholder: View {
    var state: Binding<GenerationState>
    
    
        
    var body: some View {
        
        switch state.wrappedValue {
        
        case .complete(_, let image, _, let interval):
            guard let theImage = image else {
                return AnyView(Image(systemName: "exclamationmark.triangle").resizable())
            }
            let imageView = Image(theImage, scale: 1, label: Text("generated"))
            return AnyView(
                VStack {
                    imageView.resizable().clipShape(RoundedRectangle(cornerRadius: 20))
                    HStack {
                        let intervalString = String(format: "Time: %.1fs", interval ?? 0)
                        Rectangle().fill(.clear).overlay(Text(intervalString).frame(maxWidth: .infinity, alignment: .leading).padding(.leading))
                        Rectangle().fill(.clear).overlay(
                            HStack {
                                Spacer()
                            }
                        )
                    }.frame(maxHeight: 25)
            })
        
        case .startup:
            return AnyView(Image("Placeholder").resizable())
        default: return AnyView(Image(systemName: "pencil").resizable())
        }
    }
}
