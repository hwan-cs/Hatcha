//
//  MyTableViewCell.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/02.
//

import UIKit
import SwipeCellKit

class MyTableViewCell: UITableViewCell
{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var setAlarmButton: UIButton!
 
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
