//
//  Presenter.swift
//  TikTok Video Feed Swift
//
//  Created by Cedan Misquith on 19/10/22.
//

import Foundation

protocol PresenterProtocol: AnyObject {
    func refresh()
}

struct VideoObject {
    var videoURL: String
    var thumbnailURL: String
    var title: String
    var videoDescription: String
    init(videoURL: String, thumbnailURL: String, title: String, videoDescription: String) {
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.title = title
        self.videoDescription = videoDescription
    }
}

class Presenter: NSObject {
    var videos: [VideoObject] = [
        VideoObject.init(
               videoURL: "https://vod04-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/Galanhacviet2023NamQuaDaLamGi_Moments_1080p/index.smil/playlist.m3u8?st=0qMPsGv-xvDdzQpVTS6FLw&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/1/5616/3744",
               title: "Video 01",
               videoDescription: "This is a description for video 01"
           ),
           VideoObject.init(
               videoURL: "https://vod01-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/100036768_ChilbongToTinhVoiNaJungTruocThemNamMoi_Moments_1080p/index.smil/playlist.m3u8?st=iUx00DYm_4_m4nTSXCDsfQ&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/2/5616/3744",
               title: "Video 02",
               videoDescription: "This is a description for video 02"
           ),
           VideoObject.init(
               videoURL: "https://vod07-cdn.fptplay.net/POVOD/encoded/2024/12/16/imobsessedwithmybosspartii-2024-au-b-50t-trailer-1734323214/H264/master.m3u8?st=V1vP3h9ZbSzKdDVFgQ53iA&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/3/5616/3744",
               title: "Video 03",
               videoDescription: "This is a description for video 03"
           ),
           VideoObject.init(
               videoURL: "https://vod03-cdn.fptplay.net/POVOD/encoded/2024/12/23/nevermesswithabadassgirl-2023-au-trailer-1734894948/H264/master.m3u8?st=Az9mqyslIodt4cMVD8bfUw&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/4/5616/3744",
               title: "Video 04",
               videoDescription: "This is a description for video 04"
           ),
           VideoObject.init(
               videoURL: "https://vod05-cdn.fptplay.net/POVOD/encoded/2024/12/19/sistershavecrushonthesameman-2023-au-b-50t-trailer-1734580287/H264/master.m3u8?st=A95x_VkS7p90gAK13XXZSw&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/5/5616/3744",
               title: "Video 05",
               videoDescription: "This is a description for video 05"
           ),
           VideoObject.init(
               videoURL: "https://vod01-cdn.fptplay.net/POVOD/encoded/2024/12/24/nytdn-tuandungbanhighnote-moments-1080p-1735027023/H264/master.m3u8?st=5ZxIYPCzopAMplvgOSBDsA&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/6/5616/3744",
               title: "Video 06",
               videoDescription: "This is a description for video 06"
           ),
           VideoObject.init(
               videoURL: "https://vod01-cdn.fptplay.net/POVOD/encoded/2024/12/17/onenightstand-2023-au-b-50t-1734445143/H264/master.m3u8?st=EdPAlI5Dk9Yzk0o4hVa3Kg&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/7/5616/3744",
               title: "Video 07",
               videoDescription: "This is a description for video 07"
           ),
           VideoObject.init(
               videoURL: "https://vod03-cdn.fptplay.net/POVOD/encoded/2024/12/15/echoesofvengeance-2023-au-trailer-1734263466/H264/master.m3u8?st=cBBg0I7SEqex0Pl_EAwxZw&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/8/5616/3744",
               title: "Video 08",
               videoDescription: "This is a description for video 08"
           ),
           VideoObject.init(
               videoURL: "https://vod06-cdn.fptplay.net/POVOD/encoded/2024/12/23/mysisterstolemyman-2023-au-b-50t-trailer-1734937554/H264/master.m3u8?st=f8SXwvmnB2uwpvddGoRJrg&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/9/5616/3744",
               title: "Video 09",
               videoDescription: "This is a description for video 09"
           ),
           VideoObject.init(
               videoURL: "https://vod03-cdn.fptplay.net/POVOD/encoded/2024/12/24/nytdn-monquacuoicungphuonglantangphandat-moments-1080p-1735030102/H264/master.m3u8?st=MJgrUUxJM7stRdSrMVYplA&expires=1735198204",
               thumbnailURL: "https://picsum.photos/id/10/5616/3744",
               title: "Video 10",
               videoDescription: "This is a description for video 10"
           )
    ]
    weak var delegate: PresenterProtocol?
    init(delegate: PresenterProtocol) {
        self.delegate = delegate
    }
}
