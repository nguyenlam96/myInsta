//
//  CustomAnimationDismisser.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        // fromView now is CameraView
        guard let fromView = transitionContext.view(forKey: .from) else {
            Logger.LogDebug(type: .error, message: "fromView is nil")
            return
        }
        // toView now is HomeVC
        guard let toView = transitionContext.view(forKey: .to) else {
            Logger.LogDebug(type: .error, message: "toView is nil")
            return
        }
        container.addSubview(toView)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
        }) { (success) in
            
            transitionContext.completeTransition(true)
        }
        
    }
    
    
    
    
}
