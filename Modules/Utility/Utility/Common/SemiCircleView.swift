import UIKit

public final class SemiCirleView: UIView {
    @IBInspectable
    public var circleColor: UIColor = .systemOrange
    
    private var semiCirleLayer: CAShapeLayer!

    public override func layoutSubviews() {
        super.layoutSubviews()

        if semiCirleLayer == nil {
            let arcCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
            let circleRadius = bounds.size.width / 2
            let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 2, clockwise: true)

            semiCirleLayer = CAShapeLayer()
            semiCirleLayer.path = circlePath.cgPath
            semiCirleLayer.fillColor = circleColor.cgColor
            
            layer.addSublayer(semiCirleLayer)

            // Make the view color transparent
            backgroundColor = UIColor.clear
        }
    }
}
