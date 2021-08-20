//
//  SearchTableViewCell.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/28.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit

//protocol SearchTableViewCellDelegate {
//    func didTapFollowButton(tableViewCell: UITableViewCell, button:UIButton)
//}

class SearchTableViewCell: UITableViewCell {
    
//    var delegate: SearchTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    //@IBOutlet var followButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    @IBAction func tapFollowButton(button: UIButton) {
//        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
//    }
    
}
