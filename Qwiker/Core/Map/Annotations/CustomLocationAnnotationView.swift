//
//  CustomLocationAnnotationView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import SwiftUI
import MapKit


class CustomLocationAnnotationView: MKAnnotationView {
    var isCurrent: Bool = false
    private let annotationFrame = CGRect(x: 0, y: 0, width: 20, height: 20)
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }

    override func draw(_ rect: CGRect) {
        if isCurrent{
            UIColor.black.setFill()
            let outerPath = UIBezierPath(ovalIn: rect)
            outerPath.fill()
            UIColor.white.setFill()
            let centerPath = UIBezierPath(ovalIn: CGRect(x: 6, y: 6, width: 8, height: 8))
            centerPath.fill()
        }else{
            let rectangle = UIBezierPath(rect: rect)
            UIColor.black.setFill()
            rectangle.fill()
        }
    }
}
