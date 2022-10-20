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
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onEnded { value in
                                print("tapped location(view): ", value.location)
                                let point = camera.previewLayer?.captureDevicePointConverted(fromLayerPoint: value.location)
                                print("tapped location(camera): ", point ?? .zero)
                                camera.forcusAndExposure(point)
                            }
                    )
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop()}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
