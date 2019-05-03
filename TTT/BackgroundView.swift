//
//  backgroundView.swift
//  TTT
//
//  Created by Akash kahalkar on 02/05/19.
//  Copyright © 2019 Akashka. All rights reserved.
//

import UIKit

@IBDesignable class BackgroundView: Board {

    override func draw(_ rect: CGRect) {
        addCornerRadius(rect)
        drawGradient()
    }
}
