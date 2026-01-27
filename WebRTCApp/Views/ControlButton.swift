//
//  ControlButton.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import SwiftUI

struct ControlButton: View {
    
    let icon: String
    let color: Color
    var size: CGFloat = 60
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(color)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ControlButton(icon: "mic.fill", color: .gray) {}
}

