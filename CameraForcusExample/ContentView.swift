//
//  ContentView.swift
//  CameraForcusExample
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var camera: Camera

    var previewSize: CGSize {
        .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    init() {
        self.camera = Camera()
    }

    var body: some View {
        VStack {
            if let layer = camera.previewLayer {
                PhotoPreviewView(layer: layer, size: previewSize)
                    .frame(width: previewSize.width, height: previewSize.height)
                    .addCamera(camera)
            }
        }
        .onAppear { camera.start()
            print("Appear") }
        .onDisappear { camera.stop()
            print("Disappear")}
    }
}

private struct CameraModifier: ViewModifier {

    @State var camera: Camera
    @State var tapPositionState: CGPoint?

    func body(content: Content) -> some View {

        if let position = tapPositionState {
            content
                .overlay(
                    Rectangle()
                        .stroke(Color.yellow, lineWidth: 2)
                        .frame(width: 100, height: 100, alignment: .center)
                        .position(x: position.x, y: position.y)
                        .animation(nil)
                        .transition(.scale)
                        .onAppear { print("onAppear(transition)") }
                        .onDisappear { print("onDisappear(transition)") }
                )
        } else {
            content
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onEnded { value in
                            print("tapped location(view): ", value.location)
                            tapPositionState = value.location
                            let point = camera.previewLayer?.captureDevicePointConverted(fromLayerPoint: value.location)
                            print("tapped location(camera): ", point ?? .zero)
                            camera.forcusAndExposure(point)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                tapPositionState = nil
                            }
                        }
                )
                .onAppear { print("onAppear(gesture)") }
                .onDisappear { print("onDisappear(gesture)") }
        }
    }
}

extension View {
    func addCamera(_ camera: Camera) -> some View {
        modifier(CameraModifier(camera: camera))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
