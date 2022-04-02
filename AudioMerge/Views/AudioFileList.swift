//
//  AudilFileList.swift
//  AudioMerge
//
//  Created by Fabian Mettler on 02.04.22.
//

import SwiftUI

struct AudioFileList: View {
    var audioFiles: [AudioFile] = []
    
    var body: some View {
        Table(self.audioFiles) {
            TableColumn("Artist", value: \.artist)
            TableColumn("Title", value: \.title)
            TableColumn("Album", value: \.album)
            TableColumn("Duration", value: \.durationFormatted)
        }
    }
}
