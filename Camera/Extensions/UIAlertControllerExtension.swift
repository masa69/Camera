
import UIKit

extension UIAlertController {
    
    class func simple(title: String, message: String?) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }
    
    
    class func simple(title: String, message: String?, handler: @escaping (_ action: UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            handler(action)
        }))
        return alert
    }
    
}
