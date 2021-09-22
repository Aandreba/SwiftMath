//
//  ViewController.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 3/9/21.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let test = Complex<BigDecimal>(re: 1)
        print(test.description)
        // Do any additional setup after loading the view.
    }
}
