//
//  File.swift
//
//
//  Created by 荆文征 on 2023/3/8.
//

import Foundation

extension Encodable {
    /// encodable 对象 转 json 字符串
    var jsonString: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        guard let data = try? jsonEncoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
