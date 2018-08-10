/*
import UIKit
import GPUImage

class VideoCamera: UIView {
    
    var finishCapture: ((_ image: UIImage?) -> Void)?
    
    private var camera: GPUImageVideoCamera?
    
    private var writer: GPUImageMovieWriter?
    
    private var url: URL = FileManager.photoURL
    
    private var promise: Timer?
    
    private var filter: GPUImageFilter = GPUImageFilter()
    
    private var imageView: GPUImageView?
    
    // 通常のカメラのズーム
    private var currentZoomScale: CGFloat = 1.0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        FileManager.forbidBackupToiCloud()
        self.backgroundColor = UIColor.black
        
        self.imageView = GPUImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        self.imageView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        self.camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.photo.rawValue, cameraPosition: .back)
        self.camera?.outputImageOrientation = .portrait
        self.camera?.horizontallyMirrorFrontFacingCamera = true
        self.camera?.addTarget(self.filter)
        self.filter.addTarget(self.imageView!)
        self.addSubview(self.imageView!)
        self.camera?.startCapture()
        
        if let imageView: GPUImageView = self.imageView {
            self.writer = GPUImageMovieWriter(movieURL: self.url, size: CGSize(width: imageView.frame.width, height: imageView.frame.height), fileType: AVFileType.mp4.rawValue, outputSettings: nil)
            self.writer?.encodingLiveVideo = true
        }
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
                //print("アジャスト: x = \(p.x), y = \(p.y)")
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
        FileManager.sharedInstance.remove(atPath: FileManager.photoPath)
        self.writer?.startRecording()
        self.promise = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.finish(_:)), userInfo: nil, repeats: false)
    }
    
    
    // AVURLAsset から画像を保存する
    private func save(asset: AVURLAsset, callback: (_ image: UIImage?) -> Void) {
        let maxSize: CGFloat = 350
        //assetから画像をキャプチャーする為のジュネレーターを生成.
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = CGSize(width: maxSize, height: maxSize)
        // 画像の向きを調整してくれる
        generator.appliesPreferredTrackTransform = true
        // GPUImage の録画がたまに最初の一瞬ブラックアウトする
        // https://github.com/BradLarson/GPUImage/issues/1255
        // https://github.com/BradLarson/GPUImage/pull/2410
        // そのため動画の0秒時点を画像にするとブラック画像のサムネが生成される場合があるので
        // キャプチャーの時間を 0.365秒 ずらす
        // AVAssetWriterは0秒時点でよい
        do {
            let at: CMTime = kCMTimeZero
//            let at: CMTime = CMTime(value: 365, timescale: 600)
//            print(at)
//            print(asset.duration)
            let capturedImage : CGImage! = try generator.copyCGImage(at: at, actualTime: nil)
            let jpg: Data = UIImageJPEGRepresentation(UIImage(cgImage: capturedImage), 0.7)!
            callback(UIImage(data: jpg))
        } catch {
            print("画像の生成に失敗しました")
            callback(nil)
        }
    }
    
    
    // MARK: Timer
    
    @objc func finish(_ sender: Timer) {
        self.writer?.finishRecording(completionHandler: {
            print("finish")
            let asset: AVURLAsset = AVURLAsset(url: self.url)
            self.save(asset: asset, callback: { (image: UIImage?) in
                self.finishCapture?(image)
            })
        })
    }
    
}
*/
