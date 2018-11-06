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

extension CCDateManager {
    fileprivate func numberOfRowsInComponent(_ component: Int) -> Int {
        switch component {
        case 0: // 年
            return (maxDate.year - minDate.year) + 1
        case 1: // 月
            if (maxDate.year == minDate.year) {
                return (maxDate.month - minDate.month) + 1
            } else {
                if currentDate.year == minDate.year {
                    return 12 - minDate.month + 1
                } else if currentDate.year == maxDate.year {
                    return maxDate.month
                } else {
                    return 12
                }
            }
        case 2: // 日
            let fullDays = Date.fullDaysOf(year: currentDate.year, month: currentDate.month)
            
            if (maxDate.year == minDate.year) {
                if (maxDate.month == minDate.month){
                    return maxDate.day - minDate.day + 1
                } else {
                    if (currentDate.month == minDate.month) {
                        return fullDays - minDate.day + 1
                    } else if (currentDate.month == maxDate.month) {
                        return maxDate.day
                    } else {
                        return fullDays
                    }
                }
            } else {
                if currentDate.year == minDate.year {
                    if currentDate.month == minDate.month {
                        return fullDays - minDate.day + 1
                    } else {
                        return fullDays
                    }
                } else if currentDate.year == maxDate.year {
                    if currentDate.month == maxDate.month {
                        return maxDate.day
                    } else {
                        return fullDays
                    }
                } else {
                    return fullDays
                }
            }
        default: return 0
        }
    }
    
    fileprivate func intValueForRow(row: Int, forComponent component: Int) -> Int{
        switch component {
        case 0: return minDate.year + row
        case 1:
            if (maxDate.year == minDate.year) {
                return minDate.month + row
            } else {
                if currentDate.year == minDate.year {
                    return minDate.month + row
                } else if currentDate.year == maxDate.year {
                    return row + 1
                } else {
                    return row + 1
                }
            }
        case 2:
            if (maxDate.year == minDate.year) {
                if (maxDate.month == minDate.month){
                    return minDate.day + row
                } else {
                    if (currentDate.month == minDate.month) {
                        return minDate.day + row
                    } else if (currentDate.month == maxDate.month) {
                        return row + 1
                    } else {
                        return row + 1
                    }
                }
            } else {
                if currentDate.year == minDate.year {
                    if currentDate.month == minDate.month {
                        return minDate.day + row
                    } else {
                        return row + 1
                    }
                } else if currentDate.year == maxDate.year {
                    if currentDate.month == maxDate.month {
                        return row + 1
                    } else {
                        return row + 1
                    }
                } else {
                    return row + 1
                }
            }
        default: return 1
        }
    }
}

extension CCDateManager: CCDatePickerDataSource {
    func datepicker(_ picker: CCDatePicker, numberOfRowsInComponent component: Int) -> Int {
        return self.numberOfRowsInComponent(component)
    }
    
    func datepicker(_ picker: CCDatePicker, intValueForRow row: Int, forComponent component: Int) -> Int {
        return self.intValueForRow(row: row, forComponent: component)
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
