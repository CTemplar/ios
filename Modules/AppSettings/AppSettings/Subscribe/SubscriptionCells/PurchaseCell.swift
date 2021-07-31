//
//  PurchaseCell.swift
//  Sub
//


import UIKit
import Utility

protocol PurchaseCellDelegate:AnyObject {
    func purchaseAction()
    func monthly_Tapped(cell :PurchaseCell)
    func yearly_Tapped(cell :PurchaseCell)
}
class PurchaseCell: UITableViewCell {
    static let CellIdentifier = "PurchaseCell"
    weak var delegate: PurchaseCellDelegate?
    @IBOutlet var monthPriceLBL : UILabel!,yearlPriceLBL : UILabel!
    @IBOutlet var monthLBL : UILabel!,yearlLBL : UILabel!
    @IBOutlet var monthlyBTN : UIButton!,yearlyBTN : UIButton!
    @IBOutlet var continueBTN: LoadingButton!
    @IBOutlet var monthlyHolder: UIView!,yearlyHolder : UIView!
    @IBOutlet var monthlyCheckImage: UIImageView!,yearlyCheckImage : UIImageView!

    let corner : CGFloat = 12
    var selectedIndex = 0
    var lightBackColor = UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        monthlyCheckImage.backgroundColor = .clear
        yearlyCheckImage.backgroundColor = .clear
        self.setDetails()
    }
    
    func setDetails(){
        lightBackColor = k_emailToInputColor1//(self.traitCollection.userInterfaceStyle == .dark) ? UIColor(red: 191/255.0, green: 191/255.0, blue: 191/255.0, alpha: 1.0) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0)
        
        
        selectedIndex = 0
        continueBTN.backgroundColor = k_redColor
        continueBTN.setTitleColor(.white, for: .normal)
        continueBTN.titleLabel?.font = AppFont.medium.size(15)
        
        monthLBL.font = AppFont.heavy.size(12)
        monthPriceLBL.font = AppFont.black.size(17)
        yearlLBL.font = AppFont.heavy.size(12)
        yearlPriceLBL.font = AppFont.black.size(17)
  
        monthlyCheckImage.image = UIImage()
        monthlyCheckImage.borderColor = .white
        monthlyCheckImage.borderWidth = 1
        monthlyCheckImage.cornerRadius = 13
        
        monthlyBTN.tintColor = .clear
        yearlyBTN.tintColor = .clear
        
        monthLBL.text = "Monthly"
        
        yearlLBL.text = "Yearly"
        self.monthlySelected()
    }
    
    func monthlySelected(){
        monthLBL.textColor = .white
        monthPriceLBL.textColor = .white
        yearlLBL.textColor = k_emailToInputColor
        yearlPriceLBL.textColor = k_emailToInputColor
        
        
        monthlyHolder.backgroundColor = k_blueColor
        yearlyHolder.backgroundColor = .white
        
        yearlyHolder.borderWidth = 2
        yearlyHolder.borderColor = k_blueColor
        
        monthlyHolder.borderWidth = 0
        
        monthlyCheckImage.image = UIImage(named: "check")
        monthlyCheckImage.setImageColor(color: .white)
        monthlyCheckImage.borderWidth = 0
        
        yearlyCheckImage.image = UIImage()
        yearlyCheckImage.borderColor = .white
        yearlyCheckImage.borderWidth = 1
        yearlyCheckImage.cornerRadius = 13
    }
    func yearlySelected(){
        monthLBL.textColor = k_emailToInputColor
        monthPriceLBL.textColor = k_emailToInputColor
        yearlLBL.textColor = .white
        yearlPriceLBL.textColor = .white
        
        monthlyHolder.backgroundColor = .white
        yearlyHolder.backgroundColor = k_blueColor
        
        monthlyHolder.borderWidth = 2
        monthlyHolder.borderColor = k_blueColor
        
        yearlyHolder.borderWidth = 0
        
        yearlyCheckImage.image = UIImage(named: "check")
        yearlyCheckImage.setImageColor(color: .white)
        yearlyCheckImage.borderWidth = 0
        
        monthlyCheckImage.image = UIImage()
        monthlyCheckImage.borderColor = .white
        monthlyCheckImage.borderWidth = 1
        monthlyCheckImage.cornerRadius = 13
    }
    
    
    @IBAction func monthlyAction(_ sender : UIButton){
        self.delegate?.monthly_Tapped(cell: self)
    }
    @IBAction func yearlyAction(_ sender : UIButton){
        self.delegate?.yearly_Tapped(cell: self)
    }
    @IBAction func continueAction(_ sender : UIButton){
        self.continueBTN.showLoading()
        self.delegate?.purchaseAction()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setSelection(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options:[], animations: {
            if self.selectedIndex == 0{
                self.monthlySelected()
            }else{
                self.yearlySelected()
            }
        }, completion:nil)
    }

}
