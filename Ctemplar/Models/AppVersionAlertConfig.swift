import EMAlertController

public struct AppVersionAlertConfig {
    let title: String
    let message: String
    let image: UIImage
    let alertButtons: [AlertButton]
    
    public struct AlertButton {
        let title: String
        let type: EMAlertActionStyle
        let action: (() -> Void)
    }
}
