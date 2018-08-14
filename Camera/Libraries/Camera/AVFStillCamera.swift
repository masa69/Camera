
import UIKit
import AVFoundation

class AVFStillCamera: UIView, AVCapturePhotoCaptureDelegate {
    
    var finishCapture: ((_ image: UIImage?) -> Void)?
    
    private var session: AVCaptureSession = AVCaptureSession()
    private var output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var device: AVCaptureDevice?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private(set) var flashMode: AVCaptureDevice.FlashMode = .off
    private var cameraPosition: AVCaptureDevice.Position {
        return (self.isFrontCamera)
            ? AVCaptureDevice.Position.front
            : AVCaptureDevice.Position.back
    }
    
    private var isReadyVideoInput: Bool = false
    private var isReadyVideoOutput: Bool = false
    
    private var isReady: Bool = false
    private var isCapturing: Bool = false
    
    private var isFrontCamera: Bool = false
    private var currentZoomScale: CGFloat = 1.0
    
    private let sessionQueue: DispatchQueue = DispatchQueue(label: "sessionQueue")
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.black
        self.session.sessionPreset = .photo
    }
    
    
    func start() {
        if self.isReady {
            return
        }
        self.sessionQueue.async {
            
            self.addVideoInput()
            self.addVideoOutput()
            
            if !self.isReadyVideoInput
                || !self.isReadyVideoOutput {
                return
            }
            self.startSession {
                DispatchQueue.main.async {
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                    
                    guard let layer: AVCaptureVideoPreviewLayer = self.previewLayer else {
                        print(3)
                        return
                    }
                    
                    layer.videoGravity = .resizeAspectFill
                    layer.connection?.videoOrientation = .portrait
                    layer.position = CGPoint(x: 0, y: 0)
                    layer.frame = self.bounds
                    
                    self.layer.sublayers = nil
                    self.layer.addSublayer(layer)
                }
            }
        }
    }
    
    
    func finish() {
        self.stopSession {}
    }
    
    
    private func startSession(callback: () -> Void) {
        if self.isReady {
            callback()
            return
        }
        self.session.startRunning()
        self.isReady = true
        callback()
    }
    
    
    private func stopSession(callback: () -> Void) {
        if !self.isReady {
            callback()
            return
        }
        self.session.stopRunning()
        self.isReady = false
        callback()
    }
    
    
    private func addVideoInput() {
        if !self.isReadyVideoInput {
            do {
                // builtInWideAngleCamera 10.0 〜 標準カメラ
                // builtInDualCamera 10.2 〜
                guard let videoDevice: AVCaptureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDualCamera, for: AVMediaType.video, position: self.cameraPosition) else {
                    guard let videoDevice: AVCaptureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: self.cameraPosition) else {
                        return
                    }
                    // フレームレートの設定
//                    videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                    let videoInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    self.session.addInput(videoInput)
                    self.device = videoDevice
                    self.isReadyVideoInput = true
                    return
                }
                // フレームレートの設定
//                videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                let videoInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                self.session.addInput(videoInput)
                self.device = videoDevice
                self.isReadyVideoInput = true
            } catch {
                return
            }
        }
    }
    
    
    private func addVideoOutput() {
        if !self.isReadyVideoOutput {
            self.session.addOutput(self.output)
            self.isReadyVideoOutput = true
        }
    }
    
    
    func ajustCameraScreen(view: UIView, point: CGPoint, focusMode: AVCaptureDevice.FocusMode, expusureMode: AVCaptureDevice.ExposureMode, isSubjectAreaChangeMonitoringEnabled: Bool) {
        DispatchQueue.main.async {
            guard let device: AVCaptureDevice = self.device else {
                return
            }
            do {
                let p: CGPoint = (self.device?.position == .front)
                    ? CGPoint(x: point.y / view.frame.height, y: point.x / view.frame.width)
                    : CGPoint(x: point.y / view.frame.height, y: 1 - (point.x / view.frame.width))
                try? device.lockForConfiguration()
                if(device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode)){
                    device.focusPointOfInterest = p
                    device.focusMode = focusMode
                }
                if(device.isExposurePointOfInterestSupported && device.isExposureModeSupported(expusureMode)){
                    device.exposurePointOfInterest = p
                    device.exposureMode = expusureMode
                }
                device.isSubjectAreaChangeMonitoringEnabled = isSubjectAreaChangeMonitoringEnabled
                device.unlockForConfiguration()
                // print("アジャスト: x = \(p.x), y = \(p.y)")
            }
        }
    }
    
    
    func zoom(pinch: UIPinchGestureRecognizer) {
        guard let captureDevice: AVCaptureDevice = self.device else {
            return
        }
        do {
            try? captureDevice.lockForConfiguration()
            // ズームの最大値
            let maxZoomScale: CGFloat = 6.0
            // ズームの最小値
            let minZoomScale: CGFloat = 1.0
            // 現在のカメラのズーム度
            var newZoomScale: CGFloat = captureDevice.videoZoomFactor
            // ピンチの度合い
            let pinchZoomScale: CGFloat = pinch.scale
            
            // ピンチアウトの時、前回のズームに今回のズーム -1 を指定
            if pinchZoomScale > 1.0 {
                newZoomScale = self.currentZoomScale + pinchZoomScale - 1
            } else {
                newZoomScale = self.currentZoomScale - (1 - pinchZoomScale) * self.currentZoomScale
            }
            
            // 最小値より小さく、最大値より大きくならないようにする
            if newZoomScale < minZoomScale {
                newZoomScale = minZoomScale
            }
            else if newZoomScale > maxZoomScale {
                newZoomScale = maxZoomScale
            }
            
            // 画面から指が離れたときの処理
            if pinch.state == .ended {
                self.currentZoomScale = newZoomScale
            }
            
            captureDevice.videoZoomFactor = newZoomScale
            captureDevice.unlockForConfiguration()
        }
    }
    
    
    func switchCameraPosition() {
        if self.isCapturing {
            return
        }
        self.stopSession {
            self.isFrontCamera = !self.isFrontCamera
            self.sessionQueue.async {
                for input in self.session.inputs {
                    self.session.removeInput(input)
                }
                self.isReadyVideoInput = false
                
                self.addVideoInput()
                
                if !self.isReadyVideoInput
                    || !self.isReadyVideoOutput {
                    self.isFrontCamera = !self.isFrontCamera
                    return
                }
                self.startSession {}
            }
        }
    }
    
    
    func capture() {
        if self.isCapturing {
            return
        }
        self.isCapturing = true
        let setting = AVCapturePhotoSettings()
        setting.flashMode = self.flashMode
        setting.isAutoStillImageStabilizationEnabled = true
        setting.isHighResolutionPhotoEnabled = false
        self.output.capturePhoto(with: setting, delegate: self)
    }
    
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        self.isCapturing = false
        if let sampleBuffer: CMSampleBuffer = photoSampleBuffer {
            if let data: Data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                if let image: UIImage = UIImage(data: data) {
                    let scale: CGFloat = min(image.size.width / self.frame.width, image.size.height / self.frame.height)
                    let width: CGFloat = self.frame.width * scale
                    let height: CGFloat = self.frame.height * scale
                    let x: CGFloat = (image.size.width - width) / 2
                    let y: CGFloat = (image.size.height - height) / 2
                    self.finishCapture?(image.cropping(to: CGRect(x: x, y: y, width: width, height: height)))
                }
            }
        }
    }
}
