//
//  Camera.swift
//  CameraForcusExample
//

import AVFoundation

final class Camera: NSObject, ObservableObject {

    @Published var previewLayer: AVCaptureVideoPreviewLayer? = nil

    private let session = AVCaptureSession()
    private let device = AVCaptureDevice.default(for: .video)
    private var input: AVCaptureInput? = nil {
        willSet {
            guard let input = input else { return }
            session.removeInput(input)
        }
        didSet {
            guard let input = input else { return }
            session.addInput(input)
        }
    }

    func setupCamera() {

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized, .restricted:
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                }
            }
        case .denied:
            break
        @unknown default:
            break
        }
    }

    func setupSession() {

        guard let device = device else { return }

        session.beginConfiguration()
        session.sessionPreset = .photo

        input = try? AVCaptureDeviceInput(device: device)

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspect
        previewLayer?.connection?.videoOrientation = .portrait

        session.commitConfiguration()
    }

    func start() {
        setupCamera()
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        self.session.stopRunning()
    }

    func forcusAndExposure(_ point: CGPoint?) {
        guard let point = point, let device = device else { return }
        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus

            device.exposurePointOfInterest = point
            device.exposureMode = .autoExpose

            device.unlockForConfiguration()
        } catch let error {
            print(error)
        }
    }
}
