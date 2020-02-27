//
//  AlbumsTableViewCell.swift
//  Exam-PG5600-Tabbed
//

import UIKit

class AlbumsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
