//
//  SubscribeNavigation.swift
//  AppSettings
//


import UIKit
import Utility
import Networking

class SubscribeNavigation: UINavigationController, LeftBarButtonItemConfigurable  {
    func setupLeftBarButtonItems() {
        
    }
    
    private (set) var presenter: AppSubscriptionsCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
