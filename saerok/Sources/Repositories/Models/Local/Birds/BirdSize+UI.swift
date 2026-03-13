//
//  BirdSize+UI.swift
//  saerok
//
//  Created by HanSeung on 3/13/26.
//

import SwiftUI

extension BirdSize {
    var image: Image {
        switch self {
        case .sparrow: .init(.birdFilter1)
        case .pigeon: .init(.birdFilter2)
        case .duck: .init(.birdFilter3)
        case .kayak: .init(.birdFilter4)
        }
    }
}
