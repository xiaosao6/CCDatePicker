//
//  CCDateManager.swift
//  CCDatePicker
//
//  Created by sischen on 2018/11/6.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit


protocol CCDateSelectionDelegate: class {
    func currentYearRow() -> Int
    func currentMonthRow() -> Int
    func currentDayRow() -> Int
}


/// 日期数据管理类
class CCDateManager {
    
    fileprivate lazy var months_: [Int] = {
        var arr = [Int]()
        for i in 1...12 { arr.append(i) }
        return arr
    }()
    fileprivate lazy var days_: [Int] = {
        var arr = [Int]()
        for i in 1...31 { arr.append(i) }
        return arr
    }()
    
    
    /// 最小的日期
    fileprivate let minDate: Date
    /// 最大的日期
    fileprivate let maxDate: Date
    
    fileprivate(set) var months_available   :[Int]
    fileprivate(set) var days_available     :[Int]
    
    weak var delegate: CCDateSelectionDelegate?
    
    init(minDate: Date, maxDate: Date) {
        self.minDate = minDate
        self.maxDate = maxDate
        self.months_available = []
        self.days_available   = []
    }
}

extension CCDateManager {
    @discardableResult
    func setDate(_ date: Date) -> (yRow: Int, mRow: Int, dRow: Int) {
        if date.compare(minDate) == .orderedAscending || date.compare(maxDate) == .orderedDescending {
            fatalError("指定日期超过了可选日期范围")
        }
        
        let result = refreshCurrent(year: date.year, month: date.month, day: date.day)
        return result
    }
    
    func refreshSelection() -> (yRow: Int, mRow: Int, dRow: Int) {
        let yRow = self.delegate?.currentYearRow() ?? 0
        let mRow = self.delegate?.currentMonthRow() ?? 0
        let dRow = self.delegate?.currentDayRow() ?? 0
        
        let year = minDate.year + yRow
        let month = months_available[mRow]
        let day = days_available[dRow]
        
        let result = refreshCurrent(year: year, month: month, day: day)
        return result
    }
    
    fileprivate func refreshCurrent(year: Int, month: Int, day: Int) -> (yRow: Int, mRow: Int, dRow: Int) {
        handleRefreshMonthsOf(year: year)
        
        handleRefreshDaysOf(year: year, month: month)
        
        let yRow = year - minDate.year
        let mRow = months_available.index(of: month) ?? 0
        let dRow = days_available.index(of: day) ?? 0
        return (yRow, mRow, dRow)
    }
    
//    /// 处理用户选择变化,返回新的序号
//    func onSelectionChangedWith(year: Int, month: Int, day: Int) -> (yRow: Int, mRow: Int, dRow: Int) {
//
//
//
////        if let dayLast = days_available?.last, let dayFirst = days_available?.first {
////            if day < dayFirst || day > dayLast {
////                let distanceToLast  = abs(day - dayLast)
////                let distanceToFirst = abs(day - dayFirst)
////                return (distanceToLast < distanceToFirst) ? dayLast : dayFirst
////            }
////        }
////        return day
//    }
    
    var minYearInt: Int {
        return minDate.year
    }
}

extension CCDateManager {
    /// 处理`月`范围
    fileprivate func handleRefreshMonthsOf(year: Int) {
        
        if (maxDate.year == minDate.year) {
            months_available = months_.filter({ $0 >= minDate.month && $0 <= maxDate.month })
        } else {
            if year == minDate.year {
                months_available = months_.filter({ $0 >= minDate.month })
            } else if year == maxDate.year {
                months_available = months_.filter({ $0 <= maxDate.month })
            } else {
                months_available = months_
            }
        }
    }
    /// 处理`日`范围
    fileprivate func handleRefreshDaysOf(year: Int, month: Int) {
        let fullDays = Date.fullDaysOf(year: year, month: month)
        
        if (maxDate.year == minDate.year) {
            if (maxDate.month == minDate.month){
                days_available = days_.filter({ $0 >= minDate.day && $0 <= maxDate.day })
            } else {
                if (month == minDate.month) {
                    days_available = days_.filter({ $0 >= minDate.day && $0 <= fullDays })
                } else if (month == maxDate.month) {
                    days_available = days_.filter({ $0 <= maxDate.day })
                } else {
                    days_available = days_.filter({ $0 <= fullDays })
                }
            }
        } else {
            if year == minDate.year {
                if month == minDate.month {
                    days_available = days_.filter({ $0 >= minDate.day && $0 <= fullDays })
                } else {
                    days_available = days_.filter({ $0 <= fullDays })
                }
            } else if year == maxDate.year {
                if month == maxDate.month {
                    days_available = days_.filter({ $0 <= maxDate.day })
                } else {
                    days_available = days_.filter({ $0 <= fullDays })
                }
            } else {
                days_available = days_.filter({ $0 <= fullDays })
            }
        }
    }
    
}

extension CCDateManager {
    fileprivate func numberOfRowsInComponent(_ component: Int) -> Int {
        switch component {
        case 0: return (maxDate.year - minDate.year) + 1
        case 1: return months_available.count
        case 2: return days_available.count
        default: return 0
        }
    }
    
    fileprivate func intValueForRow(row: Int, forComponent component: Int) -> Int{
        switch component {
        case 0:
            return minDate.year + row
        case 1:
            return months_available[row]
        case 2:
            return days_available[row]
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
