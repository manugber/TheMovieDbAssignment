//
//  ConfigurationInDto.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 17/11/24.
//

import Foundation

struct ConfigurationInDto: Codable {
    let images: ImageConfigurationInDto
    let changeKeys: [String]

    enum CodingKeys: String, CodingKey {
        case images
        case changeKeys = "change_keys"
    }
}
