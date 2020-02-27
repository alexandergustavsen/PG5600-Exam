//
//  FavoriteTableViewCell.swift
//  Exam-PG5600-Tabbed
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var favTrackLabel: UILabel!
    @IBOutlet weak var favArtistLabel: UILabel!
    @IBOutlet weak var favTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
