//
//  WebRTCClient.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import Foundation
import WebRTC
import AVFoundation


class WebRTCClient: NSObject {
    
    private let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
    private let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
    private lazy var factory: RTCPeerConnectionFactory = {
        RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    var peerConnection: RTCPeerConnection!
    var audioTrack: RTCAudioTrack?
    var localVideoTrack: RTCVideoTrack?

    var onICECandidate: ((RTCIceCandidate) -> Void)?
    var onRemoteStream: ((RTCVideoTrack?) -> Void)?

    override init() {
        super.init()

        // Configure audio session (optional but recommended for iOS)
        RTCAudioSession.sharedInstance().useManualAudio = true

        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        config.sdpSemantics = .unifiedPlan

        let pcConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: [
            "DtlsSrtpKeyAgreement": "true"
        ])

        peerConnection = factory.peerConnection(with: config, constraints: pcConstraints, delegate: self)

        let audioSource = factory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil))
        audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        if let audioTrack {
            peerConnection.add(audioTrack, streamIds: ["stream0"])
        }
    }

    func setupVideo() {
        let source = factory.videoSource()
        localVideoTrack = factory.videoTrack(with: source, trackId: "video0")
        if let localVideoTrack {
            peerConnection.add(localVideoTrack, streamIds: ["stream0"])
        }
    }
    func setupAudio() {
        // Configure iOS audio session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord,
                                 mode: .voiceChat,
                                 options: [.allowBluetoothHFP, .defaultToSpeaker])
        try? session.setActive(true)

        // Create WebRTC audio source/track via factory (direct init is unavailable)
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = factory.audioSource(with: constraints)
        let newAudioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        self.audioTrack = newAudioTrack

        // Add to PeerConnection if not already added
        if let track = self.audioTrack {
            peerConnection.add(track, streamIds: ["stream0"])
        }
    }
    
    func createOffer(cb: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: [
            "OfferToReceiveAudio": "true",
            "OfferToReceiveVideo": "true"
        ], optionalConstraints: nil)
        peerConnection.offer(for: constraints) { [weak self] sdp, error in
            guard let self, let sdp = sdp, error == nil else { return }
            self.peerConnection.setLocalDescription(sdp) { _ in }
            cb(sdp)
        }
    }

    func createAnswer(cb: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: [
            "OfferToReceiveAudio": "true",
            "OfferToReceiveVideo": "true"
        ], optionalConstraints: nil)
        peerConnection.answer(for: constraints) { [weak self] sdp, error in
            guard let self, let sdp = sdp, error == nil else { return }
            self.peerConnection.setLocalDescription(sdp) { _ in }
            cb(sdp)
        }
    }
    
    }

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        onRemoteStream?(stream.videoTracks.first)
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        onICECandidate?(candidate)
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}

