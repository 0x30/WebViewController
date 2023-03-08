//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import RxCocoa
import RxSwift

import WebKit

extension Reactive where Base: WKWebView {
    var goBack: Binder<Void> {
        return Binder(base) { vc, _ in
            vc.goBack()
        }
    }

    var goForward: Binder<Void> {
        return Binder(base) { vc, _ in
            vc.goForward()
        }
    }

    var reload: Binder<Void> {
        return Binder(base) { vc, _ in
            vc.reload()
        }
    }
}
