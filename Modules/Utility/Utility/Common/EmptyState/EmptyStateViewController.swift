import UIKit
import EmptyStateKit

final class EmptyStateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.emptyState.show(MainState.noInternet)
    }
    
    // MARK: - Setup
    private func setupState() {
        var format = EmptyStateFormat()
        format.buttonColor = UIColor.hexToColor(hex: "44CCD6")
        format.position = EmptyStatePosition(view: .bottom, text: .left, image: .top)
        format.verticalMargin = 40
        format.horizontalMargin = 40
        format.imageSize = CGSize(width: 320, height: 200)
        format.buttonShadowRadius = 10
        format.titleAttributes = [.font: AppStyle.CustomFontStyle.Bold.font(withSize: 25.0)!,
                                  .foregroundColor: UIColor.white]
        format.descriptionAttributes = [.font: AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!,
                                        .foregroundColor: UIColor.white]
        format.gradientColor = (UIColor.hexToColor(hex: "3854A5"), UIColor.hexToColor(hex: "2A1A6C"))
        
        view.emptyState.format = format
        view.emptyState.delegate = self
        view.emptyState.dataSource = self
    }
}

extension EmptyStateViewController: EmptyStateDataSource {
    func imageForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> UIImage? {
        switch state as? MainState {
        case .noInternet: return UIImage(named: "Internet")
        case .none: return nil
        }
    }

    func titleForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
        switch state as? MainState {
        case .noInternet:  return Strings.NetworkError.networkErrorTitle.localized
        case .none: return nil
        }
    }

    func descriptionForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
        switch state as? MainState {
        case .noInternet: return Strings.NetworkError.networkErrorMessage.localized
        case .none: return nil
        }
    }

    func titleButtonForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
        return nil
    }
}

extension EmptyStateViewController: EmptyStateDelegate {
    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
        view.emptyState.hide()
    }
}

