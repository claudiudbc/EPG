//
//  ViewController.swift
//  EPG Screen
//
//  Created by Claudiu Dobre on 23/08/2018.
//  Copyright © 2018 Claudiu Dobre. All rights reserved.
//

import UIKit

class EPGViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    let logoCellIdentifier = "logoCell"
    let collectionViewCellIdentifier = "collectionViewCell"
    let channelsTableRowHeight:CGFloat = 70
    
    var channels: [Channel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.register(EPGTableViewCell.self, forCellReuseIdentifier: logoCellIdentifier)
        
        APIManager.sharedInstance.getChannels { (result) in
            switch result {
            case .success(let root):
                print(root)
                self.channels = root.channels
                self.tableView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                
            case .failure(let error):
                fatalError("error: \(error.localizedDescription)")
            }
        }
    }
}

extension EPGViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return channelsTableRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let channels = channels else { return 0 }
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: logoCellIdentifier, for: indexPath) as! EPGTableViewCell
        if let logoUrl = self.channels?[indexPath.row].images?.logo {
            cell.imageUrl = logoUrl
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 80.0/255, green: 80.0/255, blue: 80.0/255, alpha: 1.0)
    }
}

extension EPGViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let channels = channels else { return 0 }
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let channel = channels?[section], let schedules = channel.schedules else { return 0 }
        return schedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath) as! EPGCollectionViewCell
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.darkGray.cgColor
        
        guard let channel = channels?[indexPath.section], let schedules = channel.schedules else { return cell }
        
        let schedule = schedules[indexPath.row]
        cell.programName.text = "\(schedule.title!)"
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        if let startTimeString = schedule.startDate, let endTimeString = schedule.endDate {
            let startDate = dateFormatter.date(from: startTimeString)
            let endDate = dateFormatter.date(from: endTimeString)
            let startHour = calendar.component(.hour, from: startDate!)
            let startMinutes = calendar.component(.minute, from: startDate!)
            let endHour = calendar.component(.hour, from: endDate!)
            let endMinutes = calendar.component(.minute, from: endDate!)
            cell.programTime.text = "\(startHour):\(startMinutes) - \(endHour):\(endMinutes)"
        }
        
        return cell
    }
}
