//
//  CCDatePicker.swift
//  CCDatePicker
//
//  Created by sischen on 2018/10/4.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit


protocol CCDatePickerDelegate: class {
    func didSelectDate(at picker: CCDatePicker)
}


class CCDatePicker: UIView {
    
    weak var delegate: CCDatePickerDelegate?
    
    /// 标题字体,默认17号
    var titleFont  = UIFont.systemFont(ofSize: 17)
    
    /// 标题颜色,默认darkGray
    var titleColor = UIColor.darkGray
    
    /// 行高
    var rowHeight: CGFloat = 44
    
    /// 分割线颜色,默认lightGray
    var separatorColor = UIColor.lightGray {
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { // 立即刷新
                self.separatorLines.forEach {
                    $0.backgroundColor = self.separatorColor
                }
            }
        }
    }
    
    /// 最小的日期
    var minDate = Date.defaultFormatter.date(from: "2000-10-20")!
    /// 最大的日期,默认今天
    var maxDate = Date()
    
    /// 当前选中的日期
    var currentDate: Date {
        let offset = getDayOffset()
        let currentDay = pickerview.selectedRow(inComponent: 2) + offset
        let dateStr = "\(currentYear)-\(currentMonth)-\(currentDay)"
        return Date.defaultFormatter.date(from: dateStr)!
    }
    
    
    fileprivate lazy var pickerview: UIPickerView = {
        let tmpv = UIPickerView.init()
        tmpv.delegate = self
        tmpv.dataSource = self
        return tmpv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pickerview.frame = frame
        self.addSubview(pickerview)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // 暂不支持xib
    }
}

//MARK: ------------------------ Public

extension CCDatePicker{
    
    func setDate(_ date: Date, animated: Bool = false) {
        let string = Date.defaultFormatter.string(from: date)
        setDate(string, animated: animated)
    }
    
    /// 设置日期,例如`"2007-08-20"`或`"2007-11-09"`
    func setDate(_ dateString: String, animated: Bool = false) {
        let components = dateString.components(separatedBy: "-")
        if components.count != 3 { return }
        
        let minYear = minDate.intValueOf(.year)
        let year  = Int(components.first ?? "") ?? minYear
        let month = Int(components[1]) ?? 1
        let day   = Int(components.last ?? "") ?? 1
        
        let yearRow  = (year - minYear) > 0 ? (year - minYear) : 0
        let monthRow = (month - 1) > 0 ? (month - 1) : 0
        let dayRow   = (day - 1) > 0 ? (day - 1) : 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.pickerview.selectRow(yearRow, inComponent: 0, animated: animated)
            self.pickerview.reloadAllComponents()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.pickerview.selectRow(monthRow, inComponent: 1, animated: animated)
            self.pickerview.selectRow(dayRow,   inComponent: 2, animated: animated)
            self.pickerview.reloadAllComponents()
        }
    }
}

//MARK: ------------------------ Private

extension CCDatePicker{
    /// 当前年数值
    fileprivate var currentYear: Int {
        let minYear = minDate.intValueOf(.year)
        return pickerview.selectedRow(inComponent: 0) + minYear
    }
    /// 当前月数值
    fileprivate var currentMonth: Int {
        let offset = getMonthOffset()
        return pickerview.selectedRow(inComponent: 1) + offset
    }
    
    /// 分割线views
    fileprivate var separatorLines: [UIView] {
        return pickerview.subviews.filter {
            $0.bounds.height < 1.0 && $0.bounds.width == pickerview.bounds.width
        }
    }
    
    fileprivate func getMonthOffset() -> Int {
        let minYear  = minDate.intValueOf(.year)
        let minMonth = minDate.intValueOf(.month)
        let offset = (currentYear == minYear) ? minMonth : 1
        return offset
    }
    
    fileprivate func getDayOffset() -> Int {
        let minYear  = minDate.intValueOf(.year)
        let minMonth = minDate.intValueOf(.month)
        let offset = (currentYear == minYear && currentMonth == minMonth) ? minDate.intValueOf(.day) : 1
        return offset
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerview.frame = self.bounds
    }
}

extension CCDatePicker: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return pickerView.bounds.width * 0.45 // 根据字符宽度测得比例
        case 1: return pickerView.bounds.width * 0.5 * (1 - 0.45)
        default:return pickerView.bounds.width * 0.5 * (1 - 0.45)
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var ostr = ""
        switch component {
        case 0: ostr = String(minDate.intValueOf(.year) + row) + "年"
        case 1:
            ostr = String(row + getMonthOffset()) + "月"
        case 2:
            ostr = String(row + getDayOffset()) + "日"
        default: break
        }
        let attStr = NSMutableAttributedString(string: ostr)
        let range  = NSRange(location: 0, length: ostr.count)
        attStr.addAttributes([.foregroundColor: titleColor, .font: titleFont], range: range)
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
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
        case 1:
            pickerView.reloadComponent(2)
        default: break
        }
        self.delegate?.didSelectDate(at: self)
    }
}

extension CCDatePicker: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // 年月日
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let maxYearInt  = maxDate.intValueOf(.year)
        let maxMonthInt = maxDate.intValueOf(.month)
        
        let minYearInt  = minDate.intValueOf(.year)
        let minMonthInt = minDate.intValueOf(.month)
        
        switch component {
        case 0: return (maxYearInt - minYearInt) + 1
        case 1:
            if (currentYear == maxYearInt) {
                return maxMonthInt
            } else if (currentYear == minYearInt) {
                return 12 - minMonthInt + 1
            }
            return 12
        case 2:
            let fullDays = Date.fullDaysOfMonth(currentMonth, year: currentYear)
            if (currentYear == maxYearInt && currentMonth == maxMonthInt){
                return maxDate.intValueOf(.day)
            } else if (currentYear == minYearInt && currentMonth == minMonthInt) {
                return fullDays - minDate.intValueOf(.day) + 1
            }
            return fullDays
        default: return 0
        }
    }
}

fileprivate extension Date {
    static var defaultFormatter: DateFormatter {
        return self.dateFormatterWith("yyyy-MM-dd")
    }
    /// 自定义时间格式的格式化器
    static func dateFormatterWith(_ formatString: String) -> DateFormatter {
        let threadDic = Thread.current.threadDictionary
        if let fmt = threadDic.object(forKey: formatString) as? DateFormatter {
            return fmt
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        threadDic.setObject(dateFormatter, forKey: formatString as NSCopying)
        return dateFormatter
    }
    
    /// 特定年月的天数
    static func fullDaysOfMonth(_ month: Int, year: Int) -> Int {
        if [1, 3, 5, 7, 8, 10, 12].contains(month) { return 31 }
        if [4, 6, 9, 11].contains(month) { return 30 }
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
        return isLeapYear ? 29 : 28 // 二月
    }
    
    func intValueOf(_ component: Calendar.Component) -> Int {
        return NSCalendar.current.component(component, from: self)
    }
}
