//
//  ViewController.swift
//  CCDatePicker
//
//  Created by sischen on 2018/10/4.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 200)
        let datepicker = CCDatePicker.init(frame: frame)
        self.view.addSubview(datepicker)
        
        datepicker.setDate(Date())
    }

}

