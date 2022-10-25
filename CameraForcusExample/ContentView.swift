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
        .onAppear { camera.start() }
        .onDisappear { camera.stop()}
    }
}

private struct CameraModifier: ViewModifier {

    @State var camera: Camera
    @State var tap = false
    @State var tapPosition = CGPoint(x: 0, y: 0)

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: tap ? 100 : 150, height: tap ? 100 : 150, alignment: .center)
                    .opacity(tap ? 1 : 0)
                    .position(x: tapPosition.x, y: tapPosition.y)
            )
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onEnded { value in
                        print("tapped location(view): ", value.location)
                        withAnimation(.easeInOut) {
                            tap = true
                        }
                        tapPosition = value.location
                        let point = camera.previewLayer?.captureDevicePointConverted(fromLayerPoint: value.location)
                        print("tapped location(camera): ", point ?? .zero)
                        camera.forcusAndExposure(point)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeInOut) {
                                tap = false
                            }
                        }
                    }
            )
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
