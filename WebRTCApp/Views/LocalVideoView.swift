//
//  LocalVideoView.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import SwiftUI
import WebRTC

struct LocalVideoView: UIViewRepresentable {
    
    let videoTrack: RTCVideoTrack?
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView()
        view.videoContentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        if let track = videoTrack {
            track.add(uiView)
        }
    }
}

#Preview {
    LocalVideoView(videoTrack: nil)
        .frame(width: 120, height: 180)
        .background(.black)
}
