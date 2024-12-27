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
    var minimumLayerHeightToPlay: CGFloat = 0
    var mute = false
    var preferredPeakBitRate: Double = 10_000 // 10 Kbps
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
    
    struct TimeDataModel {
        let currentTime: Double
        let durationTime: Double
        let bufferedTime: Double
        let videoURL: String?
    }
    
    var timeHandler: ((TimeDataModel) -> Void)?
    
    var currentTime: Double {
        let time = currentPlayer?.currentTime() ?? .zero
        if CMTIME_IS_VALID(time) && !CMTIME_IS_INDEFINITE(time) {
            return CMTimeGetSeconds(time)
        } else {
            return 0.0
        }
    }
    
    var durationTime: Double {
        guard let currentItem = currentPlayer?.currentItem else { return 0.0 }
        
        let duration = currentItem.duration
        if CMTIME_IS_VALID(duration) && !CMTIME_IS_INDEFINITE(duration) {
            return CMTimeGetSeconds(duration)
        } else {
            return 0.0
        }
    }
    
    func isValidTime(value: Double) -> Bool{
        return !value.isNaN && value != 0.0 && !value.isInfinite
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
        removeTimeObserver()
    }

    // Setup video for a URL using HLSVideoCache
    func setupVideoFor(url: String) {
        guard let originalURL = URL(string: url),
              let proxyURL = HLSVideoCache.shared.reverseProxyURL(from: originalURL) else {
            printShort("Invalid URL or unable to create reverse proxy URL")
            return
        }
        
        let player = AVPlayer()
        let item = AVPlayerItem(url: proxyURL)
        if self.videoURL == url, let layer = self.currentLayer {
            self.playVideo(withLayer: layer, url: url, player: player, playerItem: item)
        }
    }

    func playVideo(withLayer layer: AVPlayerLayer, url: String, player: AVPlayer, playerItem: AVPlayerItem) {
        videoURL = url
        currentLayer = layer
        
        if let currentPlayer = currentPlayer {
            currentPlayer.pause()
            currentPlayer.replaceCurrentItem(with: nil)
        } else {
            currentPlayer = player
        }
        
        // Assign player and item to the layer
        layer.player = currentPlayer == nil ? player : currentPlayer!
        currentPlayer!.replaceCurrentItem(with: playerItem)

        // Play the video
        currentPlayer!.playImmediately(atRate: 1)
        addTimeObserver()
        addObservers()
    }
    
    private var timeObserverToken: Any?
    func addTimeObserver() {
        // Ensure the observer is added only once
        guard timeObserverToken == nil else { return }
        
        let timeInterval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // Update every second
        timeObserverToken = currentPlayer?.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = self.currentTime
            let durationTime = self.durationTime
            let bufferedTime = bufferedTime
            
            let timeData = TimeDataModel(currentTime: currentTime, durationTime: durationTime, bufferedTime: bufferedTime, videoURL: videoURL)
            self.timeHandler?(timeData)
        }
    }
    
    func removeTimeObserver() {
        if let token = timeObserverToken {
            currentPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
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
        removeTimeObserver() // Remove time observer when stopping playback
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
                
                let player = currentPlayer ?? AVPlayer()
                let item = AVPlayerItem(url: proxyURL)
                playVideo(withLayer: videoCell.videoLayer, url: videoCellURL, player: player, playerItem: item)
            }
        }
    }
    
    func resumeCurrentItem() {
        currentPlayer?.play()
    }
}
