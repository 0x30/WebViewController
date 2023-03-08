//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import UIKit

import RxCocoa
import RxSwift

class WebViewNavBar: UIView {
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var closeButton: UIButton!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var refreshButton: UIButton!

    private let disposeBag = DisposeBag()

    func config(_ backColor: UIColor,
                _ tintColor: UIColor,
                _ isHiddenClose: Observable<Bool>,
                _ isHiddenRefresh: Observable<Bool>,
                _ title: Observable<String?>) -> (close: ControlEvent<Void>, refresh: ControlEvent<Void>, cancel: ControlEvent<Void>)
    {
        backgroundColor = backColor
        self.tintColor = tintColor
        titleLabel.textColor = tintColor

        isHiddenClose.bind(to: closeButton.rx.isHidden).disposed(by: disposeBag)

        isHiddenRefresh.bind(to: refreshButton.rx.isHidden).disposed(by: disposeBag)
        title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)

        return (closeButton.rx.tap, refreshButton.rx.tap, cancelButton.rx.tap)
    }
}
