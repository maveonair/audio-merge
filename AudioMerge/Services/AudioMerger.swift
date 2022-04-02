//
//  AudioCombiner.swift
//  Combiner
//
//  Created by Fabian Mettler on 02.04.22.
//

import Foundation
import AVKit

struct MergeError: Error {
    let description: String
}

func mergeAudioFiles(audioFiles: [AudioFile], outputURL: URL, completionHandler: @escaping (MergeError?) -> Void) {
    let composition = AVMutableComposition()
      
    for i in 0 ..< audioFiles.count {
        let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
                   
        let asset = audioFiles[i].asset
                   
        let trackContainer = asset.tracks(withMediaType: AVMediaType.audio)

        guard trackContainer.count > 0 else {
           print("nothing")
           return
        }

        let audioTrack = trackContainer[0   ]
        let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale:  600), duration: audioTrack.timeRange.duration)

        try! compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: composition.duration)
    }

    let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
    
    if assetExport != nil {
        assetExport!.outputFileType = AVFileType.m4a
        assetExport!.outputURL = outputURL
        
        assetExport!.exportAsynchronously {
            switch assetExport!.status
            {
                case AVAssetExportSession.Status.failed:
                    print("AUDIO_MERGE -> failed \(String(describing: assetExport!.error!))")
                    
                    if let error = assetExport!.error as? NSError, let message = error.localizedRecoverySuggestion {
                        completionHandler(MergeError(description: message))
                    } else {
                        completionHandler(MergeError(description: assetExport!.error!.localizedDescription))
                    }
                case AVAssetExportSession.Status.cancelled:
                    print("AUDIO_MERGE -> cancelled \(String(describing: assetExport!.error))")
                case AVAssetExportSession.Status.unknown:
                    print("AUDIO_MERGE -> unknown\(String(describing: assetExport!.error))")
                case AVAssetExportSession.Status.waiting:
                    print("AUDIO_MERGE -> waiting\(String(describing: assetExport!.error))")
                case AVAssetExportSession.Status.exporting:
                    print("AUDIO_MERGE -> exporting\(String(describing: assetExport!.error) )")
                default:
                    print("Audio Concatenation Complete")
                    completionHandler(nil)
                  }
            }
    } else {
        let errorMessage = "Could not create AVAssetExportSession"
        print("AVASSET_EXPORT -> failed \(errorMessage)")
        completionHandler(MergeError(description: "Merge process could not be started."))
    }
}
