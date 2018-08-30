//
//  Schedules.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 24/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

struct Schedule: Codable {
    let title: String?
    let id: String?
    let startDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case id
        case startDate = "start"
        case endDate = "end"
    }
    
    var duration: TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let startDate = startDate, let endDate = endDate else { return 0 }
        let startTime = dateFormatter.date(from: startDate)
        let endTime = dateFormatter.date(from: endDate)
        guard let startTimeFormatted = startTime, let endTimeFormatted = endTime else { return 0 }
        return endTimeFormatted.timeIntervalSince(startTimeFormatted)
    }
}

