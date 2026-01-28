//
//  WebRTCAppApp.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import SwiftUI

@main
struct WebRTCAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(webRTC:    WebRTCManager.init())
        }
    }
}
