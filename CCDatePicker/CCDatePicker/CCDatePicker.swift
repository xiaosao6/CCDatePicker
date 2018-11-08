//
//  CCDatePicker.swift
//  CCDatePicker
//
//  Created by sischen on 2018/11/4.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit


protocol CCDatePickerDelegate: class {
    func didSelectDate(at picker: CCDatePicker)
}

protocol CCDatePickerDataSource: class {
    func datepicker(_ picker: CCDatePicker, numberOfRowsInComponent component: Int) -> Int
    func datepicker(_ picker: CCDatePicker, intValueForRow row: Int, forComponent component: Int) -> Int
}


class CCDatePicker: UIView {
    
    weak var delegate: CCDatePickerDelegate?
    weak var dataSource: CCDatePickerDataSource?
    
    /// 单位字符
    var unitName: (year: String?, month: String?, day: String?) = ("年", "月", "日")
    
    /// 标题字体
    var titleFont  = UIFont.systemFont(ofSize: 17)
    
    /// 标题颜色
    var titleColor = UIColor.darkGray
    
    /// 中心行高
    var rowHeight: CGFloat = 45
    
    /// 分割线颜色
    var separatorColor = UIColor.lightGray {
        didSet{
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// 当前选择的日期
    var currentDate: Date {
        let year  = currentYearInt()
        let month = currentMonthInt()
        let day   = currentDayInt()
        let date  = Date.cc_defaultFormatter.date(from: "\(year)-\(month)-\(day)")
        return date!
    }
    
    
    fileprivate let componentCount = 3
    
    fileprivate var manager: CCDateManager?
    
    fileprivate lazy var pickerview: UIPickerView = {
        let tmpv = UIPickerView.init()
        tmpv.delegate = self
        tmpv.dataSource = self
        return tmpv
    }()
    
    required init(frame: CGRect = .zero, minDate: Date, maxDate: Date) {
        super.init(frame: frame)
        
        manager = CCDateManager.init(minDate: minDate, maxDate: maxDate)
        manager?.delegate = self
        self.dataSource = manager
        
        pickerview.frame = frame
        self.addSubview(pickerview)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // 暂不支持xib
    }
}

//MARK: ------------------------ Public

extension CCDatePicker{
    
    /// 设置日期,例如`"2007-8-20"`或`"2007-11-9"`
    func setDate(_ dateString: String, animated: Bool = false) {
        guard let date = Date.cc_defaultFormatter.date(from: dateString) else { return }
        setDate(date, animated: animated)
    }
    
    func setDate(_ date: Date, animated: Bool = false) {
        let rowInfo = manager?.setDate(date)
        if let info = rowInfo {
            pickerview.selectRow(info.yRow, inComponent: 0, animated: animated)
            pickerview.selectRow(info.mRow, inComponent: 1, animated: animated)
            pickerview.selectRow(info.dRow, inComponent: 2, animated: animated)
            pickerview.reloadAllComponents()
        }
    }
}

//MARK: ------------------------ Private

extension CCDatePicker{
    /// 分割线views
    fileprivate var separatorLines: [UIView] {
        return pickerview.subviews.filter {
            $0.bounds.height < 1.0 && $0.bounds.width == pickerview.bounds.width
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerview.frame = self.bounds
        separatorLines.forEach { $0.backgroundColor = separatorColor }
    }
}

extension CCDatePicker: CCDateSelectionDelegate {
    func currentYearInt() -> Int {
        let row = pickerview.selectedRow(inComponent: 0)
        let attrStr = self.pickerView(pickerview, attributedTitleForRow: row, forComponent: 0)
        let value: Int = attrStr?.string.getInt() ?? 1
        return value
    }
    
    func currentMonthInt() -> Int {
        let row = pickerview.selectedRow(inComponent: 1)
        let attrStr = self.pickerView(pickerview, attributedTitleForRow: row, forComponent: 1)
        let value: Int = attrStr?.string.getInt() ?? 1
        return value
    }
    
    func currentDayInt() -> Int {
        let row = pickerview.selectedRow(inComponent: 2)
        let attrStr = self.pickerView(pickerview, attributedTitleForRow: row, forComponent: 2)
        let value: Int = attrStr?.string.getInt() ?? 1
        return value
    }
}

extension CCDatePicker: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return pickerView.bounds.width * 0.45 // 根据字符宽度测得比例
        case 1: return pickerView.bounds.width * 0.5 * (1 - 0.45)
        case 2: return pickerView.bounds.width * 0.5 * (1 - 0.45)
        default: return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var ostr = ""
        let intValue = self.dataSource?.datepicker(self, intValueForRow: row, forComponent: component) ?? 1
        switch component {
        case 0: ostr = String(intValue) + (unitName.year ?? "")
        case 1: ostr = String(intValue) + (unitName.month ?? "")
        case 2: ostr = String(intValue) + (unitName.day ?? "")
        default: break
        }
        let attStr = NSMutableAttributedString(string: ostr)
        attStr.addAttributes([.foregroundColor: titleColor, .font: titleFont], range: NSMakeRange(0, ostr.count))
        return attStr
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let attrText = self.pickerView(pickerView, attributedTitleForRow: row, forComponent: component)
        if let label = view as? UILabel {
            label.attributedText = attrText
            return label
        }
        let newlabel = UILabel.init()
        newlabel.backgroundColor = UIColor.clear
        newlabel.textAlignment = .center
        newlabel.attributedText = attrText
        return newlabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if let mRow = manager?.onYearRefreshed(){
                pickerView.reloadComponent(1)
                pickerview.selectRow(mRow, inComponent: 1, animated: false)
                self.pickerView(pickerView, didSelectRow: mRow, inComponent: 1)
            }
        case 1:
            if let dRow = manager?.onMonthRefreshed() {
                pickerView.reloadComponent(2)
                pickerview.selectRow(dRow, inComponent: 2, animated: false)
                self.pickerView(pickerView, didSelectRow: dRow, inComponent: 2)
            }
        case 2:
            self.delegate?.didSelectDate(at: self)
        default: break
        }
    }
}

