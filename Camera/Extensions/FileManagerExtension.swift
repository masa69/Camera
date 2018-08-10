
import UIKit

extension FileManager {
    
    static var sharedInstance: FileManager = FileManager()
    
    
    func remove(atPath: String) {
        if self.fileExists(atPath: atPath) {
            do {
                try self.removeItem(atPath: atPath)
            } catch _ {
            }
        }
    }
    
    class var photoPath: String {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let path : String = "\(documentsDirectory)/photo.mp4"
            return path
        }
    }
    
    
    class var photoURL: URL {
        get {
            let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            var path = paths[0]
            path.appendPathComponent("photo.mp4")
            return path
        }
    }
    
    
    func fileSize(atPath: String) -> (error: Bool, size: UInt64) {
        do {
            let attr: NSDictionary = try self.attributesOfItem(atPath: atPath) as NSDictionary
            return (false, attr.fileSize())
        } catch _ {
            print("failed FileManager.default.attributesOfItem()")
            return (true, 0)
        }
    }
    
    
    // iClould にバックアップさせない
    class func forbidBackupToiCloud() {
        do {
            let paths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDirectory: String = paths[0] as String
            var docURL: URL = URL(fileURLWithPath: documentDirectory)
            var resources: URLResourceValues = URLResourceValues()
            resources.isExcludedFromBackup = true
            try docURL.setResourceValues(resources)
        } catch {
            print("failed setResourceValues()")
        }
    }
    
}
