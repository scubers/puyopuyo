import Puyopuyo
import SnapKit
import TangramKit
import XCTest

extension UIView {
    var fw: CGFloat { frame.width }
    var fh: CGFloat { frame.height }
    var fx: CGFloat { frame.origin.x }
    var fy: CGFloat { frame.origin.y }
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

    // MARK: FlowBox

    // MARK: ZBox
}
