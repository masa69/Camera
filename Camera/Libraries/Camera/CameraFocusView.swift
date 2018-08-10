
import UIKit

class CameraFocusView: UIView {
    
    private var size: CGFloat = 50
    private var point: CGPoint?
    
    private var animation1: UIViewPropertyAnimator?
    private var animation2: UIViewPropertyAnimator?
    
    
    init(view: UIView, point: CGPoint) {
        let size: CGFloat = self.size * 2
        let x: CGFloat = point.x - (size / 2)
        let y: CGFloat = point.y - (size / 2)
        super.init(frame: CGRect(x: x, y: y, width: size, height: size))
        self.point = point
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.rgb(rgbValue: 0xffffff, alpha: 0.7).cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 0.7
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startAnimation() {
        guard let point: CGPoint = self.point else {
            return
        }
        self.animation1 = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn, animations: {
            self.alpha = 1
            let x: CGFloat = point.x - (self.size / 2)
            let y: CGFloat = point.y - (self.size / 2)
            self.frame = CGRect(x: x, y: y, width: self.size, height: self.size)
        })
        self.animation2 = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut, animations: {
            self.alpha = 0
        })
        self.animation1?.startAnimation()
        self.animation2?.startAnimation(afterDelay: 0.6)
    }
    
}
