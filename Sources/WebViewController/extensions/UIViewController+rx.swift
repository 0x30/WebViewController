//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import RxSwift
import UIKit

extension Reactive where Base: UIViewController {
    var dismiss: Binder<Bool> {
        return Binder(base) { vc, animated in
            vc.dismiss(animated: animated, completion: nil)
        }
    }

    var present: Binder<UIViewController> {
        return Binder(base) { vc, viewController in
            vc.present(viewController, animated: true, completion: nil)
        }
    }
}
