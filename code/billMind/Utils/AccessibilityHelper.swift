import SwiftUI

/// Helper for improving accessibility throughout the app
struct AccessibilityHelper {
    /// Apply standard accessibility modifiers to a view
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint
    ///   - addTraits: Accessibility traits to add
    ///   - removeTraits: Accessibility traits to remove
    /// - Returns: A ViewModifier that can be applied to any view
    static func standard(
        label: String? = nil,
        hint: String? = nil,
        addTraits: AccessibilityTraits = [],
        removeTraits: AccessibilityTraits = []
    ) -> some ViewModifier {
        return StandardAccessibility(
            label: label,
            hint: hint,
            addTraits: addTraits,
            removeTraits: removeTraits
        )
    }
    
    /// Apply accessibility modifiers for a button
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint
    /// - Returns: A ViewModifier that can be applied to a button
    static func button(
        label: String,
        hint: String? = nil
    ) -> some ViewModifier {
        return StandardAccessibility(
            label: label,
            hint: hint,
            addTraits: .isButton
        )
    }
    
    /// Apply accessibility modifiers for a header
    /// - Parameter text: The header text
    /// - Returns: A ViewModifier that can be applied to a header
    static func header(_ text: String) -> some ViewModifier {
        return StandardAccessibility(
            label: text,
            addTraits: .isHeader
        )
    }
    
    /// Apply accessibility modifiers for a toggle
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint
    ///   - value: The current value (on/off)
    /// - Returns: A ViewModifier that can be applied to a toggle
    static func toggle(
        label: String,
        hint: String? = nil,
        value: Bool
    ) -> some ViewModifier {
        return StandardAccessibility(
            label: label,
            hint: hint,
            addTraits: [.isButton, .isToggle],
            value: value ? "on" : "off"
        )
    }
}

/// Standard accessibility modifier implementation
private struct StandardAccessibility: ViewModifier {
    let label: String?
    let hint: String?
    let addTraits: AccessibilityTraits
    let removeTraits: AccessibilityTraits
    let value: String?
    
    init(
        label: String? = nil,
        hint: String? = nil,
        addTraits: AccessibilityTraits = [],
        removeTraits: AccessibilityTraits = [],
        value: String? = nil
    ) {
        self.label = label
        self.hint = hint
        self.addTraits = addTraits
        self.removeTraits = removeTraits
        self.value = value
    }
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label != nil ? Text(label!) : Text(""))
            .accessibilityHint(hint != nil ? Text(hint!) : Text(""))
            .accessibilityAddTraits(addTraits)
            .accessibilityRemoveTraits(removeTraits)
            .accessibilityValue(value != nil ? Text(value!) : Text(""))
    }
}

// Extension to make it easier to apply accessibility modifiers
extension View {
    /// Apply standard accessibility modifiers
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint
    ///   - addTraits: Accessibility traits to add
    ///   - removeTraits: Accessibility traits to remove
    /// - Returns: A view with accessibility modifiers applied
    func accessibilityStandard(
        label: String? = nil,
        hint: String? = nil,
        addTraits: AccessibilityTraits = [],
        removeTraits: AccessibilityTraits = []
    ) -> some View {
        return self.modifier(
            AccessibilityHelper.standard(
                label: label,
                hint: hint,
                addTraits: addTraits,
                removeTraits: removeTraits
            )
        )
    }
    
    /// Apply button accessibility modifiers
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint
    /// - Returns: A view with button accessibility modifiers applied
    func accessibilityButton(
        label: String,
        hint: String? = nil
    ) -> some View {
        return self.modifier(
            AccessibilityHelper.button(
                label: label,
                hint: hint
            )
        )
    }
    
    /// Apply header accessibility modifiers
    /// - Parameter text: The header text
    /// - Returns: A view with header accessibility modifiers applied
    func accessibilityHeader(_ text: String) -> some View {
        return self.modifier(
            AccessibilityHelper.header(text)
        )
    }
    
    /// Apply toggle accessibility modifiers
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint
    ///   - value: The current value (on/off)
    /// - Returns: A view with toggle accessibility modifiers applied
    func accessibilityToggle(
        label: String,
        hint: String? = nil,
        value: Bool
    ) -> some View {
        return self.modifier(
            AccessibilityHelper.toggle(
                label: label,
                hint: hint,
                value: value
            )
        )
    }
}