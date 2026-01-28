//
//  SocketSignalingClient.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import Foundation
import SocketIO

class SocketSignalingClient {
    
    let manager = SocketManager(socketURL: URL(string: "https://510e53db037e.ngrok-free.app")!)
    let socket: SocketIOClient

    var onOffer: ((String) -> Void)?
    var onAnswer: ((String) -> Void)?
    var onICE: (([String: Any]) -> Void)?

    init() {
        socket = manager.defaultSocket

        socket.on("offer") { data, _ in
            if let sdp = data.first as? String {
                self.onOffer?(sdp)
            }
        }

        socket.on("answer") { data, _ in
            if let sdp = data.first as? String {
                self.onAnswer?(sdp)
            }
        }

        socket.on("ice") { data, _ in
            if let dict = data.first as? [String: Any] {
                self.onICE?(dict)
            }
        }
    }

    func connect(roomId: String) {
        socket.connect()
        socket.on(clientEvent: .connect) { _, _ in
            self.socket.emit("join-room", roomId)
        }
    }

    func sendOffer(_ sdp: String, roomId: String) {
        socket.emit("offer", ["sdp": sdp, "roomId": roomId])
        print("offer \(roomId)")
    }

    func sendAnswer(_ sdp: String, roomId: String) {
        socket.emit("answer", ["sdp": sdp, "roomId": roomId])
        print("answer \(roomId)")
    }

    func sendICE(_ dict: [String: Any], roomId: String) {
        socket.emit("ice", ["candidate": dict, "roomId": roomId])
        print("Ice \(roomId)")
    }
    
    
    func disconnect() {
       print("Socket Disssconnect SuccessFully")
        socket.disconnect()
    }
}

