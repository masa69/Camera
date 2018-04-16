
import UIKit

class TransparentButton: DefaultButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.setTitle("", for: UIControlState.normal)
    }
}
