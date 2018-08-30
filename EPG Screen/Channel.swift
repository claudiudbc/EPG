//
//  Channel.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 23/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

struct Channel: Decodable {
    let id: String
    let name: String
    let programs: [Program]
}
