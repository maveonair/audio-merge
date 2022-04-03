//
//  AudioAudioMerge.swift
//  AudioMerge
//
//  Created by Fabian Mettler on 02.04.22.
//

import Foundation
import AVKit
import SwiftUI

struct MergeError: Error {
    let description: String
}

struct AudioMerger {
    enum Status {
        case failed(MergeError)
        case done
    }
}

func mergeAudioFiles(audioFiles: [AudioFile], outputURL: URL, completionHandler: @escaping (AudioMerger.Status?) -> Void) {
    guard let composition = createComposition(audioFiles: audioFiles) else {
        completionHandler(.failed(MergeError(description: "Could not create composition")))
        return
    }

    guard let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
        let errorMessage = "Could not create AVAssetExportSession"
        print("AUDIO_MERGE -> failed \(errorMessage)")
        completionHandler(.failed(MergeError(description: "Merge process could not be started.")))
        return
    }

    assetExport.outputFileType = .m4a
    assetExport.outputURL = outputURL
    
    assetExport.exportAsynchronously {
        switch assetExport.status
        {
        case .failed:
            print("AUDIO_MERGE -> failed \(String(describing: assetExport.error!))")

            if let error = assetExport.error as? NSError, let message = error.localizedRecoverySuggestion {
                completionHandler(.failed(MergeError(description: message)))
            } else {
                completionHandler(.failed(MergeError(description: assetExport.error!.localizedDescription)))
            }
        default:
            print("AUDIO_MERGE -> complete")
            completionHandler(.done)
        }
    }

}

private func createComposition(audioFiles: [AudioFile]) -> AVMutableComposition? {
    let composition = AVMutableComposition()
    
    for audioFile in audioFiles {
        let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())!
        let asset = audioFile.asset

        let trackContainer = asset.tracks(withMediaType: .audio)
        guard trackContainer.count > 0 else {
            print("AUDIO_MERGE -> skip asset with empty tracks")
            return nil
        }

        let audioTrack = trackContainer[0]
        let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale:  600), duration: audioTrack.timeRange.duration)

        try! compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: composition.duration)
    }

    return composition
}
