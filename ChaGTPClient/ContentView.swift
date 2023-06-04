//
//  ContentView.swift
//  ChaGTPClient
//
//  Created by matteo deliperi on 04/06/23.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "")
    }

    func send(text: String,
              completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               model: .gpt3(.davinci),
                               maxTokens: 500,
                               completionHandler: { result in
            switch result {
                case .success(let model):
                    let output = model.choices?.first?.text ?? ""
                    completion(output)
                case .failure:
                    break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    
    var body: some View {
        VStack {
            HStack {
                Text("ChatGPT Client").padding()
            }

            ScrollView {
                ForEach(models, id: \.self) { string in
                    HStack {
                        Text(string)
                            .padding()
                        Spacer()
                    }
                }
            }

            HStack {
                TextField("Type here...", text: $text)
                    .padding()
                Button("Send") {
                    send()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }

    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }

        models.append("Me: \(text)")
        viewModel.send(text: text) {repsonse in
            DispatchQueue.main.async {
                self.models.append("ChatGPT: " + repsonse)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
