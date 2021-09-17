//
//  FeedVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo
import UIKit

class FeedVC: BaseVC, UITableViewDelegate {
    let dataSource = State<[Feed]>([])

    let type = State(true)

    func change() {
        type.value = !type.value
    }

    override func configView() {
        vRoot.attach {
            sequenceBox().attach($0)
                .visibility(type.map { $0.py_visibleOrGone() })
            recycleBox().attach($0)
                .visibility(type.map { $0.py_toggled().py_visibleOrGone() })
        }
    }

    func recycleBox() -> UIView {
        let this = WeakCatcher(value: self)
        return RecycleBox(
            sections: [
                RecycleSection<Void, Feed>(
                    items: dataSource.asOutput(),
                    cell: { o, _ in
                        ItemView().attach()
                            .viewState(o.map(\.data))
                            .width(.fill)
                            .bottomBorder([.color(UIColor.lightGray.withAlphaComponent(0.3)), .lead(20)])
                            .view
                    },
                    header: { _, _ in
                        Header().attach()
                            .onEvent { e in
                                switch e {
                                case .reload:
                                    this.value?.reload()
                                case .change:
                                    this.value?.change()
                                }
                            }
                            .view
                    },
                    footer: { _, _ in
                        VBox().attach {
                            UILabel().attach($0)
                                .text("It's ending")
                        }
                        .backgroundColor(UIColor.systemPink)
                        .padding(all: 16)
                        .width(.fill)
                        .justifyContent(.center)
                        .view
                    }
                )
            ].asOutput()
        )
        .attach()
        .backgroundColor(UIColor.white)
        .size(.fill, .fill)
        .view
    }

    func sequenceBox() -> UIView {
        let this = WeakCatcher(value: self)
        return SequenceBox(
            sections: [
                SequenceSection<Void, Feed>(
                    dataSource: dataSource.asOutput(),
                    cell: { o, _ in
                        ItemView().attach()
                            .viewState(o.map(\.data))
                            .width(.fill)
                            .view
                    }
                )
            ].asOutput(),
            header: {
                Header().attach()
                    .onEvent { e in
                        switch e {
                        case .reload:
                            this.value?.reload()
                        case .change:
                            this.value?.change()
                        }
                    }
                    .view
            },
            footer: {
                VBox().attach {
                    UILabel().attach($0)
                        .text("It's ending")
                }
                .backgroundColor(UIColor.systemPink)
                .padding(all: 16)
                .width(.fill)
                .justifyContent(.center)
                .view
            }
        )
        .attach()
        .setDelegate(self)
        .size(.fill, .fill)
        .view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }

