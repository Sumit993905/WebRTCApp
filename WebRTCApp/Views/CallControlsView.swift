//
//  CallControlsView.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import SwiftUI

struct CallControlsView: View {
    
    @Binding var isMuted: Bool
    @Binding var isVideoEnabled: Bool
    let showVideoButton: Bool
    
    let onEndCall: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            
            // Mute
            ControlButton(
                icon: isMuted ? "mic.slash.fill" : "mic.fill",
                color: .gray
            ) {
                isMuted.toggle()
            }
            
            // End Call
            ControlButton(
                icon: "phone.down.fill",
                color: .red,
                size: 70
            ) {
                onEndCall()
            }
            
            // Video toggle (sirf video call me)
            if showVideoButton {
                ControlButton(
                    icon: isVideoEnabled ? "video.fill" : "video.slash.fill",
                    color: .gray
                ) {
                    isVideoEnabled.toggle()
                }
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    CallControlsView(
        isMuted: .constant(false),
        isVideoEnabled: .constant(true),
        showVideoButton: true,
        onEndCall: {}
    )
    .background(Color.black)
}

