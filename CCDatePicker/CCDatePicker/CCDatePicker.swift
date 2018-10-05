//
//  CCDatePicker.swift
//  CCDatePicker
//
//  Created by sischen on 2018/10/4.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit



class CCDatePicker: UIView {
    
    fileprivate let formatter = Date.dateFormatterWith("yyyy-MM-dd")
    
    /// 行高
    var rowHeight: CGFloat = 44 {
        didSet{
            pickerview.reloadAllComponents()
        }
    }
    
    /// 标题字体,默认17号
    var titleFont  = UIFont.systemFont(ofSize: 17)
    
    /// 标题颜色,默认darkGray
    var titleColor = UIColor.darkGray
    
    
    
    
    /// 最小的日期,默认1970
    var minDate = Date(timeIntervalSince1970: 0)
    
    /// 最大的日期,默认无限制
    var maxDate = Date.distantFuture
    
//    /// 当前的日期
//    var currentDate: Date {
//        return Date()
//    }
    
    
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
        let string = formatter.string(from: date)
        setDate(string, animated: animated)
    }
    
    func setDate(_ dateString: String, animated: Bool = false) {
        let components = dateString.components(separatedBy: "-")
        if components.count != 3 { return }
        let year  = Int(components.first ?? "") ?? minYear
        let month = Int(components[1]) ?? 1
        let day   = Int(components.last ?? "") ?? 1
        
        let yearRow  = (year - minYear) > 0 ? (year - minYear) : 0
        let monthRow = (month - 1) > 0 ? (month - 1) : 0
        let dayRow   = (day - 1) > 0 ? (day - 1) : 0
        
        pickerview.selectRow(yearRow, inComponent: 0, animated: animated)
        pickerview.selectRow(monthRow, inComponent: 1, animated: animated)
        pickerview.selectRow(dayRow, inComponent: 2, animated: animated)
        
        pickerview.reloadAllComponents()
    }
}

//MARK: ------------------------ Private

extension CCDatePicker{
    /// 当前年数值
    fileprivate var currentYear: Int {
        return pickerview.selectedRow(inComponent: 0) + minYear
    }
    /// 当前月数值
    fileprivate var currentMonth: Int {
        return pickerview.selectedRow(inComponent: 1) + 1
    }
    
    /// 最小的年份数值
    fileprivate var minYear: Int{
        let string = formatter.string(from: minDate)
        let components = string.components(separatedBy: "-").first!
        let resultInt = Int(components) ?? 1970
        return resultInt
    }
    
    /// 特定年月的天数
    fileprivate func fullDaysOfMonth(_ month: Int, year: Int) -> Int {
        if [1, 3, 5, 7, 8, 10, 12].contains(month) {
            return 31
        } else if [4, 6, 9, 11].contains(month) {
            return 30
        }
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
        return isLeapYear ? 29 : 28 // 二月份
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
        case 0: ostr = String(minYear + row) + "年"
        case 1: ostr = String(1 + row) + "月"
        case 2: ostr = String(1 + row) + "日"
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
        newlabel.adjustsFontSizeToFitWidth = true
        newlabel.textAlignment = NSTextAlignment.center
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
    }
}

extension CCDatePicker: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // 年月日
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let maxYearInt  = NSCalendar.current.component(.year, from: maxDate)
        let maxMonthInt = NSCalendar.current.component(.month, from: maxDate)
        let maxDayInt   = NSCalendar.current.component(.day, from: maxDate)
        
        switch component {
        case 0: return (maxYearInt - minYear) + 1
        case 1: return (currentYear == maxYearInt) ? maxMonthInt : 12
        case 2:
            let fullDays = fullDaysOfMonth(currentMonth, year: currentYear)
            return (currentYear == maxYearInt && currentMonth == maxMonthInt) ? maxDayInt : fullDays
        default: return 0
        }
    }
}

fileprivate extension Date {
    /// 自定义时间格式的格式化器
    static func dateFormatterWith(_ formatString: String) -> DateFormatter {
        let threadDic = Thread.current.threadDictionary
        var dateFormatter = threadDic.object(forKey: formatString) as? DateFormatter
        if dateFormatter == nil {
            dateFormatter = DateFormatter.init()
            dateFormatter?.dateFormat = formatString
            threadDic.setObject(dateFormatter!, forKey: formatString as NSCopying)
        }
        return dateFormatter!
    }
}
