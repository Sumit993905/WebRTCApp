//
//  HomeView.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @State private var roomId = ""
    @State private var isConnected = false
    @State private var callType: CallType?
    
    @StateObject  var webRTC: WebRTCManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                Text("WebRTC App")
                    .font(.largeTitle)
                
                
                HStack{
                    Button {
//                        guard !roomId.isEmpty else { return }
                        isConnected = true
                    } label: {
                        Text(isConnected ? "Connected ✅" : "Connect 🔌")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(30)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isConnected)
                    
                    
                    Button("Disconnect ❌") {
                        isConnected = false
                        callType = nil
                    }
                    .padding(30)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isConnected)
                }
                
                // Connect Button
                

                
                Spacer()
                
                TextField("Enter Room ID", text: $roomId)
                    .padding(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Button("Sumit Room ID"){
                    print(roomId)
                }

                
                
                Button("Audio Call 🎧") {
                    callType = .audio
                    webRTC.startCall(roomId: roomId, type: callType!)
                }
                .disabled(!isConnected)

                
                Button("Video Call 🎥") {
                    callType = .video
                    webRTC.startCall(roomId: roomId, type: callType!)

                }
                .disabled(!isConnected)
                
                Spacer()

                
                
            }
            .padding()
            .onAppear {
                PermissionManager.requestAll {}
            }
            .navigationDestination(isPresented: Binding(
                get: { callType != nil },
                set: { if !$0 { callType = nil } }
            )) {
                if let type = callType {
                    CallView(
                        roomId: roomId,
                        callType: type,
                        onEnd: {
                            callType = nil
                            isConnected = false
                        }
                    )
                }
            }
        }
    }
}


#Preview {
    HomeView(webRTC: WebRTCManager.init())
}
