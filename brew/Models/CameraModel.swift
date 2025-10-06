//
//  CameraModel.swift
//  brew
//
//  Created by toño on 06/10/25.
//

import SwiftUI
import AVFoundation

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    // MARK: - Published properties
    @Published var isTaken = false
    @Published var isSaved = false
    @Published var isProcessing = false
    @Published var picData = Data()
    @Published var alert = false
    
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // MARK: - Check camera permissions
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { self.setupSession() }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { self.alert = true }
        @unknown default:
            break
        }
    }
    
    // MARK: - Setup session
    func setupSession() {
        do {
            session.beginConfiguration()
            
            // Set preset for photos
            if session.canSetSessionPreset(.photo) {
                session.sessionPreset = .photo
            }
            
            // Select back camera
            guard let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("❌ No back camera found")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: cameraDevice)
            if session.canAddInput(input) { session.addInput(input) }
            
            // Configure photo output
            output.maxPhotoQualityPrioritization = .quality
            if session.canAddOutput(output) { session.addOutput(output) }
            
            session.commitConfiguration()
            
            // Start session
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
                print("▶️ Camera session started")
            }
        } catch {
            print("❌ Camera setup error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Take photo
    func takePic() {
        let settings: AVCapturePhotoSettings

        if output.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }

        settings.photoQualityPrioritization = .quality
        DispatchQueue.main.async { self.isProcessing = true }
        output.capturePhoto(with: settings, delegate: self)

    }
    
    // MARK: - Retake photo
    func reTake() {
        DispatchQueue.main.async {
            withAnimation {
                self.isTaken = false
                self.picData = Data()
                self.isSaved = false
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            print("▶️ Camera session restarted")
        }
    }
    
    // MARK: - Delegate method
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async { self.isProcessing = false }
        
        if let error = error {
            print("❌ Photo capture error: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            print("❌ Failed to get image data")
            return
        }
        
        DispatchQueue.main.async {
            self.picData = data
            self.isTaken = true
            print("✅ Photo captured, size: \(data.count) bytes")
        }
        
        // Stop session after capture
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
            print("⏸️ Camera session stopped")
        }
    }
    
    // MARK: - Save photo
    func savePic() {
        guard let image = UIImage(data: picData) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        DispatchQueue.main.async { self.isSaved = true }
        print("✅ Photo saved to library")
    }
}
