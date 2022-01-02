//
//  SwipeTableViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/02.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: SwipeTableViewCellDelegate
{
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]?
    {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "삭제")
        { action, indexPath in
            self.updateModel(at: indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }

    func updateModel(at indexPath: IndexPath)
    {
        //update our data model
        
    }

}
