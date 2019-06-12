//
//  TableViewCell.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/1/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    typealias ActionCompletion = ()->Void
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    var imageLongPressAction: ActionCompletion?
    var imagePressAction: ActionCompletion?
    func populate(author: String = "", title: String = "", comments: String = "", time: String = "", longAction: ActionCompletion? = nil, shortAction: ActionCompletion? = nil) {
        authorLabel?.text = author
        titleLabel?.text = title
        commentsLabel?.text = comments
        timeLabel?.text = time
        imageLongPressAction = longAction
        imagePressAction = shortAction

    }
    func setup(with image: UIImage?) {
        if let image = image {
            imgView.image = image
            imgView.isHidden = false
        } else {
            imgView.image = nil
            imgView.isHidden = true
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
        imgView.isHidden = false
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
