//
//  MemoCell.swift
//  nifty_cloud_spa
//
//  Created by 酒井文也 on 2016/02/10.
//  Copyright © 2016年 just1factory. All rights reserved.
//

import UIKit

class MemoCell: UITableViewCell {

    //テーブルビューに表示する要素
    @IBOutlet var memoTitle: UILabel!
    @IBOutlet var memoImage: UIImageView!
    @IBOutlet var memoMoney: UILabel!
    @IBOutlet var memoComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
