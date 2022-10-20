//
//  PhotoPreviewLayer.swift
//  CameraForcusExample
//

import SwiftUI

struct PhotoPreviewView: UIViewRepresentable {

    let layer: CALayer
    let size: CGSize

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        view.layer.addSublayer(layer)
        layer.frame = view.frame
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.frame.size = size
        layer.frame.size = size
    }

}
