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
            videoURL: "https://vod03-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/NgocMaiTruyenCamHungDeKhanGiaBietTonVinhNhungNgheSiChanChinh_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735227640/cdn-tiktok/playlist_frame_0_mar2hd.jpg",
            title: "Video 01",
            videoDescription: "This is a description for video 01"
        ),
        VideoObject.init(
            videoURL: "https://vod03-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/LoiRa_QuangMinhChuaMuonAiThayTheHongDao_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735262887/cdn-tiktok/playlist_frame_11_pmiu8l.jpg",
            title: "Video 02",
            videoDescription: "This is a description for video 02"
        ),
        VideoObject.init(
            videoURL: "https://vod05-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/LoiRa_MotCoGaiKhaLaNamTinh_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735262886/cdn-tiktok/playlist_frame_13_ldf8fd.jpg",
            title: "Video 03",
            videoDescription: "This is a description for video 03"
        ),
        VideoObject.init(
            videoURL: "https://vod05-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/GiaoLoThoiGianSo22ThanhPhoSuongTuanNgoc_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735262886/cdn-tiktok/playlist_frame_15_kxh4r8.jpg",
            title: "Video 04",
            videoDescription: "This is a description for video 04"
        ),
        VideoObject.init(
            videoURL: "https://vod04-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/100076085_HonChienTrongCanNhaHoang_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735262887/cdn-tiktok/playlist_frame_16_osbikc.jpg",
            title: "Video 05",
            videoDescription: "This is a description for video 05"
        ),
        VideoObject.init(
            videoURL: "https://vod05-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/BienCuaHyVongNguoiYeuCuTienCookie_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735262886/cdn-tiktok/playlist_frame_10_f6tulf.jpg",
            title: "Video 05",
            videoDescription: "This is a description for video 05"
        ),
        VideoObject.init(
            videoURL: "https://vod05-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/MusicHomeMua2So3ConCoTungDuong_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735262886/cdn-tiktok/playlist_frame_8_ljyh5m.jpg",
            title: "Video 05",
            videoDescription: "This is a description for video 05"
        ),
        VideoObject.init(
            videoURL: "https://vod05-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/100101099_NoiXauNguoiTaTrenMangXaHoiVaCaiKet_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735227640/cdn-tiktok/playlist_frame_6_vzapdu.jpg",
            title: "Video 05",
            videoDescription: "This is a description for video 05"
        ),
        VideoObject.init(
            videoURL: "https://vod02-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/SWF2_KirstenKhongPhaiDangVuaDau_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735227640/cdn-tiktok/playlist_frame_5_cvajyu.jpg",
            title: "Video 05",
            videoDescription: "This is a description for video 05"
        ),
        VideoObject.init(
            videoURL: "https://vod05-cdn.fptplay.net/ovod/_definst_/smil:mp4/encoded/moments/100059952_ChiNhinThayBeMatKhongCoNghiaLaHieuRoVeNo_Moments_1080p/index.smil/playlist.m3u8",
            thumbnailURL: "https://res.cloudinary.com/myrealestate/image/upload/v1735227639/cdn-tiktok/playlist_frame_4_wcyt9x.jpg",
            title: "Video 05",
            videoDescription: "This is a description for video 05"
        ),
    ]
    weak var delegate: PresenterProtocol?
    init(delegate: PresenterProtocol) {
        self.delegate = delegate
    }
}
