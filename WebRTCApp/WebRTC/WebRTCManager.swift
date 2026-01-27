//
//  WebRTCManager.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import Foundation
import Combine
import WebRTC

class WebRTCManager: ObservableObject {
    
    
    let client = WebRTCClient()
    let signaling = SocketSignalingClient()

    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?

    @Published var isMuted = false {
        didSet { client.audioTrack?.isEnabled = !isMuted }
    }

    @Published var isVideoEnabled = true {
        didSet { client.localVideoTrack?.isEnabled = isVideoEnabled }
    }

    func startCall(roomId: String, type: CallType) {
        
        // Connect signaling immediately
        signaling.connect(roomId: roomId)
        
        // for audio
        client.setupAudio()

        // Prepare local media if needed
        if type == .video {
            client.setupVideo()
            localVideoTrack = client.localVideoTrack
        }

        // Use a Task to allow async/await and error handling
        Task { [weak self] in
            guard let self else { return }

            do {
                // Create the local offer (async/throws in newer APIs)
                let localOffer = try await self.createOfferAsync()
                try await self.setLocalDescriptionAsync(localOffer)
                self.signaling.sendOffer(localOffer.sdp, roomId: roomId)
            } catch {
                print("Failed to create/send offer: \(error)")
            }

            // Register signaling callbacks
            self.signaling.onOffer = { [weak self] sdp in
                guard let self else { return }
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await self.setRemoteDescriptionAsync(RTCSessionDescription(type: .offer, sdp: sdp))
                        let answer = try await self.createAnswerAsync()
                        self.signaling.sendAnswer(answer.sdp, roomId: roomId)
                    } catch {
                        print("Failed handling remote offer: \(error)")
                    }
                }
            }

            self.signaling.onAnswer = { [weak self] sdp in
                guard let self else { return }
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await self.setRemoteDescriptionAsync(RTCSessionDescription(type: .answer, sdp: sdp))
                    } catch {
                        print("Failed setting remote answer: \(error)")
                    }
                }
            }

            self.client.onICECandidate = { [weak self] candidate in
                guard let self, let sdpMid = candidate.sdpMid else { return }
                self.signaling.sendICE([
                    "candidate": candidate.sdp,
                    "sdpMid": sdpMid,
                    "sdpMLineIndex": candidate.sdpMLineIndex
                ], roomId: roomId)
            }

            self.signaling.onICE = { [weak self] dict in
                guard let self,
                      let candidate = dict["candidate"] as? String,
                      let sdpMid = dict["sdpMid"] as? String,
                      let sdpMLineIndex = dict["sdpMLineIndex"] as? Int32 else { return }
                let ice = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                self.client.peerConnection.add(ice) { error in
                    if let error {
                        print("Failed to add ICE candidate: \(error)")
                    }
                }
            }

            self.client.onRemoteStream = { [weak self] track in
                DispatchQueue.main.async {
                    self?.remoteVideoTrack = track
                }
            }
        }
    }

    private func createOfferAsync() async throws -> RTCSessionDescription {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<RTCSessionDescription, Error>) in
            self.client.createOffer { sdp in
                continuation.resume(returning: sdp)
            }
        }
    }

    private func createAnswerAsync() async throws -> RTCSessionDescription {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<RTCSessionDescription, Error>) in
            self.client.createAnswer { sdp in
                continuation.resume(returning: sdp)
            }
        }
    }

    private func setLocalDescriptionAsync(_ sdp: RTCSessionDescription) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.client.peerConnection.setLocalDescription(sdp) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func setRemoteDescriptionAsync(_ sdp: RTCSessionDescription) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.client.peerConnection.setRemoteDescription(sdp) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func endCall() {
        // WebRTCManager.swift

        func endCall() {
            print("Ending call...")

            // Close peer connection
            client.peerConnection.close()

            // Stop tracks
            client.audioTrack?.isEnabled = false
            client.localVideoTrack?.isEnabled = false

            // Disconnect signaling
            signaling.disconnect()

            // Clear UI bindings
            DispatchQueue.main.async {
                self.localVideoTrack = nil
                self.remoteVideoTrack = nil
            }
        }

    }

}
