//
//  VideoPlayerController.swift
//  TikTok Video Feed Swift
//
//  Created by Cedan Misquith on 19/10/22.
//

import UIKit
import AVFoundation

protocol PlayVideoLayerContainer {
    var videoURL: String? { get set }
    var videoLayer: AVPlayerLayer { get set }
    func visibleVideoHeight() -> CGFloat
}

class VideoPlayerController: NSObject {
    var minimumLayerHeightToPlay: CGFloat = 60
    var mute = false
    var preferredPeakBitRate: Double = 1000000
    static private var playerViewControllerKVOContext = 0
    static let sharedVideoPlayer = VideoPlayerController()
    // Video url for currently playing video
    private var videoURL: String?
    /*
     Stores video url as key and true as value when player item associated to the url
     is being observed for its status change.
     Helps in removing observers for player items that are not being played.
     */
    private var observingURLs = [String: Bool]() // Dictionary<String, Bool>()
    
    private var videoLayers = VideoLayers()
    // Current AVPlapyerLayer that is playing video
    private var currentLayer: AVPlayerLayer?

    override init() {
        super.init()
    }

    // Setup video for a URL using HLSVideoCache
    func setupVideoFor(url: String) {
        guard let originalURL = URL(string: url),
              let proxyURL = HLSVideoCache.shared.reverseProxyURL(from: originalURL) else {
            print("Invalid URL or unable to create reverse proxy URL")
            return
        }

        // Load asset and create AVPlayer
        let asset = AVURLAsset(url: proxyURL)
        let requestedKeys = ["playable"]

        asset.loadValuesAsynchronously(forKeys: requestedKeys) { [weak self] in
            guard let self = self else { return }

            var error: NSError?
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                let player = AVPlayer()
                let item = AVPlayerItem(asset: asset)

                DispatchQueue.main.async {
                    // Try to play the video again in case playVideo was already called
                    if self.videoURL == url, let layer = self.currentLayer {
                        self.playVideo(withLayer: layer, url: url, player: player, playerItem: item)
                    }
                }

            case .failed, .cancelled:
                print("Failed to load asset for URL: \(url)")
                return

            default:
                print("Unknown asset loading state")
                return
            }
        }
    }

    func playVideo(withLayer layer: AVPlayerLayer, url: String, player: AVPlayer, playerItem: AVPlayerItem) {
        videoURL = url
        currentLayer = layer

        // Assign player and item to the layer
        layer.player = player
        player.replaceCurrentItem(with: playerItem)

        // Play the video
        player.playImmediately(atRate: 1)

        NotificationCenter.default.post(name: Notification.Name("STARTED_PLAYING"),
                                        object: nil,
                                        userInfo: nil)
    }

    func removeLayerFor(cell: PlayVideoLayerContainer) {
        if let url = cell.videoURL {
            removeFromSuperLayer(layer: cell.videoLayer, url: url)
        }
    }

    private func removeFromSuperLayer(layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        layer.player?.pause()
        layer.player = nil
    }
    
    /*
     Play UITableViewCell's videoplayer that has max visible video layer height
     when the scroll stops.
     */
    func pausePlayeVideosFor(tableView: UITableView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = tableView.visibleCells
        var videoCellContainer: PlayVideoLayerContainer?
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? PlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                videoCellContainer = containerCell
            }
            removeFromSuperLayer(layer: containerCell.videoLayer, url: videoCellURL)
        }
        guard let videoCell = videoCellContainer,
            let videoCellURL = videoCell.videoURL else {
            return
        }
        let minCellLayerHeight = videoCell.videoLayer.bounds.size.height * 0.5
        /*
         Visible video layer height should be at least more than max of predefined minimum height and
         cell's videolayer's 50% height to play video.
         */
        let minimumVideoLayerVisibleHeight = max(minCellLayerHeight, minimumLayerHeightToPlay)
        if maxHeight > minimumVideoLayerVisibleHeight {
            if appEnteredFromBackground {
                setupVideoFor(url: videoCellURL)
            } else {
                guard let originalURL = URL(string: videoCellURL),
                      let proxyURL = HLSVideoCache.shared.reverseProxyURL(from: originalURL) else {
                    print("Invalid URL or reverse proxy failed")
                    return
                }

                let player = AVPlayer()
                let item = AVPlayerItem(url: proxyURL)
                playVideo(withLayer: videoCell.videoLayer, url: videoCellURL, player: player, playerItem: item)
            }
        }
    }
}
