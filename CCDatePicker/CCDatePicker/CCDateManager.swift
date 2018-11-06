//
//  CCDateManager.swift
//  CCDatePicker
//
//  Created by sischen on 2018/11/6.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit


/// 日期数据管理类
class CCDateManager {
    
    /// 最小的日期
    var minDate = Date()
    
    /// 最大的日期
    var maxDate = Date()
    
    /// 当前选中的日期
    fileprivate(set) var currentDate = Date()
    
}

extension CCDateManager {
    
    func setDate(_ date: Date) {
        currentDate = date
    }
}

extension CCDateManager: CCDatePickerDataSource {
    func datepicker(_ picker: CCDatePicker, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    func datepicker(_ picker: CCDatePicker, intValueForRow row: Int, forComponent component: Int) -> Int {
        return 0
    }
}


extension Date {
    static var cc_defaultFormatter: DateFormatter {
        return self.dateFormatterWith("yyyy-MM-dd")
    }
    
    /// 自定义时间格式的格式化器
    fileprivate static func dateFormatterWith(_ formatString: String) -> DateFormatter {
        let threadDic = Thread.current.threadDictionary
        if let fmt = threadDic.object(forKey: formatString) as? DateFormatter {
            return fmt
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        threadDic.setObject(dateFormatter, forKey: formatString as NSCopying)
        return dateFormatter
    }
    
    /// 指定年月的天数
    fileprivate static func fullDaysOf(year: Int, month: Int) -> Int {
        if [1, 3, 5, 7, 8, 10, 12].contains(month) { return 31 }
        if [4, 6, 9, 11].contains(month) { return 30 }
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
        return isLeapYear ? 29 : 28 // 二月
    }
    
    fileprivate var year: Int {
        return NSCalendar.current.component(.year, from: self)
    }
    fileprivate var month: Int {
        return NSCalendar.current.component(.month, from: self)
    }
    fileprivate var day: Int {
        return NSCalendar.current.component(.day, from: self)
    }
}
