//
//  User.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

nonisolated struct User: Codable {
    let id_user: Int?
    let name: String
    let email: String
    let password: String
    let created_at: String?
}
