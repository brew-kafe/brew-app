//
//  DiagnosticView.swift
//  brew
//
//  Created by Regina Romero on 9/10/25.
//

import SwiftUI
import AVFoundation

struct DiagnosticView: View {
    var body: some View {
        CameraView()
    }
}


struct CameraView: View{
    @StateObject var camera = CameraModel()
    var body: some View{
        ZStack{
            Color.white.ignoresSafeArea()
            
            //Going to be a Camera preview
            VStack {
                Spacer(minLength: 150) // lower camera screen
                CameraPreview(camera: camera)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 350, height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 88/255, green: 92/255, blue: 48/255), lineWidth: 10)
                    )
                Spacer()
            }
            
            VStack {
                if camera.isTaken {
                    HStack {
                        Spacer()
                        Button(action: camera.reTake, label: {
                            Image(systemName:"arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing,10)
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
            camera.session.startRunning()
        }
        // action button above tab bar
        .safeAreaInset(edge: .bottom) {
            HStack {
                if camera.isTaken {
                    // after taking a pic, show "Diagnose"
                    Button(action: {
                        print("Diagnose tapped")
                    }) {
                        Text("Diagnosticar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 35)  //Bigger button
                            .background(Capsule().fill(Color(red: 88/255, green: 92/255, blue: 48/255)))
                    }
                } else {
                    // bigger camera button
                    Button(action: camera.takePic) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(32) // bigger
                            .background(
                                Circle().fill(Color(red: 88/255, green: 92/255, blue: 48/255)))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 65) // move it higher above the tab bar
            
        }
    }
}
                /*
                HStack{
                    //if taken showing save and again take button..
                    /*if camera.isTaken{
                        Button(action: {if !camera.isSaved{camera.savePic()}}, label: {
                            Text(camera.isSaved ? "Saved": "Save")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical,10)
                                .padding(.horizontal,20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading)
                        Spacer()
                        
                    }else{*/
                        Button(action: camera.takePic, label: {
                            ZStack{
                                Image(systemName: "camera.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                    .padding(22)
                                                    .background(Circle().fill(Color(red: 88/255, green: 92/255, blue: 48/255)))
                                //Circle()
                                    //.fill(Color.white)
                                    //.frame(width: 65, height: 65)
                                //Circle()
                                    //.stroke(Color.white, lineWidth: 2)
                                    //.frame(width: 75, height: 75)
                            }
                            .padding(.top, 8)
                        })
                    //}
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}*/

//Camera Model

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate{
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    
    //since we're going to read pic data
    @Published var output = AVCapturePhotoOutput()
    
    // preview...
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    //Pic Data...
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    func Check(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
            return
            //setting up session
        case .notDetermined:
            //retusting for permission
            AVCaptureDevice.requestAccess(for: .video) {
                (status) in
                if status{
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
    
    func setUp(){
        //setting up camera
        do{
            //setting configs
            self.session.beginConfiguration()
            
            //change for your own
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            guard let device = device else {
                print("No back camera available")
                return
            }
            let input = try AVCaptureDeviceInput(device: device)

            
            //checking and adding to session
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
                
            }
        
            //same for output...
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            self.session.commitConfiguration()
            
        }
        catch{
            print(error.localizedDescription)
        }
    }
    //take and retake functions
    func takePic(){
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async{
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    func reTake(){
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async{
                withAnimation{self.isTaken.toggle()}
                //clearing
                self.isSaved = false
            }
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            return
        }
        print("pic taken...")
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        self.picData = imageData
    }
    func savePic(){
        let image = UIImage(data: self.picData)!
        //saving Image..
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("Saved Successfully...")
    }
    
}
//setting view for preview..
struct CameraPreview: UIViewRepresentable{
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        //let view = UIView()
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // properties..
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        //starting session
        camera.session.startRunning()
        
        
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        //camera.preview?.frame = uiView.bounds
    }
}


#Preview {
    DiagnosticView()
}
