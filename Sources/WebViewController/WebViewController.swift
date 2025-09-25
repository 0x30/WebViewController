
import UIKit

import WebKit

import RxCocoa
import RxSwift
import RxWebKit

public class WebViewController: UIViewController {
    /// WebView 配置对象
    var config: Config!

    /// 滑动手势
    private var panScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    public var panDismissDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition? = nil

    @IBOutlet var webView: WKWebView!
    @IBOutlet var navBar: WebViewNavBar!

    // 浏览器消息字符串执行
    public let browserMessaggePublishRelay = PublishRelay<String?>()

    fileprivate let disposeBag = DisposeBag()

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        config.statusBarStyle
    }

    override public func viewDidDisappear(_ animated: Bool) {
        browserMessaggePublishRelay.accept(WebViewControllerMessage(type: .close).jsonString)
        super.viewDidDisappear(animated)
        webView.configuration.userContentController.removeAllUserScripts()
    }

    /// 标题监听对象
    lazy var titleObservable: Observable<String?> = {
        if let title = config.title {
            return Observable.of(title)
        }
        return Observable.combineLatest(Observable.of(config.title), webView.rx.title).map { $0 ?? $1 }.distinctUntilChanged()
    }()

    /// 根据用户提供的 name 进行数据交互
    lazy var scriptMessage: Observable<WebViewControllerMessage> = {
        guard let name = config.scriptMessageName else { return Observable.never() }
        return webView.configuration.userContentController.rx.scriptMessage(forName: name)
            .map { WebViewControllerMessage(type: .message, data: $0.body as? String) }
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        webView.uiDelegate = self
        webView.navigationDelegate = self

        #if DEBUG
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
        #endif

        // 配置 navView
        let (close, refresh, cancel) = navBar.config(config.barBackColor,
                                                     config.barTintColor,
                                                     webView.rx.canGoBack.map { !$0 },
                                                     webView.rx.loading,
                                                     titleObservable)

        // 刷新按钮点击事件
        let refreshShare = refresh.share()
        let cancelAction = cancel.map { [weak self] _ in self?.webView.canGoBack }.share()
        let cancelSahre = cancelAction.filter { $0 == true }.share()

        // 如果点击返回的按钮的时候，浏览器不可以返回了
        // 点击 关闭按钮
        // 推出视图
        let closeShare = Observable.merge(close.map { true },
                                          cancelAction.filter { $0 == false }.map { _ in true }).share()

        // webview 交互 绑定
        refreshShare.bind(to: webView.rx.reload).disposed(by: disposeBag)
        closeShare.bind(to: rx.dismiss).disposed(by: disposeBag)
        cancelSahre.map { _ in () }.bind(to: webView.rx.goBack).disposed(by: disposeBag)

        // merge 关闭 刷新 等操作 并发出消息 绑定到 browserMessaggePublishRelay
        Observable.merge([
            scriptMessage,
            cancelSahre.map { _ in WebViewControllerMessage(type: .cancel) },
            refreshShare.map { _ in WebViewControllerMessage(type: .refresh) },
        ])
        .map(\.jsonString)
        .bind(to: browserMessaggePublishRelay)
        .disposed(by: disposeBag)

        config.apply(webView: webView)

        webView.addGestureRecognizer(panScreenEdgePanGestureRecognizer)
        panScreenEdgePanGestureRecognizer.edges = .left
        panScreenEdgePanGestureRecognizer.delegate = self
        panScreenEdgePanGestureRecognizer.addTarget(self, action: #selector(panHandle(_:)))
    }
}

public extension WebViewController {
    /// 工厂方法获取一个 WebViewController
    /// - Returns: WebViewController 实例
    static func viewController(with configData: Data) -> WebViewController? {
        guard let config = WebViewController.Config.initSelf(configData) else { return nil }
        return viewController(with: config)
    }

    /// 工厂方法获取一个 WebViewController
    /// - Returns: WebViewController 实例
    static func viewController(with config: WebViewController.Config) -> WebViewController? {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: Bundle.module).instantiateInitialViewController() as? WebViewController else { return nil }

        viewController.config = config
        viewController.modalPresentationStyle = .fullScreen
        viewController.transitioningDelegate = viewController

        return viewController
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return config.allowPanGestureInteractionBack && !webView.canGoBack
    }

    @objc func panHandle(_ sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .possible:
            break
        case .began:
            panDismissDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            dismiss(animated: true)
        case .changed:
            let progress = sender.translation(in: view).x / view.frame.width
            panDismissDrivenInteractiveTransition?.update(progress)
        default:
            let progress = sender.location(in: sender.view).x / view.frame.width
            if progress > 0.5 || sender.velocity(in: sender.view).x > 800 {
                panDismissDrivenInteractiveTransition?.finish()
            } else {
                panDismissDrivenInteractiveTransition?.cancel()
                panDismissDrivenInteractiveTransition = nil
            }
        }
    }
}
