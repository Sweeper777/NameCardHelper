import UIKit

class MyNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

class MyImagePickerController: UIImagePickerController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}
