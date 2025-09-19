import SwiftUI

struct DigitalFont: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight?

    func body(content: Content) -> some View {
        content
            .font(resolvedFont)
            .monospacedDigit()
    }

    private var resolvedFont: Font {
        if let weight {
            return Font.custom("UFCSans-Bold", size: size).weight(weight)
        }

        return Font.custom("UFCSans-Bold", size: size)
    }
}

extension View {
    func digitalFont(size: CGFloat, weight: Font.Weight? = nil) -> some View {
        self.modifier(DigitalFont(size: size, weight: weight))
    }
}