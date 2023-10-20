import SwiftUI
import Laiban

struct MyCustomView: View {
    @Environment(\.fullscreenContainerProperties) var properties

    var body: some View {
        VStack {
            Text("HEPP")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
    }
}

struct MyCustomView_Preview: PreviewProvider {
    static var previews: some View {
        LBFullscreenContainer { _ in
            MyCustomView()
        }.attachPreviewEnvironmentObjects()
    }
}
