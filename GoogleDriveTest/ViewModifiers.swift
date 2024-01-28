//
//  ViewModifiers.swift
//  FirebaseDemo
//
//  Created by Larry Shannon on 11/7/23.
//

import SwiftUI

struct DefaultTextButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding([.leading, .trailing])
    }
}

struct EmailPaswordModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
    }
}

extension View {
    func DefaultTextButtonStyle() -> some View {
        modifier(DefaultTextButton())
    }
    
    func EmailPaswordStyle() -> some View {
        modifier(EmailPaswordModifier())
    }
}

public extension Date {
    
    static func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        let value = "\(dateFormatter.string(from: date))"
        return value
    }
}
