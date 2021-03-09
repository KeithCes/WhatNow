//
//  RoundButton.swift
//  WhatNow
//
//  Created by Keith C on 3/9/21.
//

import Foundation
import UIKit

@IBDesignable
final class RoundButtonGrayLight: UIButton {

    override init(frame: CGRect){
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    func setup() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.layer.borderColor = CustomColors.grayLight.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 4
        self.setTitleColor(CustomColors.grayLight, for: .normal)
    }
}
