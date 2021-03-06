//
//  ContentView.swift
//  AudioMerge
//
//  Created by Fabian Mettler on 14.03.22.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var audioFiles: [AudioFile] = []
    
    @State private var isProcessing = false
    
    @State private var showAlert = false
    @State private var mergeError: MergeError?
    
    private var hasFiles: Bool {
        return !self.audioFiles.isEmpty
    }
    
    var body: some View {
        Group {
            if (self.hasFiles) {
                AudioFileList(audioFiles: self.audioFiles)
                
                if (self.isProcessing) {
                    ProgressView("Merge audio files…")
                        .progressViewStyle(.linear)
                        .padding()
                }
                
            } else {
                Text("Click the Add button to add audio files.")
            }
        }
        .toolbar {
            Button(action: removeAllFiles) {
                Label("Clear all audio files", systemImage: "trash")
            }.opacity(self.hasFiles ? 1.0 : 0.0)
                .disabled(self.isProcessing)
            
            Button(action: addFiles) {
                Label("Add audio files", systemImage: "doc.badge.plus")
            }.disabled(self.isProcessing)
            
            Button(action: startMerging) {
                Label("Merge audio files into one", systemImage: "play.fill")
            }.disabled(!self.hasFiles || self.isProcessing)
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Merge failed"),
                message: Text(self.mergeError!.description)
            )
        }
        
    }
    
    private func removeAllFiles() {
        self.audioFiles = []
    }
    
    private func addFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType.audio]
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                let audioFile = AudioFile(url: url)
                self.audioFiles.append(audioFile)
            }
        }
    }
    
    private func startMerging() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.audio]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.allowsOtherFileTypes = false
        
        panel.title = "Save new audio file"
        panel.message = "Choose a folder and a name to store the merged audio file."
        panel.nameFieldLabel = "File name:"
        panel.nameFieldStringValue = "Untitled.m4a"
        
        if panel.runModal() == .OK {
            if let outputURL = panel.url {
                self.isProcessing = true
                
                mergeAudioFiles(audioFiles: self.audioFiles, outputURL: outputURL, completionHandler: { status in
                    self.isProcessing = false
                     
                    switch status {
                    case let .failed(error):
                        self.mergeError = error
                        self.showAlert = true
                    default:
                        self.mergeError = nil
                    }
                })
            }
        }
    }
}
