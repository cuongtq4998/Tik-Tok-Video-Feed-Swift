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

@objc public class PKTimeRange: NSObject {
    @objc public let start: TimeInterval
    @objc public let end: TimeInterval
    @objc public let duration: TimeInterval
    
    @objc public override var description: String {
        return "[\(String(describing: type(of: self)))] - start: \(self.start), end: \(self.end), duration: \(self.duration)"
    }
    
    init(start: TimeInterval, duration: TimeInterval) {
        self.start = start
        self.duration = duration
        self.end = start + duration
    }
    
    convenience init(timeRange: CMTimeRange) {
        let start = CMTimeGetSeconds(timeRange.start)
        let duration = CMTimeGetSeconds(timeRange.duration)
        self.init(start: start, duration: duration)
    }
}


extension VideoPlayerController {
    @objc var currentItem: AVPlayerItem? {
        return currentPlayer?.currentItem
    }
    
    public var loadedTimeRanges: [PKTimeRange]? {
        return currentItem?.loadedTimeRanges.map { PKTimeRange(timeRange: $0.timeRangeValue) }
    }
    
    var duration: TimeInterval {
        guard let playerItem = currentItem else { return 0 }
        return playerItem.duration.seconds
    }
    
    public var bufferedTime: TimeInterval {
        guard let playerItem = currentItem else { return 0 }
        
        if let loadedTimeRanges = self.loadedTimeRanges {
            for timeRange in loadedTimeRanges {
                if playerItem.currentTime().seconds.isLess(than: timeRange.end) {
                    return timeRange.end
                }
            }
        }
        
        return playerItem.currentTime().seconds
    }
}

func printShort(_ string: String) {
    print("➡️➡️➡️➡️➡️➡️: \(string)")
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
    var currentLayer: AVPlayerLayer?
    @objc var currentPlayer: AVPlayer?
    
    private var isAddObserver:Bool = false
    static private var observerContext = 0
    private var observedKeyPaths: [String] {
        return [
            #keyPath(currentItem.status),
            #keyPath(currentItem.status),
            #keyPath(currentItem.isPlaybackLikelyToKeepUp),
            #keyPath(currentItem.isPlaybackBufferEmpty),
            #keyPath(currentItem.isPlaybackBufferFull),
        ]
    }
    
    let notificationCenter: NotificationCenter = NotificationCenter.default
    public func addObservers() {
        
        for keyPath in observedKeyPaths {
            addObserver(self, forKeyPath: keyPath, options: [.new, .initial], context: &VideoPlayerController.observerContext)
        }
        
        
        isAddObserver = true
    }

    public func removeObservers() {
        guard isAddObserver else {return}
        isAddObserver = false
        for keyPath in observedKeyPaths {
            removeObserver(self, forKeyPath: keyPath, context: &VideoPlayerController.observerContext)
        }
        
        notificationCenter.removeObserver(self)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &VideoPlayerController.observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
        case #keyPath(currentItem.status):
            guard let statusChange = change?[.newKey] as? NSNumber, let newPlayerStatus = AVPlayer.Status(rawValue: statusChange.intValue) else {
                printShort("unknown player status")
                return
            }
            if newPlayerStatus == .readyToPlay {
                printShort("player is ready to play player items")
            } else {
                printShort("player is failed/unknown to play player items")
            }
            
        case #keyPath(currentItem.status):
            guard let statusChange = change?[.newKey] as? NSNumber, let newPlayerItemStatus = AVPlayerItem.Status(rawValue: statusChange.intValue) else {
                printShort("unknown player item status")
                return
            }
            if newPlayerItemStatus == .readyToPlay {
                printShort("player item is .readyToPlay")
            } else if newPlayerItemStatus == .failed {
                printShort("player item is .failed")
            } else {
                //llog("currentItem is unknown")
            }
            
        case #keyPath(currentItem.isPlaybackLikelyToKeepUp):
            guard let isPlaybackLikelyToKeepUp = currentItem?.isPlaybackLikelyToKeepUp else { return }
            if (isPlaybackLikelyToKeepUp) {
                
            }
            
        case #keyPath(currentItem.isPlaybackBufferEmpty):
            guard let isPlaybackBufferEmpty = currentItem?.isPlaybackBufferEmpty else { return }
            if (isPlaybackBufferEmpty) {
                printShort("player item is isPlaybackBufferEmpty")
            }
            
        case #keyPath(currentItem.isPlaybackBufferFull):
            guard let isPlaybackBufferFull = currentItem?.isPlaybackBufferFull else { return }
            if (isPlaybackBufferFull) {
                printShort("player item is isPlaybackBufferFull")
            }
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override init() {
        super.init()
        addObservers()
    }
    
    deinit {
        removeObservers()
    }

    // Setup video for a URL using HLSVideoCache
    func setupVideoFor(url: String) {
        guard let originalURL = URL(string: url),
              let proxyURL = HLSVideoCache.shared.reverseProxyURL(from: originalURL) else {
            printShort("Invalid URL or unable to create reverse proxy URL")
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
                printShort("Failed to load asset for URL: \(url)")
                return

            default:
                printShort("Unknown asset loading state")
                return
            }
        }
    }

    func playVideo(withLayer layer: AVPlayerLayer, url: String, player: AVPlayer, playerItem: AVPlayerItem) {
        videoURL = url
        currentLayer = layer
        currentPlayer = player

        // Assign player and item to the layer
        layer.player = player
        player.replaceCurrentItem(with: playerItem)

        // Play the video
        player.playImmediately(atRate: 1)

        NotificationCenter.default.post(name: Notification.Name("STARTED_PLAYING"),
                                        object: nil,
                                        userInfo: nil)
        
        
        addObservers()
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
                    printShort("Invalid URL or reverse proxy failed")
                    return
                }

                let player = AVPlayer()
                let item = AVPlayerItem(url: proxyURL)
                playVideo(withLayer: videoCell.videoLayer, url: videoCellURL, player: player, playerItem: item)
            }
        }
    }
}
