//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import WebKit

extension WebViewController: WKUIDelegate {
    public func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "确认", style: UIAlertAction.Style.default) { _ in completionHandler() })
        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "确认", style: UIAlertAction.Style.default) { _ in completionHandler(true) })
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { _ in completionHandler(false) })
        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: UIAlertController.Style.alert)

        alert.addTextField { textFiled in
            textFiled.text = defaultText
            textFiled.placeholder = defaultText
            textFiled.clearButtonMode = UITextField.ViewMode.whileEditing
        }

        alert.addAction(UIAlertAction(title: "确认", style: UIAlertAction.Style.default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { _ in completionHandler(nil) })

        present(alert, animated: true, completion: nil)
    }
}
