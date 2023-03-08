//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import Foundation

struct WebViewControllerMessage: Encodable {
    var type: Type
    var data: String?

    enum `Type`: String, Encodable {
        case refresh, close, cancel, message
    }
}
