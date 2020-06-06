import Foundation
class FAQConfigurator {    
    func configure(viewController: FAQViewController) {
        let router = FAQRouter(viewController: viewController)
        let presenter = FAQPresenter(viewController: viewController)
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = FAQDataSource(parentViewController: viewController, FAQURLString: "https://ctemplar.com/faqs/")
        viewController.dataSource = dataSource
    }
}
