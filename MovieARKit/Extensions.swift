//
//  Extensions.swift
//  MovieARKit
//
//  Created by 권석기 on 1/11/25.
//

import Foundation
import ARKit

extension Int {
    var degreesToRadinans: Double { return Double(self) * .pi/180}
}

extension ARPlaneAnchor.Classification {
    var planeColor: UIColor {
        switch self {
        case .ceiling:
            return  .cyan
        case .door:
            return .blue
        case .floor:
            return .brown
        case .seat:
            return .darkGray
        case .table:
            return .gray
        case .wall:
            return .green
        case .window:
            return .magenta
        default:
            return .black
        }
    }
    
    var description: String {
        switch self {
        case .wall:
            return "Wall"
        case .floor:
            return "Floor"
        case .ceiling:
            return "Ceiling"
        case .table:
            return "Table"
        case .seat:
            return "Seat"
        case .window:
            return "Window"
        case .door:
            return "Door"
        @unknown default:
            return "None"
        }
    }
}
