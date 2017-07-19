//
//  AnnotationViewController.swift
//  Gecco
//
//  Created by yukiasai on 2016/01/19.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

open class AnnotationViewController: SpotlightViewController {
    
    @IBOutlet var annotationViews: [UIView]!
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    
    var stepIndex: Int = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        firstLabel.text = NSLocalizedString("Click  + , input the password. You only need to enter a password when you first install the app", comment:"")
        secondLabel.text = NSLocalizedString("Or press long on the title,use Touch ID for PrivatePhoto", comment:"")
        logoLabel.text = NSLocalizedString("ACROPOLIS", comment:"")
        
    }
    
    func next(_ labelAnimated: Bool) {
        updateAnnotationView(labelAnimated)
        
        let screenSize = UIScreen.main.bounds.size
        switch stepIndex {
        case 0:
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: screenSize.width - 26, y: 42), diameter: 50))
        //case 1:
        //    spotlightView.move(Spotlight.Oval(center: CGPoint(x: screenSize.width - 75, y: 42), diameter: 50))
        case 1:
            spotlightView.move(Spotlight.RoundedRect(center: CGPoint(x: screenSize.width / 2, y: 42), size: CGSize(width: 120, height: 40), cornerRadius: 6), moveType: .disappear)
        case 2:
            spotlightView.move(Spotlight.Oval(center: CGPoint(x: screenSize.width / 2, y: 200), diameter: 220), moveType: .disappear)
        case 3:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
        stepIndex += 1
    }
    
    func updateAnnotationView(_ animated: Bool) {
        annotationViews.enumerated().forEach { index, view in
            UIView.animate(withDuration: animated ? 0.25 : 0) {
                view.alpha = index == self.stepIndex ? 1 : 0
            }
        }
    }
}

extension AnnotationViewController: SpotlightViewControllerDelegate {
    public func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    public func spotlightViewControllerTapped(_ viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        next(true)
    }
    
    public func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
}
