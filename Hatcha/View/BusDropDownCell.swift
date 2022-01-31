//
//  BusDropDownCell.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/02/01.
//

import UIKit
import DropDown

class BusDropDownCell: DropDownCell
{

    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
