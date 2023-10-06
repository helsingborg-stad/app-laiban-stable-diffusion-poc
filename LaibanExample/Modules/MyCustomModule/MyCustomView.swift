//
//  MyCustomView.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-19.
//

import SwiftUI
import Laiban
import Assistant

@available(iOS 16.2, *)
struct MyCustomView : View {
    @ObservedObject var service: MyCustomService

    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant

    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    
    @StateObject var imageGenerator = ImageGenerator()

    var body: some View {
        TextToImageView(imageGenerator: imageGenerator)
            .tabItem {
                Image(systemName: "text.below.photo.fill")
                Text("Text to Image")
            }
    }
}
