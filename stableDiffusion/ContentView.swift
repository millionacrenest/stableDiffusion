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
                TextField("Prompt", text: $generation.prompt)
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
            ImageWithPlaceholder()
                .scaledToFit()
            Spacer()
        }
        .environmentObject(generation)
        .padding()
    }
    
    func submit() {
        print(generation.prompt)
    }
}

struct ImageWithPlaceholder: View {
    
    let image = UIImage(named: "Placeholder") ?? UIImage()
        
    var body: some View {
                      
        let imageView = Image(uiImage: image).resizable()
        VStack {
            imageView.resizable().clipShape(RoundedRectangle(cornerRadius: 20))
            HStack {
                Rectangle().fill(.clear).overlay(
                    HStack {
                        Spacer()
                    }
                )
            }.frame(maxHeight: 25)
        }
    }
}
