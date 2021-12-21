import Puyopuyo
import SnapKit
import TangramKit
import XCTest

extension UIView {
    var fw: CGFloat { frame.width }
    var fh: CGFloat { frame.height }
    var fx: CGFloat { frame.origin.x }
    var fy: CGFloat { frame.origin.y }

    var maxX: CGFloat { frame.width + frame.origin.x }
    var maxY: CGFloat { frame.height + frame.origin.y }
}

class Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Measure

    func testActive() {
        let state = State(false)
        var v1: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(grow: 1))
                .activated(state)
                .view
        }
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(v1.py_measure.activated == false)
        XCTAssertTrue(box.frame == .zero)

        state.value = true

        box.layoutIfNeeded()

        XCTAssertTrue(v1.py_measure.activated == true)
        XCTAssertTrue(box.frame != .zero)
    }

    // MARK: LinearBox

    func testLBWidthFixed() {
        var v1: UIView!
        var v2: UIView!
        let box = HBox().attach {
            v1 = UIView().attach($0).width(100).view
            v2 = UIView().attach($0).width(100).view
        }
        .view

        box.layoutIfNeeded()
        XCTAssertTrue(v1.fw == 100)
        XCTAssertTrue(v2.fw == 100)
    }

    func testLBWidthRatio() {
        var v1: UIView!
        var v2: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0).width(.fill).view
            v2 = UILabel().attach($0).width(.fill).view
        }
        .width(100)
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(v1.fw == 50)
        XCTAssertTrue(v2.fw == 50)
    }

    func testLBWidthWrap() {
        var v1: UIView!
        var v2: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0).text("i am label 1").view
            v2 = UILabel().attach($0).text("i am label 2").view
        }
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw)
        XCTAssertTrue(box.fh == max(v1.fh, v2.fh))
    }

    func testLBWidthWrapPriority() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(priority: 1))
                .view
            v2 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(priority: 2))
                .view
            v3 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(priority: 3))
                .view
        }
        .width(200)
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw <= v2.fw)
        XCTAssertTrue(v2.fw <= v3.fw)
    }

    func testLBWidthWrapShrink() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(shrink: 1))
                .view
            v2 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(shrink: 1))
                .view
            v3 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(shrink: 1))
                .view
        }
        .width(200)
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw == v2.fw)
        XCTAssertTrue(v3.fw == v2.fw)
    }

    func testLBWidthWrapGrow() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(grow: 1))
                .view
            v2 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(grow: 2))
                .view
            v3 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(grow: 3))
                .view
        }
        .width(1000)
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw < v2.fw)
        XCTAssertTrue(v3.fw > v2.fw)
    }

    func testLBWidthWrapMaxMin() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(max: 20))
                .view
            v2 = UILabel().attach($0)
                .text("33")
                .width(.wrap(min: 100))
                .view
            v3 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap)
                .view
        }
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw == 20)
        XCTAssertTrue(v2.fw == 100)
    }

    func testLBViewAspectRatio() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .aspectRatio(1 / 2)
                .view
            v2 = UILabel().attach($0)
                .text("i am label 1")
                .aspectRatio(1)
                .view
            v3 = UILabel().attach($0)
                .text("i am label 1")
                .aspectRatio(3 / 1)
                .view
        }
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(v1.fw / v1.fh == 1 / 2)
        XCTAssertTrue(v2.fw / v2.fh == 1)
        XCTAssertTrue(v3.fw / v3.fh == 3 / 1)

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(box.fh == [v1.fh, v2.fh, v3.fh].max())
    }

    func testAlignmentWorks() {
        var views = [UIView]()
        let alignment = State(Alignment.top)
        let box = HBox().attach {
            let v = UILabel().attach($0)
                .size(50, 50)
                .alignment(alignment)
                .view
            views.append(v)
        }
        .size(1000, 100)
        .view

        alignment.value = .top
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fy == 0)

        alignment.value = .center
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].center.y == box.fh / 2)

        alignment.value = .bottom
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].maxY == box.fh)
    }

    func testPaddingMarginWorks() {
        let padding = State(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        let margin = State(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        var v1: UIView!
        let box = HBox().attach {
            v1 = UILabel().attach($0)
                .size(50, 50)
                .margin(margin)
                .view
        }
        .padding(padding)
        .view

        box.layoutIfNeeded()
        XCTAssertTrue(box.fw == v1.fw + padding.value.getHorzTotal() + margin.value.getHorzTotal())
        XCTAssertTrue(box.fh == v1.fh + padding.value.getVertTotal() + margin.value.getVertTotal())
    }

    func testFormatAndReverseWorks() {
        let format = State(Format.leading)
        let reverse = State(false)
        let boxWidth = State(SizeDescription.wrap)
        let boxHeight = State(SizeDescription.wrap)
        var views = [UIView]()
        let count = 9
        let box = HBox().attach {
            for _ in 0 ..< count {
                let v = UILabel().attach($0)
                    .size(50, 50)
                    .view
                views.append(v)
            }
        }
        .size(boxWidth, boxHeight)
        .reverse(reverse)
        .format(format)
        .view

        format.value = .trailing
        boxWidth.value = .fix(3000)
        boxHeight.value = .wrap
        box.layoutIfNeeded()

        XCTAssertTrue(abs(views[count - 1].maxX - box.fw) < 0.1)

        format.value = .between
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fx == 0)
        XCTAssertTrue(abs(views[count - 1].maxX - box.fw) < 0.1)
        print(views[count / 2].center.x)
        print(box.fw / 2)
        XCTAssertTrue(abs(views[count / 2].center.x - box.fw / 2) < 0.1)

        format.value = .round
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fx > 0)
        XCTAssertTrue(views.last!.maxX < box.fw)
        XCTAssertTrue(abs(views[count / 2].center.x - box.fw / 2) < 0.1)

        // reversed
        reverse.value = true
        views = views.reversed()

        format.value = .trailing
        boxWidth.value = .fix(3000)
        boxHeight.value = .wrap
        box.layoutIfNeeded()

        XCTAssertTrue(abs(views[count - 1].maxX - box.fw) < 0.1)

        format.value = .between
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fx == 0)
        XCTAssertTrue(abs(views[count - 1].maxX - box.fw) < 0.1)
        print(views[count / 2].center.x)
        print(box.fw / 2)
        XCTAssertTrue(abs(views[count / 2].center.x - box.fw / 2) < 0.1)

        format.value = .round
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fx > 0)
        XCTAssertTrue(views.last!.maxX < box.fw)
        XCTAssertTrue(abs(views[count / 2].center.x - box.fw / 2) < 0.1)
    }

    // MARK: FlowBox

    // MARK: ZBox
}
