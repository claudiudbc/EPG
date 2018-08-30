//
//  Channel.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 23/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

struct Root : Codable {
    let channels: [Channel]?
}

struct Channel : Codable {
    let id: String?
    let title: String?
    let images: Images?
    let schedules: [Schedule]?
}

