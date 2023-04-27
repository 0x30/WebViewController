//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import UIKit
import WebKit

public extension WebViewController {
    struct Config: Codable {
        /// 链接
        private var url: String?
        /// 标题
        var title: String?
        /// 新推出 status Bar 样式
        private var barStatusStyle = 0
        /// 导航栏 背景颜色
        private var barBackHexColor: String?
        /// 导航栏 文字颜色
        private var barTintHexColor: String?

        /// 页面加载完成 需要执行的 js 代码
        private var javaScript: String?

        /// 允许打开的 scheme 集合
        var allowScheme: [String] = []
        var appOpenScheme: [String] = []

        /// javaScript 和 native 交互的 bridge 名称
        var scriptMessageName: String?

        /// 消息交互
        /// 如果存在的话，需要处理 baimaodai 消息监听 js 交互
        public var messageCallback: String?

        /// 额外配置项
        var allowsLinkPreview = false
        var allowsBackForwardNavigationGestures = false
        // 是否允许 app 打开 UniversalLinks
        var allowUniversalLinksOpenApp = false

        static func initSelf(_ data: Data) -> Self? {
            try? JSONDecoder().decode(self.self, from: data)
        }
    }
}

extension WebViewController.Config {
    var urlRequest: URLRequest? {
        guard let url = url, let url = URL(string: url) else { return nil }
        return URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
    }

    var statusBarStyle: UIStatusBarStyle {
        switch barStatusStyle {
        case 0:
            return UIStatusBarStyle.lightContent
        case 1:
            return UIStatusBarStyle.darkContent
        default:
            return UIStatusBarStyle.default
        }
    }

    var barBackColor: UIColor {
        guard let hex = barBackHexColor else { return .white }
        return UIColor(hexString: hex)
    }

    var barTintColor: UIColor {
        guard let hex = barTintHexColor else { return .black }
        return UIColor(hexString: hex)
    }

    var userJavaScript: WKUserScript? {
        guard let javaScript = javaScript else { return nil }
        return WKUserScript(source: javaScript, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
    }
}

extension WebViewController.Config {
    // 配置 webview
    func apply(webView: WKWebView) {
        webView.allowsLinkPreview = allowsLinkPreview
        webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures

        if let script = userJavaScript {
            webView.configuration.userContentController.addUserScript(script)
        }

        if let url = urlRequest {
            webView.load(url)
        }
    }

    /// 检查是否可以打开该链接
    /// - Parameter url: 链接地址
    /// - Returns: 授权令
    func detect(url: URL?) async -> WKNavigationActionPolicy {
        guard let url = url, let scheme = url.scheme else { return .cancel }

        // 如果是 itunes.apple.com 的网址
        if let host = url.host, host == "itunes.apple.com" {
            if await UIApplication.shared.open(url) {
                return .allow
            }
        }

        // 是否允许 universalLinks 打开 app
        if allowUniversalLinksOpenApp, scheme == "https", await UIApplication.shared.open(url, options: [.universalLinksOnly: true]) {
            return .allow
        }

        // 如果需要通过 app Scheme 的方式打开 app
        if appOpenScheme.contains(scheme) {
            await UIApplication.shared.open(url)
            return .cancel
        }

        // 如果 允许 加载 请求
        if allowScheme.contains(scheme) {
            return .allow
        }
        return .cancel
    }
}
