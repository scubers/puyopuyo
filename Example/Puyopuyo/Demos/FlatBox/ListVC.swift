//
//  ListVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import RxSwift
import SnapKit
import TangramKit
import UIKit

class ListVC: BaseVC {
    enum CellType: String, CaseIterable {
        case puyo
        case tangramKit
        case snapKit
    }

    lazy var table: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.delegate = self
        v.dataSource = self
        v.rowHeight = UITableView.automaticDimension
        v.register(ListCell.self, forCellReuseIdentifier: CellType.puyo.rawValue)
//        v.register(ListCell2.self, forCellReuseIdentifier: CellType.tangramKit.rawValue)
        v.register(ListCell3.self, forCellReuseIdentifier: CellType.snapKit.rawValue)
        return v
    }()

    var data: [ListData] = []

    var cellType: CellType = .puyo {
        didSet {
            navigationItem.title = cellType.rawValue
            table.reloadData()
        }
    }

    let types = Iterator(CellType.allCases)

    @objc func changeType() {
        cellType = types.next()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "change", style: .plain, target: self, action: #selector(changeType))
        for _ in 0 ..< 100 {
            data.append(ListData(name: "名称名称名称名称名称", text: "孙零件扽三菱交付龙凯减肥三菱单反龙凯减肥领领奖看领结", time: "5分钟前"))
        }

        vRoot.attach() {
            ZBox().attach($0) {
                self.table.attach($0)
                    .size(.fill, .fill)

                FPSView().attach($0)
                    .size(100, 25)
                    .alignment([.left, .top])
            }
            .size(.fill, .fill)
        }
    }
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue) as? BaseCell else { fatalError() }
        cell.viewState.input(value: data[indexPath.row])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

struct ListData {
    var name: String?
    var text: String?
    var time: String?
}

class BaseCell: UITableViewCell, Stateful {
    typealias StateType = ListData?
    let viewState: State<ListData?> = State<ListData?>(nil)

    var name: SimpleOutput<String?> {
        return viewState.asOutput().map({ $0?.name })
    }

    var textData: SimpleOutput<String?> {
        return viewState.asOutput().map({ $0?.text })
    }

    var time: SimpleOutput<String?> {
        return viewState.asOutput().map({ $0?.time })
    }
}

class ListCell: BaseCell {
    private var root: UIView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        root =
            HBox().attach(contentView) {
                UIImageView().attach($0)
                    .size(30, 30)

                VBox().attach($0) {
                    HBox().attach($0) {
                        UILabel().attach($0)
                            .text(self.name)
                            .size(.fill, .fill)

                        UIButton().attach($0)
                            .text(State("广告"), state: .normal)
                            .size(80, 25)
                    }
                    .size(.fill, 30)

                    UILabel().attach($0)
                        .text(self.textData)
                        .numberOfLines(State(0))
                        .size(.fill, .wrap)

                    UIButton().attach($0)
                        .size(.wrap, 25)

                    Spacer(20).attach($0)
                        .width(on: $0, { .fix($0.width * 0.5) })

                    HBox().attach($0) {
                        UILabel().attach($0)
                            .text(self.time)
                        UILabel().attach($0)
                            .text(self.time)
                        UILabel().attach($0)
                            .text(self.time)
                    }
                    .format(.between)
                    .size(.fill, 30)

                    HBox().attach($0) {
                        UILabel().attach($0)
                            .text(self.time)
                            .size(.fill, .fill)
                        UIButton().attach($0)
                            .size(50, .fill)
                    }
                    .size(.fill, 25)
                }
                .size(.fill, .wrap)
            }
            .padding(all: 20)
            .size(.fill, .wrap)
            .view

        Util.randomViewColor(view: self)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return root.sizeThatFits(size)
    }
}


class ListCell3: BaseCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let img = UIImageView()
        contentView.addSubview(img)
        img.snp.makeConstraints { m in
            m.width.height.equalTo(40)
            m.top.left.equalToSuperview().inset(20)
        }

        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { m in
            m.left.equalTo(img.snp.right)
            m.top.right.bottom.equalToSuperview()
        }

        let name = UILabel()
        container.addSubview(name)
        Puyo(name).text(self.name)
        name.snp.makeConstraints { m in
            m.left.equalToSuperview()
            m.top.equalToSuperview().inset(20)
            m.height.equalTo(25)
        }

        let ad = UIButton()
        container.addSubview(ad)
        ad.snp.makeConstraints { m in
            m.top.right.equalToSuperview()
        }

        let text = UILabel()
        container.addSubview(text)
        text.sizeToFit()
        text.attach().text(textData)
        text.snp.makeConstraints { m in
            m.left.right.equalToSuperview()
            m.top.equalTo(name.snp.bottom)
        }

        let download = UIButton()
        container.addSubview(download)
        download.snp.makeConstraints { m in
            m.top.equalTo(text.snp.bottom)
            m.height.equalTo(25)
        }

        let space = UILabel()
        container.addSubview(space)
        space.snp.makeConstraints { m in
            m.height.equalTo(20)
            m.width.equalToSuperview().multipliedBy(0.5)
            m.top.equalTo(download.snp.bottom)
        }

        let spread = UIView()
        container.addSubview(spread)
        spread.snp.makeConstraints { m in
            m.left.right.equalToSuperview()
            m.height.equalTo(30)
            m.top.equalTo(space.snp.bottom)
        }

        let v1 = Label()
        let v2 = Label()
        let v3 = Label()
        v1.attach().text(textData)
        v2.attach().text(textData)
        v3.attach().text(textData)
        spread.addSubview(v1)
        spread.addSubview(v2)
        spread.addSubview(v3)

        v1.snp.makeConstraints { m in
            m.top.bottom.equalToSuperview()
            m.left.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.3)
        }
        v2.snp.makeConstraints { m in
            m.top.bottom.equalToSuperview()
            m.center.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.3)
        }
        v3.snp.makeConstraints { m in
            m.top.bottom.equalToSuperview()
            m.right.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.3)
        }

        let time = UILabel()
        container.addSubview(time)
        time.attach().text(self.time)
        time.snp.makeConstraints { m in
            m.left.equalToSuperview()
            m.bottom.equalToSuperview().inset(20)
            m.height.equalTo(25)
            m.top.equalTo(spread.snp.bottom)
        }

        let more = UIButton()
        container.addSubview(more)
        more.snp.makeConstraints { m in
            m.right.bottom.equalToSuperview()
            m.centerY.equalTo(time)
        }

        Util.randomViewColor(view: contentView)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return contentView.systemLayoutSizeFitting(targetSize)
    }
}
