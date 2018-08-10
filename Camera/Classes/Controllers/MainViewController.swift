
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: DefaultButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initButton() {
        cameraButton.touchDown = {
            self.gotoHome()
        }
    }
    
    
    private func gotoHome() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Camera", bundle: nil)
        let vc: CameraViewController = storyboard.instantiateViewController(withIdentifier: "Camera") as! CameraViewController
        let nav: DefaultNavigationController = DefaultNavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
}
