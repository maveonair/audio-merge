//
//  AudioFile.swift
//  AudioMerge
//
//  Created by Fabian Mettler on 26.03.22.
//

import AVFoundation

class AudioFile : Identifiable {
    var url: URL
    var asset: AVAsset
    
    var artist: String {
        return lookupMetadata(key: "artist")
    }
    
    var title: String {
        return lookupMetadata(key: "title")
    }
    
    var album: String {
        return lookupMetadata(key: "albumName")
    }
    
    var duration: CMTime {
        return asset.duration
    }
    
    var durationFormatted: String {
        return duration.positionalTime
    }
    
    init(url URL: URL) {
        self.url = URL
        self.asset = AVAsset(url: self.url)
    }
    
    func lookupMetadata(key: String) -> String {
        for metadata in asset.commonMetadata {
            guard let commonKey = metadata.commonKey else {
                return ""
            }
            
            if commonKey.rawValue == key {
                return metadata.stringValue!
            }
        }
        
        return "";
    }
}
