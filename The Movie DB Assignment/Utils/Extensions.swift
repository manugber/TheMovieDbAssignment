//
//  Extensions.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 18/11/24.
//

import Foundation

extension String {
    func toCGFloat() -> CGFloat? {
        if let doubleValue = Double(self) {
            return CGFloat(doubleValue)
        }
        return nil
    }
}

extension Array where Element == String {
    func convertToCGFloat() -> [CGFloat] {
        self.compactMap { size in
            if let number = size.replacingOccurrences(of: "w", with: "").toCGFloat() {
                return number
            }
            return nil
        }
    }
}
