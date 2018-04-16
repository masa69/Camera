
import UIKit

class DefaultNavigationItem {
    
    var item: UINavigationItem
    
    var onLeftItemCallback: (() -> Void)?
    
    var onRightItemCallback: (() -> Void)?
    
    
    enum ItemType: String {
        case back = "icon_angle_left_s"
        case close = "icon_close_s"
        case logo = "icon_logo"
    }
    
    
    init(item: UINavigationItem) {
        self.item = item
    }
    
    
    func addLeftItem(type: ItemType, didSelect: @escaping () -> Void) {
        self.item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: type.rawValue), style: .plain, target: self, action: #selector(self.onLeftItem(_:)))
        self.onLeftItemCallback = {
            didSelect()
        }
    }
    
    
    func addRightItem(named: String, didSelect: @escaping () -> Void) {
        self.item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: named), style: .plain, target: self, action: #selector(self.onRightItem(_:)))
        self.onRightItemCallback = {
            didSelect()
        }
    }
    
    
    @objc private func onLeftItem(_ sender: UIButton) {
        self.onLeftItemCallback?()
    }
    
    
    @objc private func onRightItem(_ sender: UIButton) {
        self.onRightItemCallback?()
    }
    
}
