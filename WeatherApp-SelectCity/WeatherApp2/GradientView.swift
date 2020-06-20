//
//  GradientView.swift
//  WeatherApp2
//
//  Created by Ania Wójcik on 15/06/2020.
//  Copyright © 2020 Ania Wójcik. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }

        theLayer.colors = [#colorLiteral(red: 0.380392164, green: 0.270588249, blue: 0.8549019694, alpha: 1).cgColor,#colorLiteral(red: 0.2901960909, green: 0.7529411912, blue: 0.8313725591, alpha: 1).cgColor]

        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

