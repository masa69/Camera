
import UIKit

class CameraScreenActionView: UIView {
    
    var tapped: ((_ touch: UITouch) -> Void)?
    
    var doubleTapped: ((_ touch: UITouch) -> Void)?
    
    var pinch: ((_ sender: UIPinchGestureRecognizer) -> Void)?
    
    private var tappedCount: Int = 0
    
    private var promise: Timer?
    
    private var touch: UITouch?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = false
        
        let pinch: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(_:)))
        self.addGestureRecognizer(pinch)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else {
            return
        }
        
        self.touch = touch
        
        if self.promise == nil {
            // タップ判定。0.3秒以内にもう一度タップがあればダブルタップ判定になる
            self.promise = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.onTappedTimer(_:)), userInfo: nil, repeats: false)
        }
        self.tappedCount += 1
        // ダブルタップ判定
        if self.tappedCount == 2 {
            self.tappedCount = 0
            self.promise?.invalidate()
            self.promise = nil
            self.doubleTapped?(touch)
            return
        }
        self.tapped?(touch)
    }
    
    
    // MARK: - Tiimer
    
    @objc func onTappedTimer(_ sender: Timer) {
        self.tappedCount = 0
        self.promise?.invalidate()
        self.promise = nil
    }
    
    
    // MARK: - Gesture Recognizer
    
    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        self.pinch?(sender)
    }
    
}
