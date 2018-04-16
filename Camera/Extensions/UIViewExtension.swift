
import UIKit

extension UIView {
    
    @IBInspectable var borderRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    
    func icon(named: String, color: UIColor) {
        self.icon(named: named, color: color, shadow: false)
    }
    
    
    func icon(named: String, color: UIColor, shadow: Bool) {
        self.backgroundColor = UIColor.clear
        guard let image: UIImage = UIImage(named: named)?.withRenderingMode(.alwaysTemplate) else {
            return
        }
        var isFoundImageView: Bool = false
        var imageView: UIImageView = UIImageView(image: image)
        
        for view in self.subviews {
            if let iv: UIImageView = view as? UIImageView {
                isFoundImageView = true
                imageView = iv
                imageView.image = image
            }
        }
        
        let x: CGFloat = (self.frame.width - image.size.width) / 2
        let y: CGFloat = (self.frame.height - image.size.height) / 2
        
        imageView.frame = CGRect(x: x, y: y, width: image.size.width, height: image.size.height)
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowOpacity = 0
        
        if shadow {
            imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
            imageView.layer.shadowRadius = 1.0
            imageView.layer.shadowOpacity = 1.0
        }
        
        if !isFoundImageView {
            self.addSubview(imageView)
        }
    }
    
    
    func toImage() -> UIImage? {
        // UIGraphicsBeginImageContextWithOptions(size: CGSize, opaque: Bool, scale: CGFloat)
        // 第2引数: true = 背景不透明, false = 背景透明
        // 第3引数: Retinaに対応するために必要
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
