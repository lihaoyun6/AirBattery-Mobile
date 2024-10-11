//
//  Orientation.swift
//  Reminder
//
//  Created by apple on 2024/8/24.
//

import SwiftUI
import Combine

@propertyWrapper struct Orientation: DynamicProperty {
    @StateObject private var manager = OrientationManager.shared

    var wrappedValue: UIInterfaceOrientation {
        manager.interfaceOrientation
    }
}

class OrientationManager: ObservableObject {
    @Published var interfaceOrientation: UIInterfaceOrientation = .unknown
    static let shared = OrientationManager()

    private var cancellables: Set<AnyCancellable> = []

    init() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        interfaceOrientation = windowScene.interfaceOrientation
        
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink() { [weak self] _ in
                guard let self = self else { return }
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    self.interfaceOrientation = windowScene.interfaceOrientation
                }
            }
            .store(in: &cancellables)
    }
}

extension UIInterfaceOrientation {
    var isPortraitOrLandscape: String {
        switch self {
        case .portrait, .portraitUpsideDown:
            return "Portrait"
        case .landscapeLeft, .landscapeRight:
            return "Landscape"
        default:
            return "Unknown"
        }
    }
}
