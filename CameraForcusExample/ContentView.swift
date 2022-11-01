//
//  ContentView.swift
//  CameraForcusExample
//

import SwiftUI
import Combine

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
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }
}

private struct CameraModifier: ViewModifier {

    @Namespace var id

    @State var camera: Camera
    @State var tapPositionState: CGPoint?

    let publisher = PassthroughSubject<CGPoint, Never>()

    @ViewBuilder
    var sight: some View {
        GeometryReader { geometry in
            if let position = tapPositionState {
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 100, height: 100, alignment: .center)
                    .transition(.opacity.combined(with: .scale(scale: 1.25, anchor: UnitPoint(x: position.x / geometry.size.width, y: position.y / geometry.size.height))))
                    .position(x: position.x, y: position.y)
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: id)
            .overlay(sight)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named(id))
                    .onEnded { value in
                        print("tapped location(view): ", value.location)
                        publisher.send(value.location)
                        let point = camera.previewLayer?.captureDevicePointConverted(fromLayerPoint: value.location)
                        print("tapped location(camera): ", point ?? .zero)
                        camera.forcusAndExposure(point)
                    }
            )
            .onReceive(publisher) { value in
                withAnimation {
                    tapPositionState = value
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if value == tapPositionState {
                        withAnimation {
                            tapPositionState = nil
                        }
                    }
                }
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
