//
//  ViewControllerAnimation.swift
//  collectionViewTest!
//
//  Created by Mahmoud Sherbeny on 11/8/20.
//

import UIKit

class AnimationController: NSObject {
    
    private let animationDurration: Double
    private let animationType: AnimationType
    
    enum AnimationType {
        case present
        case dismiss
    }
    
    init(animationDurration: Double, animationType: AnimationType) {
        self.animationDurration = animationDurration
        self.animationType = animationType
    }
    
}

extension AnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: animationDurration) ?? 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return }
        
        switch animationType {
        case .present:
            transitionContext.containerView.addSubview(toViewController.view)
            presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
        case .dismiss:
            transitionContext.containerView.addSubview(fromViewController.view)
            dismissAnimation(with: transitionContext, viewToAnimate: fromViewController.view)
        }
    }
    
    func dismissAnimation(with tranistionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        
        let duration = transitionDuration(using: tranistionContext)
        let moveOut = CGAffineTransform(translationX: -viewToAnimate.frame.width, y: 0)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                viewToAnimate.transform = moveOut
            }
        } completion: { _ in
            tranistionContext.completeTransition(true)
        }
    }
    
    func presentAnimation(with tranistionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        viewToAnimate.clipsToBounds = true
        viewToAnimate.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        
        let duration = transitionDuration(using: tranistionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                viewToAnimate.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        } completion: { _ in
            tranistionContext.completeTransition(true)
        }
    }
}
