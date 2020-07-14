import SwiftUI

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged { (_) in
        UIApplication.shared.endEditing(true)
    }
    
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}
