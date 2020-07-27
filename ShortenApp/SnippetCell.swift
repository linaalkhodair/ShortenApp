//
//  SnippetCell.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 16/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import UIKit

class SnippetCell: UITableViewCell {

    @IBOutlet weak var snippetId: UILabel!
    @IBOutlet weak var snippetParameter: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        snippetParameter.layer.cornerRadius = 15
        snippetParameter.clipsToBounds = true 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        snippetParameter.layer.cornerRadius = 15
        snippetParameter.clipsToBounds = true
        // Configure the view for the selected state
    }
}
