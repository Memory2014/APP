//
//  AnnotationViewController.swift
//  Photo
//
//  Created by zhongyi on 16/3/26.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

import UIKit

open class AnnotationViewController: SpotlightViewController {

    @IBOutlet var annotationViews: [UIView]!
    
    @IBOutlet var texst: UILabel!

    @IBOutlet var appear: UILabel!
    @IBOutlet var move: UILabel!
    @IBOutlet var photo: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var support: UILabel!
    
    var stepIndex: Int = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        appear.text = NSLocalizedString("Click  + , input the password", comment: "Appear spotlight on view.");
        //move.text = NSLocalizedString("Move spotlight.", comment: "Move spotlight.");
        photo.text = NSLocalizedString("PrivatePhoto", comment: "");
        //support.text = NSLocalizedString("Support rounded rect.", comment: "Support rounded rect.");
    }
    
    func next(_ labelAnimated: Bool) {
        updateAnnotationView(labelAnimated)
        
        let screenSize = UIScreen.main.bounds.size
        switch stepIndex {
        case 0:
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: screenSize.width - 26, y: 42), diameter: 50))
        case 1:
            spotlightView.move(Spotlight.Oval(center: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2), diameter: 0),moveType: .disappear)
        //case 1:
        //    spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width - 75, 42), diameter: 50))
        //case 2:
        //    spotlightView.move(Spotlight.RoundedRect(center: CGPointMake(screenSize.width / 2, 42), size: CGSizeMake(120, 40), cornerRadius: 6), moveType: .Disappear)
        //case 1:
        //    spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width / 2, 200), diameter: 400), moveType: .Disappear)

        //case 5:
        //    spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width / 2, 200), diameter: 0), moveType: .Disappear)
        case 3:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
        stepIndex += 1
    }
    
    func updateAnnotationView(_ animated: Bool) {
        annotationViews.enumerated().forEach { index, view in
            UIView .animate(withDuration: animated ? 0.25 : 0, animations: {
                view.alpha = index == self.stepIndex ? 1 : 0
            }) 
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
