//
//  ErrorHandler.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//


import SwiftUI

public struct ErrorHandleModifier: ViewModifier {
    @Binding var error: Error?

    public func body(content: Content) -> some View {
        content
        // Avoid SwiftUI Bug's for alert is not shown.
            .background(EmptyView().alert(item: .init(get: {
                error.map(Identity.init)
            }, set: { identifiableError in
                DispatchQueue.main.async {
                    error = identifiableError?.error
                }
            }), content: { identifiableError in
                Alert(
                    title: Text("Error"),
                    message: Text(identifiableError.localizedDescription),
                    dismissButton: .default(Text("OK"))
                )
            }))
    }
}

extension View {
    public func handle(error: Binding<Error?>) -> some View {
        modifier(ErrorHandleModifier(error: error))
    }
}


struct Identity<T>: Identifiable {
    let id = UUID()
    let value: T

    init(_ value: T) {
        self.value = value
    }
}

extension Identity: Error, LocalizedError where T: Error {
    var error: Error { value }

    var errorDescription: String? {
        error.localizedDescription
    }
    // TODO:
    var failureReason: String? { nil }
    var recoverySuggestion: String? { nil }
    var helpAnchor: String? { nil }
}
