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

    var calFrame: CGRect { layoutMeasure.calculatedFrame }

    var calSize: CGSize { calFrame.size }

    var celCenter: CGPoint { layoutMeasure.calculatedCenter }
}

class LinearTests: XCTestCase {
    var box = ZBox()
    override func setUp() {
        super.setUp()
        box = ZBox()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - Measure

    func testActive() {
        let state = State(false)
        var v1: UIView!
        HBag().attach(box) {
            v1 = UILabel().attach($0)
                .text("i am label 1")
                .width(.wrap(grow: 1))
                .activated(state)
                .view
        }

        box.layoutIfNeeded()

        XCTAssertTrue(v1.layoutMeasure.activated == false)
        XCTAssertTrue(box.frame == .zero)

        state.value = true

        box.layoutIfNeeded()

        XCTAssertTrue(v1.layoutMeasure.activated == true)
        XCTAssertTrue(box.frame != .zero)
    }

    // MARK: - LinearBox

    func testLBWidthFixed() {
        var v1: UIView!
        var v2: UIView!
        HBag().attach(box) {
            v1 = UIView().attach($0).width(100).view
            v2 = UIView().attach($0).width(100).view
        }

        box.layoutIfNeeded()
        XCTAssertTrue(v1.fw == 100)
        XCTAssertTrue(v2.fw == 100)
    }

    func testLBWidthRatio() {
        var v1: UIView!
        var v2: UIView!
        HBag().attach(box) {
            v1 = UILabel().attach($0).text("abc").width(.fill).view
            v2 = UILabel().attach($0).text("abc").width(.fill).view
        }
        .width(100)

        box.layoutIfNeeded()

        XCTAssertTrue(v1.fw == 50)
        XCTAssertTrue(v2.fw == 50)
    }

    func testLBWidthWrap() {
        var v1: UIView!
        var v2: UIView!
        HBag().attach(box) {
            v1 = UILabel().attach($0).text("i am label 1").view
            v2 = UILabel().attach($0).text("i am label 2").view
        }

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw)
        XCTAssertTrue(box.fh == max(v1.fh, v2.fh))
    }

    func testLBWidthWrapPriority() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBag().attach(box) {
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

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw <= v2.fw)
        XCTAssertTrue(v2.fw <= v3.fw)
    }

    func testLBWidthWrapShrink() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBag().attach(box) {
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

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw == v2.fw)
        XCTAssertTrue(v3.fw == v2.fw)
    }

    func testLBWidthWrapGrow() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBag().attach(box) {
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

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw < v2.fw)
        XCTAssertTrue(v3.fw > v2.fw)
    }

    func testLBWidthWrapMaxMin() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBox().attach(box) {
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

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw)
        XCTAssertTrue(v1.fw == 20)
        XCTAssertTrue(v2.fw == 100)
    }

    func testLBViewAspectRatio() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBag().attach(box) {
            v1 = UILabel().attach($0)
                .text("i am label 1")
//                .aspectRatio(1 / 2)
                .size(.wrap, .aspectRatio(1 / 2))
                .view
            v2 = UILabel().attach($0)
                .text("i am label 1")
//                .aspectRatio(1)
                .size(.wrap, .aspectRatio(1))
                .view
            v3 = UILabel().attach($0)
                .text("i am label 1")
//                .aspectRatio(3 / 1)
                .size(.wrap, .aspectRatio(3 / 1))
                .view
        }

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
        HBag().attach(box) {
            let v = UILabel().attach($0)
                .size(50, 50)
                .alignment(alignment)
                .view
            views.append(v)
        }
        .size(1000, 100)

        alignment.value = .top
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fy == 0)

        alignment.value = .center
        box.setNeedsLayout()
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].center.y == box.fh / 2)

        alignment.value = .bottom
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].maxY == box.fh)
    }

    func testJustifyContentWorks() {
        let alignment = State(Alignment.top)
        var v1: UIView!
        HBag().attach(box) {
            v1 = UILabel().attach($0)
                .size(50, 50)
                .view
        }
        .justifyContent(alignment)
        .size(1000, 100)

        alignment.value = .top
        box.layoutIfNeeded()
        XCTAssertTrue(v1.fy == 0)

        alignment.value = .center
        box.layoutIfNeeded()
        XCTAssertTrue(v1.center.y == box.fh / 2)

        alignment.value = .bottom
        box.layoutIfNeeded()
        XCTAssertTrue(v1.maxY == box.fh)
    }

    func testPaddingMarginWorks() {
        let padding = State(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        let margin = State(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        var v1: UIView!
        HBag().attach(box) {
            v1 = UILabel().attach($0)
                .size(50, 50)
                .margin(margin)
                .view
        }
        .padding(padding)

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
        HBag().attach(box) {
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

        format.value = .trailing
        boxWidth.value = .fix(3000)
        boxHeight.value = .wrap
        box.layoutIfNeeded()

        XCTAssertTrue(abs(views[count - 1].maxX - box.fw) < 0.1)

        format.value = .between
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fx == 0)
        XCTAssertTrue(abs(views[count - 1].maxX - box.fw) < 0.1)
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
        XCTAssertTrue(abs(views[count / 2].center.x - box.fw / 2) < 0.1)

        format.value = .round
        box.layoutIfNeeded()
        XCTAssertTrue(views[0].fx > 0)
        XCTAssertTrue(views.last!.maxX < box.fw)
        XCTAssertTrue(abs(views[count / 2].center.x - box.fw / 2) < 0.1)
    }

    func testLBDirectionWorks() {
        let d = State(Direction.x)
        LinearBag().attach(box) {
            UILabel().attach($0)
                .size(50, 50)
            UILabel().attach($0)
                .size(50, 50)
            UILabel().attach($0)
                .size(50, 50)
        }
        .direction(d)

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == 50 * 3)
        XCTAssertTrue(box.fh == 50)

        d.value = .y
        box.layoutIfNeeded()

        XCTAssertTrue(box.fh == 50 * 3)
        XCTAssertTrue(box.fw == 50)
    }

    func testLBSpaceWorks() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBag().attach(box) {
            v1 = WrapSizeView(100, 100).attach($0)
                .width(.wrap)
                .view
            v2 = WrapSizeView(100, 100).attach($0)
                .width(.wrap)
                .view
            v3 = WrapSizeView(100, 100).attach($0)
                .width(.wrap)
                .view
        }
        .space(20)

        box.layoutIfNeeded()

        XCTAssertTrue(box.fw == v1.fw + v2.fw + v3.fw + 20 * 2)
        print(v1.calFrame)
        print(v2.calFrame)
        XCTAssertTrue(v1.calFrame.minX == 0)
        XCTAssertTrue(v2.calFrame.minX == v1.calFrame.maxX + 20)
        XCTAssertTrue(v3.calFrame.minX == v2.calFrame.maxX + 20)
    }

    func testCrossConflictRecalculating() {
        var v1: UIView!
        var v2: UIView!
        var v3: UIView!
        HBag().attach(box) {
            v1 = WrapSizeView(100, 100).attach($0)
                .height(.fill)
                .view
            v2 = WrapSizeView(100, 200).attach($0)
                .view
            v3 = WrapSizeView(100, 200).attach($0)
                .height(.fill)
                .view
        }

        box.layoutIfNeeded()

        XCTAssertTrue(box.calFrame.width == 300)
        XCTAssertTrue(box.calFrame.height == v2.calFrame.height)
        XCTAssertTrue(v1.calFrame.height == v2.calFrame.height)
        XCTAssertTrue(v3.calFrame.height == v2.calFrame.height)
    }

    // MARK: - FlowBox

    // MARK: - ZBox
}
