
import UIKit
import GPUImage

class StillCamera: UIView {
    
    var finishCapture: ((_ image: UIImage?) -> Void)?
    
    private var camera: GPUImageStillCamera?
    
    private var filter: GPUImageFilter = GPUImageFilter()
    
    private var imageView: GPUImageView?
    
    private var isReady: Bool = false
    
    private var isCapturing: Bool = false
    
    // 通常のカメラのズーム
    private var currentZoomScale: CGFloat = 1.0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.white
    }
    
    
    func start() {
        if self.isReady {
            return
        }
        self.imageView = GPUImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.imageView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        self.camera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.photo.rawValue, cameraPosition: .back)
        self.camera?.outputImageOrientation = .portrait
        self.camera?.horizontallyMirrorFrontFacingCamera = true
        self.camera?.addTarget(self.filter)
        self.filter.addTarget(self.imageView!)
        self.addSubview(self.imageView!)
        self.camera?.startCapture()
        self.isReady = true
    }
    
    
    func finish() {
        
    }
    
    
    func ajustCameraScreen(view: UIView, point: CGPoint, focusMode: AVCaptureDevice.FocusMode, expusureMode: AVCaptureDevice.ExposureMode, isSubjectAreaChangeMonitoringEnabled: Bool) {
        DispatchQueue.main.async {
            guard let device: AVCaptureDevice = self.camera?.inputCamera else {
                return
            }
            do {
                let p: CGPoint = (self.camera?.cameraPosition() == .front)
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
        guard let captureDevice: AVCaptureDevice = self.camera?.inputCamera else {
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
        self.camera?.rotateCamera()
        self.currentZoomScale = 1.0
    }
    
    
    func capture() {
        if self.isCapturing {
            return
        }
        self.isCapturing = true
        self.camera?.capturePhotoAsJPEGProcessedUp(toFilter: self.filter, withCompletionHandler: { (data: Data?, error: Error?) in
            if let d: Data = data {
                if let image: UIImage = UIImage(data: d) {
                    let y: CGFloat = (image.size.height - image.size.width) / 2
                    self.isCapturing = false
                    self.finishCapture?(image.cropping(to: CGRect(x: 0, y: y, width: image.size.width, height: image.size.width)))
                    return
                }
            }
            self.isCapturing = false
            self.finishCapture?(nil)
        })
    }
    
}
