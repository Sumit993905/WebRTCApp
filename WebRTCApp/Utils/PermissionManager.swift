//
//  PermissionManager.swift
//  WebRTCApp
//
//  Created by Sumit Raj Chingari on 27/01/26.
//

import Foundation
import AVFoundation

class PermissionManager {
    static func requestAll(completion: @escaping () -> Void) {
        let requestCamera: (@escaping () -> Void) -> Void = { finish in
            AVCaptureDevice.requestAccess(for: .video) { _ in
                DispatchQueue.main.async { finish() }
            }
        }

        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { _ in
                requestCamera {
                    completion()
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { _ in
                requestCamera {
                    completion()
                }
            }
        }
    }
}
