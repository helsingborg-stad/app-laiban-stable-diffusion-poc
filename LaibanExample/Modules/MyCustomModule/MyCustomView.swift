import SwiftUI
import Laiban

enum Step: String {
    case Home = "Home"
    case Color = "Välj färg"
    case Shape = "Välj form"
    case Bug = "Välj insekt"
    case Render = "Rendera"
}

struct SelectionView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    let items: [String: String]
    @Binding var selectedStep: Step
    @Binding var selectedItem: String?

    var body: some View {
        LBGridView(items: items.count, columns: 3) { i in
            let item = Array(items.keys)[i]
            Button(action: { selectedItem = items[item] }) {
                Image(item)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250, alignment: .center)
                    .padding(10)
                    .shadow(color: selectedItem == items[item] ? Color.gray : Color.clear, radius: 2.0)
                    
            }
        }
        .frame(maxWidth: .infinity)

        let displayText: String = selectedItem != nil ? "Prompt: \(selectedItem!)" : selectedStep.rawValue

        Text(displayText)
            .font(properties.font, ofSize: .xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .frame(
                maxWidth: .infinity,
                alignment: .leading)
            .padding(properties.spacing[.s])
            .secondaryContainerBackground(borderColor: .purple)
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct RenderBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Binding var selectedColor: String?
    @Binding var selectedShape: String?
    @Binding var selectedBug: String?
    
    var body: some View {
        let prompt: String = "\(selectedColor!) \(selectedShape!) \(selectedBug!)"

        Text("THIS IS THE RENDER VIEW")
            .font(properties.font, ofSize: .xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        Text(prompt)
            .font(properties.font, ofSize: .xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct MyCustomView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    
    let colorImageTextMapping: [String: String] = [
        "splash.red": "color red",
        "splash.blue": "color blue",
        "splash.yellow": "color yellow",
    ]

    let shapeImageTextMapping: [String: String] = [
        "shape.square": "square shape",
        "shape.tri": "triangle shape",
        "shape.circle": "circle shape",
    ]

    let bugImageTextMapping: [String: String] = [
        "bug.beatle": "bug beatle",
        "bug.butterfly": "bug butterfly",
        "bug.wasp": "bug wasp",
    ]
    
    @State var selectedStep: Step = .Home
    @State var selectedColorImageName: String?
    @State var selectedShapeImageName: String?
    @State var selectedBugImageName: String?

    var body: some View {
        VStack {
            if selectedStep == .Home {
                HomeBugView()
            }

            if selectedStep == .Color {
                SelectionView(items: colorImageTextMapping,
                              selectedStep: $selectedStep,
                              selectedItem: $selectedColorImageName)
            }

            if selectedStep == .Shape {
                SelectionView(items: shapeImageTextMapping,
                              selectedStep: $selectedStep,
                              selectedItem: $selectedShapeImageName)
            }

            if selectedStep == .Bug {
                SelectionView(items: bugImageTextMapping,
                              selectedStep: $selectedStep,
                              selectedItem: $selectedBugImageName)
            }

            if selectedStep == .Render {
                RenderBugView(selectedColor: $selectedColorImageName,
                              selectedShape: $selectedShapeImageName,
                              selectedBug: $selectedBugImageName)
            }

            if selectedStep != .Render {
                Button("Gå vidare") {
                    switch selectedStep {
                        case .Home:
                            selectedStep = .Color
                        case .Color:
                            selectedStep = .Shape
                        case .Shape:
                            selectedStep = .Bug
                        case .Bug:
                            selectedStep = .Render
                        default:
                            break
                    }
                }
            }

            Button("RESET") {
                selectedStep = .Home
                selectedColorImageName = nil
                selectedShapeImageName = nil
                selectedBugImageName = nil
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
