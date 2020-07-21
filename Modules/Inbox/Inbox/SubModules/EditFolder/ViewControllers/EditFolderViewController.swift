import Foundation
import UIKit
import Networking
import Utility
import Colorful

class EditFolderViewController: UIViewController {
    // MARK: Properties
    private (set) var interactor: EditFolderInteractor?
    
    private (set) var folder: Folder?
    
    private (set) var selectedHexColor = ""
    
    private (set) var folderName = ""

    private let k_colorPickerOffset: CGFloat = 32.0
    
    private var k_colorPickeriPadHeight: CGFloat = 180.0

    // MARK: IBOutlets
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.setTitle(Strings.ManageFolder.deleteFolderTitle.localized, for: .normal)
        }
    }
    
    @IBOutlet weak var folderNameTextField: UITextField! {
        didSet {
            folderNameTextField.placeholder = Strings.ManageFolder.folderName.localized
        }
    }
    
    @IBOutlet weak var darkLineView: UIView!
    
    @IBOutlet weak var colorPicker: ColorPicker!
    
    @IBOutlet weak var chooseColorLabel: UILabel! {
        didSet {
            chooseColorLabel.text = Strings.ManageFolder.chooseColor.localized
        }
    }
    
    @IBOutlet weak var folderNameLabel: UILabel! {
        didSet {
            folderNameLabel.text = Strings.ManageFolder.folderName.localized
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuratrions
        let configurator = EditFolderConfigurator()
        configurator.configure(viewController: self)
                
        colorPicker.addTarget(self, action: #selector(handleColorChanged(picker:)), for: .valueChanged)
        colorPicker.set(color: .red, colorSpace: .extendedSRGB)

        if let folder = self.folder {
            interactor?.setFolderProperties(folder: folder)
        }
        
        interactor?.validateFolderName(text: folderName)
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.Button.saveButton.localized,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveButtonPressed))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        if let folderID = folder?.folderID {
            interactor?.showDeleteFolderAlert(folderID: folderID)
        }
    }
    
    @objc
    private func saveButtonPressed() {
        if let folderID = folder?.folderID {
            interactor?.updateCustomFolder(folderID: folderID, name: folderName, colorHex: selectedHexColor)
        }
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        self.interactor?.validateFolderName(text: sender.text!)
    }
    
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        folderNameTextField.resignFirstResponder()
    }
    
    // MARK: - Setup
    func setup(interactor: EditFolderInteractor) {
        self.interactor = interactor
    }
    
    func setup(folder: Folder) {
        self.folder = folder
    }
    
    func setup(folderName: String) {
        self.folderName = folderName
    }

    func setup(selectedHexColor: String) {
        self.selectedHexColor = selectedHexColor
        colorPicker.set(color: UIColor.hexToColor(hex: selectedHexColor), colorSpace: .sRGB)
    }
    
    // MARK: - Color Picker Actions
    @objc
    private func handleColorChanged(picker: ColorPicker) {
        DPrint("selected colorHex:", picker.color.hex)
        self.selectedHexColor = picker.color.hex
        self.interactor?.validateFolderName(text: self.folderName)
    }
}
