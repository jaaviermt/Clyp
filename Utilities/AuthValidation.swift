//
//  AuthValidation.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

/// Returns nil when the value is valid, or a user-facing
/// error message when it isn't. Server-side rules still apply.
enum AuthValidation {
    static func emailError(for email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Email is required." }

        let regex = #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#
        if trimmed.range(of: regex, options: .regularExpression) == nil {
            return "Enter a valid email address."
        }
        return nil
    }

    static func passwordError(for password: String) -> String? {
        if password.isEmpty { return "Password is required." }
        if password.count < 6 { return "Password must be at least 6 characters." }
        return nil
    }

    static func nameError(for name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Name is required." }
        if trimmed.count < 2 { return "Name must be at least 2 characters." }
        return nil
    }
}
