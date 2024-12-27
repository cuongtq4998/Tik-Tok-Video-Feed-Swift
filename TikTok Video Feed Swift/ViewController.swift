//
//  ViewController.swift
//  TikTok Video Feed Swift
//
//  Created by Cedan Misquith on 19/10/22.
//

import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var clearCache: UIButton!
    @IBAction func clearCacheTrigger(_ sender: Any) {
        do {
            try HLSVideoCache.shared.clearCache()
            showToast(message: "Cache Cleared OK")
        }catch {
            print("Error in clearing cache")
        }
    }
    
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topGradientImageView: UIImageView!
    var presenter: Presenter!
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = Presenter(delegate: self)
        configureGradients()
        configureTableView()
        DispatchQueue.main.async {
            VideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: self.tableView)
        }
        
        addObserverState()
        
        VideoPlayerController.sharedVideoPlayer.timeHandler = { [weak self] timeData in
            guard let self = self else { return }
            
            
            var timeAttributes = ["─ Debug ─",
                                    "bufferTime: \(timeData.bufferedTime.timeIntervalString)" + ", current: \(timeData.currentTime.timeIntervalString)" + ", duration: \(timeData.durationTime.timeIntervalString)"
            ]
            
            if let orginalURL = timeData.videoURL, let url = URL(string: orginalURL) {
                let originalURLCache = HLSVideoCache.shared.reverseProxyURL(from: url)
                timeAttributes.append(originalURLCache?.absoluteString ?? "")
            }
            
            let debugTime = timeAttributes.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.debugLabel.text = debugTime
            }
            
        }
    }
    fileprivate func configureGradients() {
        let topGradient = Utilities.shared.createGradient(color1: UIColor.black.withAlphaComponent(0.7),
                                         color2: UIColor.black.withAlphaComponent(0.0),
                                         frame: topGradientImageView.bounds)
        
        topGradientImageView.contentMode = .scaleAspectFill
        topGradientImageView.image = topGradient
    }
    fileprivate func configureTableView() {
        tableView.alwaysBounceVertical = true
        tableView.isPagingEnabled = true
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UINib(nibName: "VideoCustomCell", bundle: nil),
                           forCellReuseIdentifier: "VideoCustomCell")
    }
    
    
    func addObserverState(){
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc internal func appCameToForeground() {
        VideoPlayerController.sharedVideoPlayer.resumeCurrentItem()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.videos.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCustomCell") as? VideoCustomCell else {
            return UITableViewCell()
        }
        cell.configureCell(data: presenter.videos[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? PlayVideoLayerContainer {
            if videoCell.videoURL != nil {
                VideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollEnd()
    }
    
    private func handleScrollEnd() {
        VideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: self.tableView)
    }
}
extension ViewController: PresenterProtocol {
    func refresh() {
    }
}

extension UIViewController{
    func showToast(message : String, seconds: Double = 0.1){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}
