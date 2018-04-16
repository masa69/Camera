
import UIKit

class DefaultButton: UIButton {
    
    var touchDown: (() -> Void)?
    
    var touchUpInside: (() -> Void)?
    
    var touchUpOutside: (() -> Void)?
    
    var touchDownRepeat: (() -> Void)?
    
    var isValid: Bool = true
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(self.onTouchDown(_:)), for: .touchDown)
        // 指を離した時
        self.addTarget(self, action: #selector(self.onTouchUpInside(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.onTouchUpOutside(_:)), for: .touchUpOutside)
        // ダブルタップ
        self.addTarget(self, action: #selector(self.onTouchDownRepeat(_:)), for: .touchDownRepeat)
    }
    
    
    @objc func onTouchDown(_ sender: UIButton) {
        if self.isValid {
            self.touchDown?()
        }
    }
    
    @objc func onTouchUpInside(_ sender: UIButton) {
        if self.isValid {
            self.touchUpInside?()
        }
    }
    
    @objc func onTouchUpOutside(_ sender: UIButton) {
        if self.isValid {
            self.touchUpOutside?()
        }
    }
    
    @objc func onTouchDownRepeat(_ sender: UIButton) {
        if self.isValid {
            self.touchDownRepeat?()
        }
    }
    
}
