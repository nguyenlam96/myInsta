//
//  CustomAnimationPresentor.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        // fromView is now HomeVC
        guard let fromView = transitionContext.view(forKey: .from) else {
            Logger.LogDebug(type: .error, message: "fromView is nil")
            return
        }
        // toView is CameraController:
        guard let toView = transitionContext.view(forKey: .to) else {
            Logger.LogDebug(type: .error, message: "toView is nil")
            return
        }
        containerView.addSubview(toView)
        toView.frame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        }) { (success) in
            transitionContext.completeTransition(true)
        }

    }

}

