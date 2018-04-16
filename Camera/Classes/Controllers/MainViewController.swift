
import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gotoHome()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func gotoHome() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Camera", bundle: nil)
        let vc: CameraViewController = storyboard.instantiateViewController(withIdentifier: "Camera") as! CameraViewController
        let nav: DefaultNavigationController = DefaultNavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
}