extension CCDatePicker: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return componentCount }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rowCount = self.dataSource?.datepicker(self, numberOfRowsInComponent: component) ?? 0
        return rowCount
    }
}

extension String {
    fileprivate func getInt() -> Int {
        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number: Int = 0
        scanner.scanInt(&number)
        return number
    }
}




protocol CCDateSelectionDelegate: class {
    func currentYearInt() -> Int
    func currentMonthInt() -> Int
    func currentDayInt() -> Int
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
    
    fileprivate var months_available   :[Int]
    fileprivate var days_available     :[Int]
    
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
    
    /// 更新`年`的选择,返回新的`月`index
    func onYearRefreshed() -> Int {
        let year  = self.delegate?.currentYearInt() ?? 1
        let month = self.delegate?.currentMonthInt() ?? 1
        
        handleRefreshMonthsOf(year: year)
        
        var mRow = months_available.index(of: month) ?? 0
        if let monthLast = months_available.last, let monthFirst = months_available.first {
            if month < monthFirst {
                mRow = 0
            } else if month > monthLast {
                mRow = months_available.count - 1
            }
        }
        return mRow
    }
    
    /// 更新`月`的选择,返回新的`日`index
    func onMonthRefreshed() -> Int {
        let year  = self.delegate?.currentYearInt() ?? 1
        let month = self.delegate?.currentMonthInt() ?? 1
        let day   = self.delegate?.currentDayInt() ?? 1
        
        handleRefreshDaysOf(year: year, month: month)
        
        var dRow = days_available.index(of: day) ?? 0
        if let dayLast = days_available.last, let dayFirst = days_available.first {
            if day < dayFirst {
                dRow = 0
            } else if day > dayLast {
                dRow = days_available.count - 1
            }
        }
        return dRow
    }
}

extension CCDateManager {
    fileprivate func refreshCurrent(year: Int, month: Int, day: Int) -> (yRow: Int, mRow: Int, dRow: Int) {
        handleRefreshMonthsOf(year: year)
        handleRefreshDaysOf(year: year, month: month)
        
        var mRow = months_available.index(of: month) ?? 0
        if let monthLast = months_available.last, let monthFirst = months_available.first {
            if month < monthFirst {
                mRow = 0
            } else if month > monthLast {
                mRow = months_available.count - 1
            }
        }
        
        var dRow = days_available.index(of: day) ?? 0
        if let dayLast = days_available.last, let dayFirst = days_available.first {
            if day < dayFirst {
                dRow = 0
            } else if day > dayLast {
                dRow = days_available.count - 1
            }
        }
        
        let yRow = year - minDate.year
        return (yRow, mRow, dRow)
    }
    
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
        case 0:
            return (maxDate.year - minDate.year) + 1
        case 1:
            return months_available.count
        case 2:
            return days_available.count
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
        return self.dateFormatterWith("yyyy-M-d")
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
