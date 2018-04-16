
import UIKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    
    
    var image: UIImage?
    
    private var item: DefaultNavigationItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNav()
        self.initPreview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initNav() {
        self.title = "プレビュー"
    }
    
    
    private func initPreview() {
        previewView.backgroundColor = UIColor.black
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.previewView.frame.width, height: self.previewView.frame.height))
        imageView.image = self.image
        //            imageView.contentMode = .scaleAspectFill
        //            imageView.contentMode = .scaleToFill
        imageView.contentMode = .scaleAspectFit
        self.previewView.addSubview(imageView)
    }
    
}
