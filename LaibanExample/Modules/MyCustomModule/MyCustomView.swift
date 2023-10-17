import SwiftUI
import Laiban

enum Step {
    case Home
    case Color
    case Shape
    case Render
}

struct SelectionView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    let items: [String]
    @Binding var selectedStep: Step
    @Binding var selectedItem: String?

    var body: some View {
        LBGridView(items: items.count, columns: 3) { i in
            let item = items[i]
            Button(item, action: { selectedItem = item })
                .padding(10)
                .background(.primary)
                .colorInvert()
                
        }
        .font(properties.font, ofSize: .xxl)
        .frame(maxWidth: .infinity)
        
        if selectedItem != nil {
            Text("Du har valt \(selectedStep == .Color ? "färgen" : "formen"): \(selectedItem!)")
                .font(properties.font, ofSize: .xxl)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            Text("Vilken \(selectedStep == .Color ? "färg" : "form") ska insekten ha?")
                .font(properties.font, ofSize: .xxl)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct HomeBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties

    var body: some View {
        Image("intro")
            .resizable()
            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
            .cornerRadius(18.0)
        Text("Vill du skapa en bild på en insekt utifrån form och färg? Tryck på insekten för att tala om för en artisifiell intelligens hur insekten ska se ut.")
            .font(properties.font, ofSize: .xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(20)
            .secondaryContainerBackground(borderColor: .purple)
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct RenderBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Binding var selectedColor: String?
    @Binding var selectedShape: String?
    
    var body: some View {
        Text("RENDER BUG VIEW")
            .font(properties.font, ofSize: .xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        Text(selectedColor!)
            .font(properties.font, ofSize: .xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        Text(selectedShape!)
            .font(properties.font, ofSize: .xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct MyCustomView: View {
    @Environment(\.fullscreenContainerProperties) var properties

    @State var selectedStep: Step = .Home
    @State var selectedColor: String?
    @State var selectedShape: String?

    var body: some View {
        VStack {
            if selectedStep == .Home {
                HomeBugView()
            }

            if selectedStep == .Color {
                SelectionView(items: ["red", "yellow", "blue", "black"],
                              selectedStep: $selectedStep,
                              selectedItem: $selectedColor)
            }

            if selectedStep == .Shape {
                SelectionView(items: ["square", "triangle", "cylinder"],
                              selectedStep: $selectedStep,
                              selectedItem: $selectedShape)
            }

            if selectedStep == .Render {
                RenderBugView(selectedColor: $selectedColor,
                              selectedShape: $selectedShape)
            }

            if selectedStep != .Render {
                Button("Gå vidare") {
                    switch selectedStep {
                        case .Home:
                            selectedStep = .Color
                        case .Color:
                            selectedStep = .Shape
                        case .Shape:
                            selectedStep = .Render
                        case .Render:
                            break
                    }
                }
            }

            Button("RESET") {
                selectedStep = .Color
                selectedColor = nil
                selectedShape = nil
            }
            .padding()
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
