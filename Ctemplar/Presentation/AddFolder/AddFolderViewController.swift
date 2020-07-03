import Foundation
import UIKit
import Utility
import Colorful

class AddFolderViewController: UIViewController {
    
    // MARK: Properties
    private var interactor: AddFolderInteractor?
    
    weak var delegate: AddFolderDelegate?
    
    var selectedHexColor: String = ""
    
    var folderName: String?
    
    let k_colorPickerOffset: CGFloat = 32.0
    
    var k_colorPickeriPadHeight: CGFloat = 90.0

    // MARK: IBOutlets
    @IBOutlet var addButton: UIBarButtonItem!
    
    @IBOutlet var folderNameTextField: UITextField!
    
    @IBOutlet var darkLineView: UIView!
   
    @IBOutlet var colorPicker: ColorPicker!
    
    @IBOutlet var colorPickerSuperViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = AddFolderConfigurator()
        configurator.configure(viewController: self)

        colorPicker.addTarget(self, action: #selector(handleColorChanged(picker:)), for: .valueChanged)
        colorPicker.set(color: .red, colorSpace: .extendedSRGB)
        
        interactor?.validateFolderName(text: folderName ?? "")
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
        
        folderNameTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        if let name = folderName,
            interactor?.validFolderName(text: folderName) == true {
            self.interactor?.createCustomFolder(name: name, colorHex: self.selectedHexColor)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        folderName = sender.text
        interactor?.validateFolderName(text: sender.text!)
    }
    
    @objc
    private func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if Device.IS_IPAD {
            _ = self.view.bounds.height - k_colorPickerOffset
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Setup
    func setup(interactor: AddFolderInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Color Picker Actions
    @objc
    private func handleColorChanged(picker: ColorPicker) {
        DPrint("selected colorHex:", picker.color.hex)
        self.selectedHexColor = picker.color.hex
        self.interactor?.validateFolderName(text: self.folderName)
    }
}
