//
//  MyCustomView.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-19.
//

import SwiftUI
import Laiban
import Assistant

struct MyCustomView : View {
    @ObservedObject var service: MyCustomService
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var body: some View {
        Text("Detta är min Laiban-modul")
            .frame(maxWidth:.infinity,alignment: .leading)
            .padding(properties.spacing[.m])
            .font(properties.font, ofSize: .n)
            .primaryContainerBackground()
            .frame(maxHeight:.infinity,alignment: .bottom)
    }
}
