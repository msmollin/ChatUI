//
//  CameraField.swift
//  
//
//  Created by Jaesung Lee on 2023/02/12.
//

import SwiftUI
import Combine

public struct CameraField: View {
    @Environment(\.appearance) var appearance
    
    @State private var isCameraViewPresented: Bool = true
    @State private var capturedItem: CapturedItemView.CaptureType?
    
    @Binding var isPresented: Bool
    
    public var body: some View {
        VStack {
            if let capturedItem = capturedItem {
//            if let imageData = dataModel.capturedPhotoData?.fileDataRepresentation() {
                CapturedItemView(itemType: capturedItem)
                    .frame(width: 600)
            } else {
                appearance.secondary
                    .overlay {
                        VStack {
                            Image.downloadFailed.xLarge
                                .clipped()

                            Text(String.Message.failedPhoto)
                                .font(appearance.footnote.bold())
                        }
                        .foregroundColor(appearance.secondary)
                    }
                    .frame(
                        width: 600,
                        height: 600
                    )
            }
            
            HStack {
                Button(action: retake) {
                    Image.camera.medium
                }
                .tint(appearance.tint)
                .frame(width: 36, height: 36)
                
                Spacer()
                
                Button(action: send) {
                    HStack {
                        Image.send.xSmall
                        
                        Text("Send")
                            .font(appearance.footnote.bold())
                    }
                    .frame(height: 24)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 18)
                    .background {
                        appearance.tint
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(16)
        }
        .background { Color(.systemBackground) }
        .fullScreenCover(isPresented: $isCameraViewPresented) {
//            CameraView {
//                isPresented = false
//            }
          EmptyView()
        }
        .onReceive(capturedItemPublisher) { capturedItem in
            self.capturedItem = capturedItem
            self.isCameraViewPresented = false
        }
    }
    
    func retake() {
        isCameraViewPresented = true
    }
    
    func send() {
        let _ = Empty<Void, Never>()
            .sink { _ in
                guard let capturedItem = capturedItem else { return }
                let style: MessageStyle
                switch capturedItem {
                case .photo(let data):
                    style = MessageStyle.media(.photo(data))
                case .video(let data):
                    style = MessageStyle.media(.video(data))
                }
                sendMessagePublisher.send(style)
            } receiveValue: { _ in }
        withAnimation {
            isPresented = false            
        }
    }
}
