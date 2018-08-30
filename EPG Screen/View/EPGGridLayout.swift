//
//  EPGGridLayout.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 29/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

class EPGGridLayout: UICollectionViewLayout {
    
    var epgStartTime: Date!
    var epgEndTime: Date!
    var xPos:CGFloat = 0
    var yPos:CGFloat = 0
    let tileWidth: CGFloat = 200
    let tileHeight: CGFloat = 70
    var layoutInfo: NSMutableDictionary?
    var framesInfo: NSMutableDictionary?
    
    var channels : [Channel]?
    
    override init() {
        super.init()
        configuration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configuration()
    }
    
    override func prepare() {
        self.channels = APIManager.sharedInstance.channels
        calculateFramesForAllSchedules()
        guard let channels = channels else { return }
        let newLayoutInfo = NSMutableDictionary()
        let cellLayoutInfo = NSMutableDictionary()
        
        for section in 0..<channels.count {
            let channel = channels[section]
            guard let schedules = channel.schedules else { continue }
            for index in 0..<schedules.count {
                let indexPath = IndexPath(item: index, section: section)
                let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                itemAttributes.frame = frameForItemAtIndexPath(indexPath)
                cellLayoutInfo[indexPath] = itemAttributes
            }
        }
        newLayoutInfo["collectionCell"] = cellLayoutInfo
        layoutInfo = newLayoutInfo
    }
    
    func configuration() {
        var date = Calendar.current.startOfDay(for: Date())
        date = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: date, options: [])!
        epgStartTime = date
        let weekTimeInterval: TimeInterval = (60 * 60 * 24 * 7)
        epgEndTime = epgStartTime.addingTimeInterval(weekTimeInterval)
        layoutInfo = NSMutableDictionary()
        framesInfo = NSMutableDictionary()
    }
    
    func tileSize(for schedule : Schedule) -> CGSize {
        let duartionFactor = schedule.duration / 3600.0
        let width: CGFloat = CGFloat(duartionFactor * 240.0) + 110
        return CGSize(width: width, height: tileHeight)
    }
    
    func calculateFramesForAllSchedules() {
        guard let channels = channels else { return }
        for i in 0..<channels.count {
            xPos = 0
            let channel = channels[i]
            guard let schedules = channel.schedules else {
                yPos += tileHeight
                continue
            }
            for index in 0..<schedules.count {
                let program = schedules[index]
                let tileSize = self.tileSize(for: program)
                let frame = CGRect(x: xPos, y: yPos, width: tileSize.width, height: tileSize.height)
                let rectString = NSStringFromCGRect(frame)
                let indexPath = IndexPath(item: index, section: i)
                framesInfo?[indexPath] = rectString
                xPos = xPos + tileSize.width
            }
            yPos += tileHeight
        }
    }
    
    override var collectionViewContentSize : CGSize {
        guard let channels = channels else { return CGSize.zero }
        let intervals = epgEndTime.timeIntervalSince(epgStartTime)
        let numberOfHours = CGFloat(intervals / 3600)
        let width = numberOfHours * tileWidth
        let height = CGFloat(channels.count) * tileHeight
        return CGSize(width: width, height: height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes  = [UICollectionViewLayoutAttributes]()
        let enumerateClosure = { (object: Any, attributes: Any, stop: UnsafeMutablePointer<ObjCBool>) in
            guard let attributes = attributes as? UICollectionViewLayoutAttributes, rect.intersects(attributes.frame) else { return }
            layoutAttributes.append(attributes)
        }
        layoutInfo?.enumerateKeysAndObjects({ (object: Any, elementInfo: Any, stop: UnsafeMutablePointer<ObjCBool>) in
            guard let infoDic = elementInfo as? NSDictionary else { return }
            infoDic.enumerateKeysAndObjects(enumerateClosure)
        })
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> (UICollectionViewLayoutAttributes?) {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = self.frameForItemAtIndexPath(indexPath)
        return attributes
    }
    
    func frameForItemAtIndexPath(_ indexPath : IndexPath) -> CGRect {
        guard let infoDic = framesInfo, let rectString = infoDic[indexPath] as? String else { return CGRect.zero }
        return CGRectFromString(rectString)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !collectionView!.bounds.size.equalTo(newBounds.size)
    }
    override func invalidateLayout() {
        xPos = 0
        yPos = 0
        super.invalidateLayout()
    }
    
}
