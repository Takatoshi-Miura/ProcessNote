//
//  SaveButtonCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/16.
//

import UIKit

class SaveButtonCell: UITableViewCell {
    
    // MARK: - UI,Variable
    
    var delegate: SaveButtonCellDelegate? = nil
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func tapSaveButton(_ sender: Any) {
        delegate?.tapSaveButton()
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.tapCancelButton()
    }
    
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        saveButton.setTitle(NSLocalizedString("Addition", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        // 枠線を追加
        saveButton.layer.borderWidth = 0.5
        saveButton.layer.borderColor = UIColor.systemBackground.cgColor
        saveButton.layer.cornerRadius = 5.0
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.borderColor = UIColor.systemBackground.cgColor
        cancelButton.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


// MARK: - 【Delegate】SaveButtonCellDelegate

protocol SaveButtonCellDelegate {
    func tapSaveButton()
    func tapCancelButton()
}
