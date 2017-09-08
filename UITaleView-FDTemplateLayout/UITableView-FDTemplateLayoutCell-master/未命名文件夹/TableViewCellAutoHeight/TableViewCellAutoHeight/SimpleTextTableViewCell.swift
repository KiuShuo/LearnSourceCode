//
//  SimpleTextTableViewCell.swift
//  TableViewCellAutoHeight
//
//  Created by shuo on 2017/4/21.
//  Copyright © 2017年 shuo. All rights reserved.
//

import UIKit

class SimpleTextTableViewCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        debugPrint("\(NSStringFromSelector(#function)), contenViewFrame = \(contentView.frame)")
        //detailLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
