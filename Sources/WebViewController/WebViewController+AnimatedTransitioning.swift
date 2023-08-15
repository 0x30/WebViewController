//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import UIKit

class BrowserPresentedAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
              let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return transitionContext.completeTransition(false)
        }

        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.transform = toViewController.view.transform.translatedBy(x: toViewController.view.frame.width, y: 0)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.98, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut) {
            toViewController.view.transform = .identity
            fromViewController.view.transform = fromViewController.view.transform.translatedBy(x: -fromViewController.view.frame.width / 2, y: 0)
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class BrowserDismissedAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    let isInteraction: Bool

    init(_ isInteraction: Bool) {
        self.isInteraction = isInteraction
        super.init()
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        else {
            return transitionContext.completeTransition(false)
        }

        transitionContext.containerView.insertSubview(toViewController.view, at: 0)

        if isInteraction {
            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                toViewController.view.transform = .identity
                fromViewController.view.transform = fromViewController.view.transform.translatedBy(x: fromViewController.view.frame.width, y: 0)
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                if !transitionContext.transitionWasCancelled {
                    fromViewController.endAppearanceTransition()
                }
            }
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.98, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut) {
                toViewController.view.transform = .identity
                fromViewController.view.transform = fromViewController.view.transform.translatedBy(x: fromViewController.view.frame.width, y: 0)
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                fromViewController.endAppearanceTransition()
            }
        }
    }
}

extension WebViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BrowserPresentedAnimatedTransitioning()
    }

    public func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BrowserDismissedAnimatedTransitioning(panDismissDrivenInteractiveTransition != nil)
    }

    public func interactionControllerForDismissal(using _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if config.allowPanGestureInteractionBack {
            return panDismissDrivenInteractiveTransition
        }
        return nil
    }
}
