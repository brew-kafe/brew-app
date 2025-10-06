//
//  CameraView.swift
//  brew
//
//  Created by: toño
//

import SwiftUI
import AVFoundation

// MARK: - Main Camera View
struct CameraView: View {
    @StateObject var camera = CameraModel()
    @StateObject var viewModel = DiagnosisViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showDiagnosticForm = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 90)
                
                ZStack {
                    if camera.isTaken, let uiImage = UIImage(data: camera.picData) {
                        // Show captured image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 340, height: 450)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 88/255, green: 92/255, blue: 48/255), lineWidth: 10)
                            )
                    } else {
                        // Live camera preview
                        CameraPreview(camera: camera)
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 340, height: 450)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 88/255, green: 92/255, blue: 48/255), lineWidth: 10)
                            )
                    }
                }
                
                Spacer().frame(height: 25)
            }
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    if camera.isTaken {
                        Button(action: camera.reTake) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Processing indicator
            if camera.isProcessing {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                VStack(spacing: 12) {
                    ProgressView().scaleEffect(1.5).tint(.white)
                    Text("Procesando foto...").foregroundColor(.white).font(.headline)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                if camera.isTaken {
                    Button(action: {
                        if camera.picData.count > 0 {
                            showDiagnosticForm = true
                        } else {
                            camera.reTake()
                        }
                    }) {
                        Text("Diagnosticar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 32)
                            .background(Capsule().fill(Color(red: 88/255, green: 92/255, blue: 48/255)))
                    }
                    .disabled(camera.picData.isEmpty)
                    .opacity(camera.picData.isEmpty ? 0.5 : 1.0)
                } else {
                    Button(action: camera.takePic) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(32)
                            .background(Circle().fill(Color(red: 88/255, green: 92/255, blue: 48/255)))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 55)
        }
        .sheet(isPresented: $showDiagnosticForm) {
            DiagnosticFormView(
                imageData: camera.picData,
                viewModel: viewModel,
                onComplete: {
                    showDiagnosticForm = false
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Preview
#Preview {
    CameraView()
}
