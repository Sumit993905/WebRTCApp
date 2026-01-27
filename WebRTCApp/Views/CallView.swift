//
//  CallView.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import SwiftUI

class MockWebRTCManager: WebRTCManager {
    override func startCall(roomId: String, type: CallType) {
        // Do nothing, just fake state
        self.isVideoEnabled = type == .video
    }
}


struct CallView: View {
    
    let roomId: String
    let callType: CallType
    let onEnd: () -> Void

    @StateObject private var webRTC: WebRTCManager

    // Dependency injection for preview
    init(roomId: String,
         callType: CallType,
         onEnd: @escaping () -> Void,
         webRTC: WebRTCManager = WebRTCManager()) {
        
        self.roomId = roomId
        self.callType = callType
        self.onEnd = onEnd
        _webRTC = StateObject(wrappedValue: webRTC)
    }

    var body: some View {
        ZStack {
            
            // Video / Audio UI
            if callType == .video && webRTC.isVideoEnabled {
                RemoteVideoView(videoTrack: webRTC.remoteVideoTrack)
                LocalVideoView(videoTrack: webRTC.localVideoTrack)
            } else {
                Color.black
                Text("Audio Call")
                    .foregroundColor(.white)
                    .font(.title)
            }

            // Controls
            VStack {
                Spacer()
                CallControlsView(
                    isMuted: $webRTC.isMuted,
                    isVideoEnabled: $webRTC.isVideoEnabled,
                    showVideoButton: callType == .video,
                    onEndCall: {
                        webRTC.endCall()
                        onEnd()
                    }
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            webRTC.startCall(roomId: roomId, type: callType)
            print("Audio track:", webRTC.client.audioTrack)
            print("Local audio:", webRTC.client.audioTrack)
            print("Remote audio:", webRTC.client.onRemoteStream)

        }

        .onDisappear {
            webRTC.endCall()
        }
    }
}



#Preview("Audio Call") {
    CallView(
        roomId: "test123",
        callType: .audio,
        onEnd: {},
        webRTC: MockWebRTCManager()
    )
}

#Preview("Video Call") {
    CallView(
        roomId: "test123",
        callType: .video,
        onEnd: {},
        webRTC: MockWebRTCManager()
    )
}


