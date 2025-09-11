//
//  DiagnosticView.swift
//  brew
//
//  Created by Regina Romero on 9/10/25.
//

import SwiftUI
import AVFoundation

// The main DiagnosticView that includes the CameraView
struct DiagnosticView: View {
    var body: some View {
        CameraView()
    }
}

// CameraView: View that handles the camera preview and buttons for taking/retaking a picture
struct CameraView: View {
    @StateObject var camera = CameraModel()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                Spacer(minLength: 90) // lower camera screen
                CameraPreview(camera: camera) // Camera preview in a custom view
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 340, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255), lineWidth: 10)
                    )
                Spacer()
                    .frame(height: 25)
            }

            VStack {
                if camera.isTaken {
                    HStack {
                        Spacer()
                        Button(action: camera.reTake, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing, 10)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            camera.Check()
            camera.isTaken = false
            camera.isSaved = false
            camera.picData = Data()
            camera.session.startRunning() // Start the session when view appears
        }

        // Action button above tab bar
        .safeAreaInset(edge: .bottom) {
            HStack {
                if camera.isTaken {
                    // After taking a picture, show "Diagnose"
                    Button(action: {
                        print("Diagnose tapped")
                    }) {
                        Text("Diagnosticar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 32)  // Bigger button
                            .background(Capsule().fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255)))
                    }
                } else {
                    // Bigger camera button
                    Button(action: camera.takePic) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(32) // Bigger
                            .background(
                                Circle().fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255)))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 55) // Move it higher above the tab bar
        }
    }
}

// CameraModel: Handles all camera-related logic
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false

    // Since we're going to read pic data
    @Published var output = AVCapturePhotoOutput()

    // Preview...
    @Published var preview: AVCaptureVideoPreviewLayer!

    // Pic Data...
    @Published var isSaved = false
    @Published var picData = Data(count: 0)

    func Check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            // Requesting for permission
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }

    func setUp() {
        // Setting up the camera
        do {
            // Session configuration
            self.session.beginConfiguration()

            // Use the back camera (Wide-angle)
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            guard let device = device else {
                print("No back camera available")
                return
            }
            let input = try AVCaptureDeviceInput(device: device)

            // Adding input to the session
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }

            // Adding output to session
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()

        } catch {
            print(error.localizedDescription)
        }
    }

    // Take and retake functions
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()

            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
            }
        }
    }

    func reTake() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()

            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
                // Resetting
                self.isSaved = false
            }
        }
    }

    // Photo output
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        print("Pic taken...")
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        self.picData = imageData
    }

    // Save picture to the album
    func savePic() {
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        self.isSaved = true

        print("Saved Successfully...")
    }
}

// CameraPreview: View to show the camera preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        // Create and set up the preview layer
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame

        // Set video gravity (aspect fill)
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)

        // Start the session
        camera.session.startRunning()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to update anything here
    }
}

#Preview {
    DiagnosticView()
}
