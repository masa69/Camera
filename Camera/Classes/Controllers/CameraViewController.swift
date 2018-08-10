
import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraScreenView: CameraScreenView!
    
    @IBOutlet weak var cameraScreenActionView: CameraScreenActionView!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var cameraButton: TransparentButton!
    
    @IBOutlet weak var cameraPositionView: UIView!
    
    @IBOutlet weak var cameraPositionButton: TransparentButton!
    
    
    private var item: DefaultNavigationItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNav()
        self.initCameraScreen()
        self.initButton()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraScreenView.startCapture()
    }
    
    
    private func initNav() {
        self.title = "camera"
        self.item = DefaultNavigationItem(item: self.navigationItem)
        self.item?.addLeftItem(type: .close, didSelect: {
            self.dismiss(animated: true, completion: nil)
        })
        self.item?.addRightItem(named: "icon_cog", didSelect: {
            self.gotoLicence()
        })
    }
    
    
    private func initCameraScreen() {
        cameraScreenActionView.tapped = { (touch: UITouch) in
            self.ajustCameraScreen(point: touch.location(in: self.cameraScreenView))
        }
        cameraScreenActionView.doubleTapped = { (touch: UITouch) in
            self.switchCameraPosition()
        }
        cameraScreenActionView.pinch = { (sender: UIPinchGestureRecognizer) in
            self.zoom(sender: sender)
        }
        cameraScreenView.finishCapture = { (image: UIImage?) in
            self.gotoPreview(image: image)
        }
    }
    
    
    private func initButton() {
        cameraView.borderRadius = cameraView.frame.height / 2
        cameraView.borderWidth = 2
        cameraView.layer.borderColor = UIColor.ultraDarkGray.cgColor
        cameraView.backgroundColor = UIColor.white
        cameraButton.touchDown = {
            self.capture()
        }
        cameraPositionView.icon(named: "icon_rotate", color: .ultraDarkGray, shadow: false)
        cameraPositionButton.touchDown = {
            self.switchCameraPosition()
        }
    }
    
    
    private func capture() {
        cameraScreenView.capture()
    }
    
    
    private func switchCameraPosition() {
        cameraScreenView.switchCameraPosition()
    }
    
    
    private func zoom(sender: UIPinchGestureRecognizer) {
        cameraScreenView.zoom(pinch: sender)
    }
    
    
    private func ajustCameraScreen(point: CGPoint) {
        for subView in self.view.subviews {
            if let v: CameraFocusView = subView as? CameraFocusView {
                v.removeFromSuperview()
            }
        }
        let v: CameraFocusView = CameraFocusView(view: self.view, point: point)
        self.view.addSubview(v)
        v.startAnimation()
        
        cameraScreenView.ajustCameraScreen(view: self.view, point: point, focusMode: .autoFocus, expusureMode: .autoExpose, isSubjectAreaChangeMonitoringEnabled: true)
    }
    
    
    private func gotoPreview(image: UIImage?) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Preview", bundle: nil)
        let vc: PreviewViewController = storyboard.instantiateViewController(withIdentifier: "Preview") as! PreviewViewController
        vc.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func gotoLicence() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Licence", bundle: nil)
        let vc: LicenceViewController = storyboard.instantiateViewController(withIdentifier: "Licence") as! LicenceViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
