//
//  storyTableViewCell.swift
//  kps
//
//  Created by mac035 on 6/19/24.
//

import UIKit

class subjectStoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var storyLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
