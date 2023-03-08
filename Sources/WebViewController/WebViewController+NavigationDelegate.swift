//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import Foundation
import WebKit

extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        Task {
            if await config.detect(url: navigationAction.request.url) == .allow {
                webView.load(navigationAction.request)
            }
        }
        return nil
    }

    // 加载完成
    public func webView(_: WKWebView, didFinish _: WKNavigation!) {}

    // 加载失败
    public func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }
    }
}
