//
//  NewsVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2022/5/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class NewsVC: BaseViewController {
    let direction = State(Direction.vertical)

    func refreshDirection() {
        switch UIDevice.current.orientation {
        case .portrait:
            direction.value = .vertical
        default:
            direction.value = .horizontal
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshDirection()

        LinearBox().attach(view) {
            let v = $0
            Outputs.listen(to: UIDevice.orientationDidChangeNotification).safeBind(to: self) { this, _ in
                this.refreshDirection()
                v.setNeedsLayout()
            }
            UIImageView().attach($0)
                .size(direction.map { direction in
                    switch direction {
                    case .vertical:
                        return Size(width: .fill, height: .aspectRatio(4 / 3))
                    case .horizontal:
                        return Size(width: .aspectRatio(1), height: .fill)
                    }
                })
                .contentMode(.scaleAspectFill)
                .clipToBounds(true)
                .image(downloadImage(url: Images().get()))

            VGroup().attach($0) {
                UILabel().attach($0)
                    .fontSize(32, weight: .bold)
                    .text("A Headline news !!")
                    .numberOfLines(0)
                UIScrollView().attach($0) {
                    VBox().attach($0) {
                        UILabel().attach($0)
                            .text(text)
                            .numberOfLines(0)
                    }
                    .width(.fill)

                    .autoJudgeScroll(true)
                }
                .size(.fill, .fill)
            }
            .padding(all: 16)
            .padding(bottom: 0)
            .size(.fill, .fill)
            .space(18)
        }
        .padding(view.py_safeArea())
        .direction(direction)
        .size(.fill, .fill)
    }

    var text: String {
        """
        When Stephanie Mejia Arciñiega drove her friend to the Planned Parenthood in Ann Arbor, Mich., they were surrounded by anti-abortion protestors as soon as they tried to pull in to the clinic.

        "They come up to your car super fast," Mejia Arciñiega said. "You don't want to run their feet over, so we had to stop and be like, 'OK, no thank you.' But then they started throwing a bunch of papers and resources at us. We tried to go inside, but we couldn't."

        The clinic, which offers abortion care as well as birth control, cancer screenings, and STD treatment, has long been the target of anti-abortion protestors. Protestors' efforts to limit abortions in the state may soon get a huge boost, if the Supreme Court strikes down Roe v. Wade.

        In Michigan, this would have an immediate impact. Overnight, nearly all abortions would become a felony carrying a penalty of up to four years, even in the cases of rape and incest. That's under an old state law, last updated in 1931, that was never repealed, even after Roe made it unenforceable in 1973.

        Mejia Arciñiega is only 18. She's never imagined a world where abortion is illegal. "You wouldn't think that in 2022, we'd be worrying about women's rights, reproduction rights," she said. "You wouldn't want someone young that isn't ready [to] have to have a baby because the law says 'No.' It's not fair."

        Michigan Attorney General, Dana Nessel has a similar concern. The Democrat said she won't enforce the law if it springs back into effect. But Michigan has 83 local county prosecutors, and Nessel said they could do whatever they want. "I don't think that I have the authority to tell the duly elected county prosecutors what they can and what they cannot charge," Nessel said at a press conference earlier this week.

        The way the law's written, Nessel said it's possible that prosecutors could go after anyone who provides an abortion, as well as the person who takes medications to end their own pregnancy.
        """
    }
}
