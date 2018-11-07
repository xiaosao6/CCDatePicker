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
        let minDate = Date().addingTimeInterval((365 * 24 * 60 * 60) * -10)
        let maxDate = Date().addingTimeInterval((  1 * 24 * 60 * 60))
        let datepicker = CCDatePicker.init(minDate: minDate, maxDate: maxDate)
        datepicker.frame = frame
        datepicker.delegate = self
        self.view.addSubview(datepicker)
        
        datepicker.setDate(Date())
    }

}

extension ViewController: CCDatePickerDelegate {
    func didSelectDate(at picker: CCDatePicker) {
        let description = picker.description//.currentDate.description(with: Locale.current)
        NSLog(description)
    }
}

