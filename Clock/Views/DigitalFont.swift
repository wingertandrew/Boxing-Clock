import SwiftUI

struct DigitalFont: ViewModifier {
    var size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.custom("UFCSans-Bold", size: size))
            .monospacedDigit()
    }
}

extension View {
    func digitalFont(size: CGFloat) -> some View {
        self.modifier(DigitalFont(size: size))
    }
}