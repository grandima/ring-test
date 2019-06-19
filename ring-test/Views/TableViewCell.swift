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
    var imageLongTapAction: ActionCompletion?
    var imageTapAction: ActionCompletion?
    func populate(author: String = "", title: String = "", comments: String = "", time: String = "", image: UIImage?, longAction: ActionCompletion? = nil, shortAction: ActionCompletion? = nil) {
        authorLabel?.text = author
        titleLabel?.text = title
        commentsLabel?.text = comments
        timeLabel?.text = time
        imageLongTapAction = longAction
        imageTapAction = shortAction
        imgView.image = image
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
        selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action:
            #selector(imageTap))
        tap.cancelsTouchesInView = false
        let longTap = UILongPressGestureRecognizer(target: self, action:
            #selector(imageLongTap))
        imgView.addGestureRecognizer(longTap)
        imgView.addGestureRecognizer(tap)
    }
    
    @objc func imageTap() {
        imageTapAction?()
    }
    
    @objc func imageLongTap() {
        imageLongTapAction?()
    }
}
