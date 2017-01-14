//
//  EventFeedCell.swift
//  Chula Expo 2017
//
//  Created by NOT on 1/12/2560 BE.
//  Copyright © 2560 Chula Computer Engineering Batch#41. All rights reserved.
//

import UIKit

class EventFeedCell: UITableViewCell {

    @IBOutlet weak var eventTumbnailImage: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    
    var name: String?{
        didSet{
            print("\(name)")
            updateUI()
        }
    }
    var tumbnail: String?{
        didSet{
            updateUI()
        }
    }
    var startTime: NSDate?{
        didSet{
            updateUI()
        }
    }
    var endTime: NSDate?{
        didSet{
            updateUI()
        }
    }
    var facity: String?{
        didSet{
            updateUI()
        }
    }

    func updateUI(){
        // reset
        eventTumbnailImage.image = nil
        eventNameLabel.text = nil
        eventTimeLabel.text = nil
        
        if let eventStartTime = startTime{
            if let eventEndTime = endTime{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "H:mm"
                let sTime = dateFormatter.string(from: eventStartTime as Date)
                let eTime = dateFormatter.string(from: eventEndTime as Date)
                eventTimeLabel.text = "\(sTime) - \(eTime)"
            }
        }
        if let eventName = name{
            eventNameLabel.text = eventName
        }
        if let eventTumbnail = tumbnail{
            eventTumbnailImage.image = UIImage(named: eventTumbnail)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