    private func reload() {
        DispatchQueue.main.async {
            self.dataSource.value = (0 ..< 20).map { _ in
                Feed(icon: Images().get(), name: Names().get(), content: Contents().get(), images: Images().random(9), createdAt: Int(Date().timeIntervalSince1970), likes: Names().random(10), comments: Contents().random(10).map { "\(Names().get()): \($0)" })
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

struct Feed {
    var icon: String?
    var name: String?
    var content: String?
    var images: [String]?
    var createdAt: Int?
    var likes: [String]?
    var comments: [String]
}

private class Header: VBox, Eventable {
    enum Event {
        case reload
        case change
    }

    var eventProducer = SimpleIO<Event>()
    override func buildBody() {
        attach {
            UIImageView().attach($0)
                .image(Images().download())
                .size(.fill, 300)
                .contentMode(.scaleAspectFill)
                .clipToBounds(true)

            HBox().attach($0) {
                UILabel().attach($0)
                    .text("Jrwong")
                    .textColor(UIColor.white)
                    .fontSize(20, weight: .heavy)
                    .style(ShadowStyle())

                UIImageView().attach($0)
                    .image(Images().download())
                    .size(100, 100)
                    .cornerRadius(8)
            }
            .margin(top: -70, right: 40)
            .justifyContent(.center)
            .space(8)

            HBox().attach($0) {
                ZBox().attach($0) {
                    UILabel().attach($0)
                        .text("Refresh")
                        .textColor(UIColor.white)
                }
                .padding(all: 8)
                .cornerRadius(8)
                .backgroundColor(UIColor.black.withAlphaComponent(0.7))
                .width(.wrap(add: 20))
                .alignment(.center)
                .style(TapRippleStyle())
                .onTap(to: self) { this, _ in
                    this.emmit(.reload)
                }

                ZBox().attach($0) {
                    UILabel().attach($0)
                        .text("Change RecycleBox and SequenceBox")
                        .textColor(UIColor.white)
                }
                .padding(all: 8)
                .cornerRadius(8)
                .backgroundColor(UIColor.black.withAlphaComponent(0.7))
                .width(.wrap(add: 20))
                .alignment(.center)
                .style(TapRippleStyle())
                .onTap(to: self) { this, _ in
                    this.emmit(.change)
                }
            }
            .space(10)
            .alignment(.center)
        }
        .justifyContent(.right)
        .width(.fill)
    }
}

class ItemView: HBox, Stateful {
    var viewState = State<Feed>.unstable()

    override func buildBody() {
        attach {
            UIImageView().attach($0)
                .size(50, 50)
                .image(bind(\.icon).distinct().then { downloadImage(url: $0) })
                .cornerRadius(4)

            VBox().attach($0) {
                UILabel().attach($0)
                    .text(bind(\.name).distinct())
                    .fontSize(20, weight: .heavy)

                UILabel().attach($0)
                    .text(bind(\.content).distinct())
                    .numberOfLines(0)

                let images = bind(\.images).unwrap(or: [])

                VFlowRecycle<String>(
                    builder: { o, i in
                        UIImageView().attach()
                            .image(o.then { downloadImage(url: $0) })
                            .size(100, 100)
                            .userInteractionEnabled(true)
                            .onTap {
                                i.inContext { c in
                                    print(c.index)
                                }
                            }
                            .view
                    }
                )
                .attach($0)
                .arrangeCount(images.map { $0.count < 5 ? 2 : 3 }.distinct())
                .space(8)
                .viewState(images)
                .visibility(images.map { $0.isEmpty ? .gone : .visible })

                HBox().attach($0) {
                    UILabel().attach($0)
                        .text(bind(\.createdAt).map { Date(timeIntervalSince1970: Double($0 ?? 0)).description })

                    UIButton().attach($0)
                        .text("more")
                        .textColor(UIColor.lightGray)
                }
                .justifyContent(.center)
                .format(.between)
                .width(.fill)

                VBox().attach($0) {
                    let likes = bind(\.likes).unwrap(or: [])
                    let comments = bind(\.comments)

                    let likeVisible = likes.map { (!$0.isEmpty).py_visibleOrGone() }
                    let commentVisible = comments.map { (!$0.isEmpty).py_visibleOrGone() }

                    HBox().attach($0) {
                        UIImageView().attach($0)
                            .image(UIImage(systemName: "heart.fill"))
                            .margin(right: 8)

                        UILabel().attach($0)
                            .text(likes.map { $0.joined(separator: ", ") })
                    }
                    .justifyContent(.center)
                    .padding(all: 8)
                    .visibility(likeVisible)

                    UIView().attach($0)
                        .size(.fill, Util.pixel(1))
                        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.3))
                        .visibility(Outputs.combine(likeVisible, commentVisible).map { v1, v2 in
                            (v1 == .visible && v2 == .visible).py_visibleOrGone()
                        })

                    VBoxRecycle<String>(
                        builder: { o, i in
                            HBox().attach {
                                UILabel().attach($0)
                                    .text(o)
                                    .width(.fill)
                                    .userInteractionEnabled(true)
                            }
                            .padding(all: 8)
                            .width(.fill)
                            .onTap {
                                i.inContext { c in
                                    print(c.index)
                                    print(c.data)
                                }
                            }
                            .view
                        }
                    )
                    .attach($0)
                    .width(.fill)
                    .viewState(comments)
                    .visibility(commentVisible)
                }
                .backgroundColor(UIColor(hexString: "#F6F6F6"))
                .width(.fill)
                .visibility(output.map { f in
                    (!(f.comments.isEmpty && (f.likes ?? []).isEmpty)).py_visibleOrGone()
                })
            }
            .width(.fill)
            .space(8)
        }
        .padding(all: 16)
        .space(16)
        .width(.fill)
    }
}

func downloadImage(url: String?) -> Outputs<UIImage?> {
    return Outputs { i in
        if let URL = URL(string: url ?? "") {
            let task = URLSession.shared.downloadTask(with: URL) { u, _, _ in
                if let u = u, let data = try? Data(contentsOf: u) {
                    i.input(value: UIImage(data: data))
                } else {
                    i.input(value: nil)
                }
            }
            task.resume()
        } else {
            i.input(value: nil)
        }

        return Disposers.create()
    }
    .bind { o, i in
        DispatchQueue.main.async {
            i.input(value: o)
        }
    }
}

protocol RandomValues {
    associatedtype V
    var values: [V] { get }
}

extension RandomValues {
    func get() -> V {
        values[Int.random(in: 0 ..< values.count)]
    }

    func random(_ max: Int) -> [V] {
        (0 ..< Int.random(in: 0 ..< max)).map { _ in values[Int.random(in: 0 ..< values.count)] }
    }
}

struct Names: RandomValues {
    var values = [
        "John", "Tom", "Micheal", "Jrwong", "Scubers", "Fedex"
    ]
}

struct Contents: RandomValues {
    var values = [
        "对于很多人来说，西装一直都是很传统的服装，尽管在这个不断有新鲜血液融入到时尚的年代，西装似乎也没有摆脱原有的单调与沉闷感，还是会有人把它定义为“老土单品”。但是时尚从来没有停下探索的脚步，尽管你会把它框在狭小的空间里，但是随着潮流的不断变化，西装也开始被贴上新的标签，例如：精致、洒脱、有内涵与有腔调。不光是女生的西装发生变化，男生的西装似乎看起来会更加韵味，不拘小节还显得很沉稳，重点能够展现出男生该有的绅士魅力，看着也很大气。",
        "近日，有网友晒出在环球影城偶遇佟丽娅的照片，用叠字夸赞佟丽娅瘦、白、美，同时该网友回复评论，强调佟丽娅身边穿粉色外套的就是陈思诚。据悉，2021年5月20日，陈思诚佟丽娅在社交平台发文宣布离婚，佟丽娅生日当天，陈思诚还卡点送出祝福，这次是两人离婚以后的首次同框。 　　按照佟丽娅的蓝色毛衣配明黄色短裙造型，9月2日就有网友晒出在北京环球影城偶遇照片，佟丽娅则在9月4日晒出一组环球影城游客照",
        "有媒体拍到张继科与一美女聚会后送女方回家，疑似新恋情曝光。 9月6日，张继科工作室发文辟谣了恋情：“爆料是假，恋情也是假，小室呼吁大家文明理性上网，不信谣不传谣。”同时也向大家保证如果今后真的有好消息，一定会和大家一起分享喜悦。",
        "粉丝们看到辟谣后反倒不淡定了，纷纷表示希望张继科可以赶紧找到自己的幸福：“收到，期待哥遇见自己真命天女的那一天啊！”“不该加入催婚大队，但是希望哥哥可以赶紧找到自己的幸福呀！”",
        "时隔2个月她再度公开恋情，秀出倚靠在新男友肩头的亲密互动，不过不久后她把IG照片全清空，关于恋情的发文也全都消失。",
        "权珉娥昨（3）日在IG公开倚靠着一位男子的合照，她写下“不久前开始交往，现在遇见不错的人，也认真地在工作。”另外一张照片中虽然有3人，但她蜷曲在新男友的怀里，显得相当幸福。",
        "生日快乐",
        "寿比南山",
        "新浪娱乐讯 9月5日，所属社Maroo发表公告，GHOST9成员黄栋俊、李兑昇经过与公司长时间的讨论决定退出组合活动，将不影响组合回归准备。"
    ]
}

struct Images: RandomValues {
    func download() -> Outputs<UIImage?> {
        downloadImage(url: get())
    }

    let values = [
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20171221%2F2a14e6b09df846a1908379c06045ba96.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=b72763232c581a611d7cc913047dc0d1",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201710%2F24%2F20171024071632_hzJ8n.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=7e16f80814a403848fba59bafab77654",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201812%2F27%2F20181227101820_tqdsl.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=589881f015d27769ca388ae8bc059da0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201803%2F17%2F20180317233658_dR4s2.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=5c04ea3b91c9dc08ab1d9d703ba23e53",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F27%2F20150927200243_YmaQB.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=369b644e3f213edc85c09702ba35e3f9",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201502%2F14%2F20150214112415_V8Qde.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=d75d73ece78d0e1c5c1c7c5648731a60",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201507%2F27%2F20150727163929_cdkCx.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=843ba8f0a2db111d970360f1ee9ac4df",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201807%2F29%2F20180729101646_emixn.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=a424d68e1280e319f50e97e9c6a24cda",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201805%2F07%2F20180507190841_rjvvo.jpg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=5a687b0a2d4f0044467f53498ab79955",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201704%2F02%2F20170402192733_dhUeY.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=15b00f1940f2eb304d305ef7ce0f1f75",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa-ssl.duitang.com%2Fuploads%2Fitem%2F201505%2F19%2F20150519233153_CAvFt.jpeg&amp;refer=http%3A%2F%2Fa-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=1016b154be067973e4dead913e881c98",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F02%2F20150902212827_V2Qyk.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=5c32102a86e52dc62f9848bfb5857c35",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20171221%2F7951c4f37ee948a2a1fb1f662a1b2feb.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=39347360c11dadaa990e20319934b50f",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201702%2F14%2F20170214234505_Rtjcz.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=9fd3be9dfbbf32efa98b33fe91636959",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F17%2F20150917091946_RHXBh.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=1e52d535bfa1475bafd5b44e641e951a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201512%2F05%2F20151205155108_tXrxZ.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=cc5563240d9a4a95a35cc89965af48b7",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201506%2F28%2F20150628201339_k4ws3.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=32a72002a8ac9671a32f8d91e28fbc56",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201309%2F26%2F20130926095128_SiPMh.jpeg&amp;refer=http%3A%2F%2Fcdn.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=53cfc28cc9d87d1f7c6831eaeb7da301",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F22%2F20150922193950_KC35P.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=2773434806094ac24177cb7e01288fab",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20180124%2F0247a1cd9f044116a69c4a9897082027.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=6e62d2ad9a26db5d7e84b75b46da9502",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F18%2F20150818213048_vAdhz.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=3828df6720781b39f4ca4d9082e75c14",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201603%2F19%2F20160319134314_aeAjE.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=c062f89669d8c73ab13e642caf66eccc",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F13%2F20150913102840_nXhdL.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=f3f7ddc2c34cbb5f117e09c286953517",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201511%2F04%2F20151104080435_YsWjm.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=b9f836e083c70e43d195b24fd4434d78",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201704%2F08%2F20170408194023_3Lj5H.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=338251aa35f478fd6c9a0d86e69983f9",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F18%2F20150918185207_KVACt.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=90f9d4af54d73c574f1b3db67da03a4b",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20170722%2F1bf55888ea3648efb8235c6aee50abb3.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=5d796d59979eca9f0fbab60ea7c76d45",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F18%2F20151018150210_GShuF.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=aa583d81bf276d6caf1cc05d48a33b7a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F25%2F20150925100041_twrfj.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=3788050d3329186d8f98a0ccf5df5aa2",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F24%2F20151024135601_kzNhx.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=0f0881bdd36e28784ef761daefd2693e",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201509%2F22%2F20150922121054_5PyBN.jpeg&amp;refer=http%3A%2F%2Fimg3.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=b6b477c417dacfdd746926b745761c2f",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20190117%2F561b9f9b2fe04d39bfa2151d142d3d42.jpg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=2c476136370d1066e2d9a1ebdc74a0b8",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201408%2F09%2F20140809230820_VvjBe.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fcdn.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=9ff2e08f9bd5256cc29b06183c0c0c77",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201805%2F05%2F20180505182342_wwdki.jpg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=1deb680b38f4a41eaae8b4396705fecf",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F31%2F20151031195151_rtLCM.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=bb6ecd08a882d85a28d2683d85398eb4",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201901%2F26%2F20190126012851_sxvbw.jpg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=a44c05fe3081d9b365f823d4095ea643",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F16%2F20161016183333_5jurS.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=934eb756d8664fb437b79fc8ddac18d6",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201409%2F18%2F20140918001748_CM53y.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=9ee52e8455f07053b1c1e2c297240cfe",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa-ssl.duitang.com%2Fuploads%2Fitem%2F201609%2F17%2F20160917035102_hEuy3.thumb.700_0.png&amp;refer=http%3A%2F%2Fa-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=94e34f86f39fed3bc846d33b3592af5c",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F2b.zol-img.com.cn%2Fproduct%2F108_1200x900%2F201%2FcetEhlzWrJoT2.gif&amp;refer=http%3A%2F%2F2b.zol-img.com.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=08d22120ecde532f05335372502823e9",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F31%2F20151031190344_Rezuv.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=c2819f62fd5b1120e9a9f0865d698184",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201804%2F09%2F20180409125847_qyjvc.jpg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=6d3b55b1f79b96d3bedded46f05c14a5",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F14%2F20151014200219_fe4sR.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=b08433d5517aa710fd442792f3f37847",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F04%2F20150904110552_vHmGS.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=e0cf4156336ec1951051c812d025b108",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201804%2F23%2F20180423181203_duwqk.jpg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=d16c6bc7529401f4bde3fbe27dbc8e4d",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201508%2F26%2F20150826162423_JnfSE.jpeg&amp;refer=http%3A%2F%2Fcdn.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=184abe2d7f5e407ad5a89ad0dd384536",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa-ssl.duitang.com%2Fuploads%2Fitem%2F201506%2F09%2F20150609135553_yWVS2.jpeg&amp;refer=http%3A%2F%2Fa-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=60a79d37089cd714b9e97e8e952d027f",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F13%2F20150813231915_uPsrw.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=bcbf96a17ecd9b2fb4d4ed4a72cb1486",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201602%2F10%2F20160210075340_KyBCF.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=aa42b945e6860f86b28615a38548f87a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201802%2F12%2F20180212223628_XUH4f.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=b74ad560020f09e35151d4d1666eb4d8",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F04%2F20161004161302_VreQT.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=62ac6c7812152c72314ceab0284bf747",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201812%2F31%2F20181231010435_scjtm.png&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=d52fa5a264d06bae2d5175fe07061472",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201410%2F30%2F20141030044137_GmwsS.jpeg&amp;refer=http%3A%2F%2Fcdn.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=3bca720e91c21ad61580570872b8eece",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201503%2F06%2F20150306002239_wF5tx.jpeg&amp;refer=http%3A%2F%2Fcdn.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=4f89d1b00e6a504b66c0854b7682dc6a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F28%2F20150928101603_m2WFA.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=ba0dbfc63c7052d74d461071881851ea",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F04%2F20151004123955_tvKaR.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=874ff9539ee4dd6b1a7e6d1f03a87e2f",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201111%2F23%2F2141464yp2dz68ybjp46p8.jpg&amp;refer=http%3A%2F%2Fattach.bbs.miui.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=26e7a8b04d14b8768534fe520a7dafea",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F02%2F20150802170710_iNCUw.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=349572ffc21a28673936e7d5338c96a1",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20170828%2F46d45098e1364ca88949d982ea7219f1.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=4486cf1b67cfb7699634946e6ab233d9",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F21%2F20150921173512_PehaH.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=b1d5705b7378a732b5c7adf257a189a0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201611%2F07%2F20161107111904_XtWk5.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=c05592b342a381069b79c9508b023cf0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa-ssl.duitang.com%2Fuploads%2Fitem%2F201901%2F11%2F20190111111418_ntkvt.jpeg&amp;refer=http%3A%2F%2Fa-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=7607ce9b83ac8fe7e6cd62b8f59e2601",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201608%2F11%2F20160811150336_fkwyh.thumb.700_0.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=750ae6eafaaeb4b93b97646b9f472873",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201609%2F15%2F20160915090905_cCyEu.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=d45b032e9e440c2f464bd5954963c52e",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fblog%2F201405%2F03%2F20140503140453_Bz3Tt.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=f1d678071e0b3da9ceb1b984167675ca",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201702%2F06%2F20170206140005_uM2XQ.jpeg&amp;refer=http%3A%2F%2Fb-ssl.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=f03de07bd97c7d1ed646217a260b5904",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20180203%2Feb7a1bb7d5d64ea59c35f095ad0bf67b.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=347b65507b5c8071115a952fc3d19f97",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww2.sinaimg.cn%2Fmw690%2F006IV4YMgy1gssxs8pknij30qo0qoq4p.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=3385f7cc01e3ca4f85bf4530b8eafa15",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F006WjMqXgy1gss9xh6nblj30n00n0gna.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=c404d74e67d99dbbb3427ada56e75966",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F006IV4YMgy1gtm0zq3m3tj60n00mrt9h02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=bcd2d432bbbd7addf1c6074a926082e4",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F90440ed7ly1godn3dwmk0j21kw1kwb29.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=e151fcc0e637dc8c50db64aa53f06ca5",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww3.sinaimg.cn%2Fmw690%2F001VEnKKgy1gtd82ek9kzj60u00u0gnn02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=297270ed6219e5cd6f23c4c8e9c84480",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F006yaFLbly1gsuob3jyprj30zi0zkh60.jpg&amp;refer=http%3A%2F%2Fwx2.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=e3f7b3491588611cb3853465dc626d50",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx1.sinaimg.cn%2Fmw690%2F99a32133gy1gsweyt297rj21be1bekct.jpg&amp;refer=http%3A%2F%2Fwx1.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=80763b00f39ced7febec83ba3459cb77",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fnimg.ws.126.net%2F%3Furl%3Dhttp%253A%252F%252Fdingyue.ws.126.net%252F2021%252F0820%252Fbb7790d5j00qy47xp000od200b000azg00430042.jpg%26thumbnail%3D650x2147483647%26quality%3D80%26type%3Djpg&amp;refer=http%3A%2F%2Fnimg.ws.126.net&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=6980649eea7e3817db12ca99fe6f5018",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F006IV4YMgy1gthfysat05j60u00u0tan02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=b1dd7d690c502f28dd2141428145e87d",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww2.sinaimg.cn%2Fmw690%2F006IV4YMgy1gssxsbfnh7j30qo0qodh3.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=cd76a65a4ddd36ff08b9e842923e408f",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F006IV4YMgy1gtl5l1glbbj60u00u075x02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=ed69e4269395c5768e9f2f926b3800f3",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww2.sinaimg.cn%2Fmw690%2F006IV4YMgy1gtl5kyahbcj60u00u0abf02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=c430155f27d43623f65ebf1209f6f256",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fnimg.ws.126.net%2F%3Furl%3Dhttp%253A%252F%252Fdingyue.ws.126.net%252F2021%252F0823%252F60ecc1b8p00qy9xub000bc000650064c.png%26thumbnail%3D650x2147483647%26quality%3D80%26type%3Djpg&amp;refer=http%3A%2F%2Fnimg.ws.126.net&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=1e51c2d7dbfd8e0e89e7f2a88e64d6c5",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww1.sinaimg.cn%2Fmw690%2F0066cjg4ly1gt9j1hxebxj30u00u0441.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=c14ccc3fa2ebafc7f60ffe1b66ea0d49",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F007ZVs3Jgy1gsvkf8qjihj31kw1kwthm.jpg&amp;refer=http%3A%2F%2Fwx2.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=345dc07ebcb4c98bacacdeeeb94a0729",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww1.sinaimg.cn%2Fmw690%2F006IV4YMgy1gtl5l8paauj60u00u40ue02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=047ce0d6810f1c6f5423125b54ae8087",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F007ZVs3Jgy1gsvkfa2jcmj31kw1kwtfk.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=fe20e4e0a4e25b7383baab3a4c471e1f",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx1.sinaimg.cn%2Fmw690%2F8150acbdly1gtsv0rr6zxj20u00u0gp4.jpg&amp;refer=http%3A%2F%2Fwx1.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=03640f5697c577d8c937ec9d40dcf5cb",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.zhimg.com%2Fv2-4a1c5772df7a52b5f5772177327bc3eb_r.jpg%3Fsource%3D1940ef5c&amp;refer=http%3A%2F%2Fpic1.zhimg.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=28af0ebb86ec356218431ee94adcdb81",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww1.sinaimg.cn%2Fmw690%2F006yaFLbly1gsuoavu1ymj30zk0zi1g3.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=0f69e0993ff02ff75d93c6b8a10bed1a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx4.sinaimg.cn%2Fmw690%2F001VEnKKgy1gtfc78kuzoj60u00v477202.jpg&amp;refer=http%3A%2F%2Fwx4.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=fd3b81e88256fba80a50fccdf356ed71",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F006IV4YMgy1gtfklp9ia8j60mv0mumyw02.jpg&amp;refer=http%3A%2F%2Fwx2.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=3e20f25a69c4a55fbc73b737921373b8",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F006IV4YMgy1gsupw3rdy3j30zo0zfgof.jpg&amp;refer=http%3A%2F%2Fwx2.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=772c0587b3a236e294c692fa0e330154",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F006IV4YMgy1gsupw3rdy3j30zo0zfgof.jpg&amp;refer=http%3A%2F%2Fwx2.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=772c0587b3a236e294c692fa0e330154",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww2.sinaimg.cn%2Fmw690%2F006WjMqXgy1gss9xhnbq5j30tz0toq5i.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=9a974ade26f0dcd97306253d7ce623d7",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx3.sinaimg.cn%2Fmw690%2F006WjMqXgy1gss9xeg5ynj30u00u0tal.jpg&amp;refer=http%3A%2F%2Fwx3.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=4cc47d26f549c51c5bbf8494b9ad7bd0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx4.sinaimg.cn%2Fmw690%2F90440ed7ly1godn3jr84sj21kw1kwh2t.jpg&amp;refer=http%3A%2F%2Fwx4.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=ac38642170ce211956ceb4ff421f02d6",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx3.sinaimg.cn%2Fmw690%2F006yaFLbly1gsuoaxn4a7j30zk0ziqos.jpg&amp;refer=http%3A%2F%2Fwx3.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=dc2d13ba9bd1b3f18e6ee4c2a1121bdb",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww3.sinaimg.cn%2Fmw690%2F006WjMqXgy1gss9xgtpuqj30tw0tw0ub.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=318be82c2de5707d00df120cdbc61d65",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx4.sinaimg.cn%2Fmw690%2F001SCD0oly1gt6xzd61mlj61tm1tm42502.jpg&amp;refer=http%3A%2F%2Fwx4.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=db978e2d7d9a8c92f0a5a6889e325941",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201511%2F08%2F20151108061853_iU3Zd.jpeg&amp;refer=http%3A%2F%2Fcdn.duitang.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=ae46976d4437b2b06e9eeb7ee2addb67",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fww4.sinaimg.cn%2Fmw690%2F001SCD0oly1gtw8bi860lj61tm1tmwhf02.jpg&amp;refer=http%3A%2F%2Fwww.sina.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=0a4363c4a84a54d2490a982db43f3e8a",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F96a8340fgy1gtkxr2ufd0j20rs0rsk12.jpg&amp;refer=http%3A%2F%2Fwx2.sinaimg.cn&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419561&amp;t=1a4ce0f8da965e790966ab7be3ccbcf3"
    ]
}
