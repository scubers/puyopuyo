import XCTest
import Puyopuyo
import TangramKit
import SnapKit


class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
        let diff = Diff(src: [0,1,2].map({ $0.description }),
                        dest: [2,0,4,6,1].map({ $0.description }))
        diff.check()
        print("insert: \(diff.insert)")
        print("delete: \(diff.delete)")
        print("move: \(diff.move)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            for _ in 0..<300 {
                // puyo
                let cell = ListCell(style: .value1, reuseIdentifier: "1")
                // tg
//                let cell = ListCell2(style: .value1, reuseIdentifier: "1")
                // autolayout
//                let cell = ListCell3(style: .value1, reuseIdentifier: "1")
                cell.viewState.input(value: ListData(name: "slkdjflksdjflkjsdf", text: "来看房来看房龙看房龙蛋飞龙扽静", time: "lskdj"))
                _ = cell.sizeThatFits(CGSize(width: 320, height: 0))
//                _ = cell.systemLayoutSizeFitting(CGSize(width: 320, height: 0))
            }
        }
    }
    
}
struct Util {
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        let c = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
        return c
    }
    
    
    static func randomViewColor(view: UIView) {
        view.subviews.forEach { (v) in
            v.backgroundColor = self.randomColor()
            self.randomViewColor(view: v)
        }
    }
    
    static func random<T>(array: [T]) -> T {
        let index = arc4random_uniform(UInt32(array.count))
        return array[Int(index)]
    }
}


struct ListData {
    var name: String?
    var text: String?
    var time: String?
}

class BaseCell: UITableViewCell, Stateful {
    typealias StateType = ListData?
    var viewState: State<ListData?> = State<ListData?>(nil)
    
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
                            .text(State("广告"))
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
    required init?(coder aDecoder: NSCoder) {
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
        img.snp.makeConstraints { (m) in
            m.width.height.equalTo(40)
            m.top.left.equalToSuperview().inset(20)
        }
        
        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { (m) in
            m.left.equalTo(img.snp.right)
            m.top.right.bottom.equalToSuperview()
        }
        
        let name = UILabel()
        container.addSubview(name)
        Puyo(name).text(self.name)
        name.snp.makeConstraints { (m) in
            m.left.equalToSuperview()
            m.top.equalToSuperview().inset(20)
            m.height.equalTo(25)
        }
        
        let ad = UIButton()
        container.addSubview(ad)
        ad.snp.makeConstraints { (m) in
            m.top.right.equalToSuperview()
        }
        
        let text = UILabel()
        container.addSubview(text)
        text.sizeToFit()
        text.attach().text(self.textData)
        text.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo(name.snp.bottom)
        }
        
        let download = UIButton()
        container.addSubview(download)
        download.snp.makeConstraints { (m) in
            m.top.equalTo(text.snp.bottom)
            m.height.equalTo(25)
        }
        
        let space = UILabel()
        container.addSubview(space)
        space.snp.makeConstraints { (m) in
            m.height.equalTo(20)
            m.width.equalToSuperview().multipliedBy(0.5)
            m.top.equalTo(download.snp.bottom)
        }
        
        let spread = UIView()
        container.addSubview(spread)
        spread.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.height.equalTo(30)
            m.top.equalTo(space.snp.bottom)
        }
        
        let v1 = UILabel()
        let v2 = UILabel()
        let v3 = UILabel()
        v1.attach().text(self.textData)
        v2.attach().text(self.textData)
        v3.attach().text(self.textData)
        spread.addSubview(v1)
        spread.addSubview(v2)
        spread.addSubview(v3)
        
        v1.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.3)
        }
        v2.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.center.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.3)
        }
        v3.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.right.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.3)
        }
        
        let time = UILabel()
        container.addSubview(time)
        time.attach().text(self.time)
        time.snp.makeConstraints { (m) in
            m.left.equalToSuperview()
            m.bottom.equalToSuperview().inset(20)
            m.height.equalTo(25)
            m.top.equalTo(spread.snp.bottom)
        }
        
        let more = UIButton()
        container.addSubview(more)
        more.snp.makeConstraints { (m) in
            m.right.bottom.equalToSuperview()
            m.centerY.equalTo(time)
        }
        
        Util.randomViewColor(view: contentView)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return contentView.systemLayoutSizeFitting(targetSize)
    }
}
