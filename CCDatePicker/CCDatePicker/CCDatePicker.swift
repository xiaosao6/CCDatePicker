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
    
    /// 行高
    var rowHeight: CGFloat = 44
    
    /// 分割线颜色
    var separatorColor = UIColor.lightGray {
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { // 立即刷新
                self.separatorLines.forEach { $0.backgroundColor = self.separatorColor }
            }
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
    }
}

extension CCDatePicker: CCDateSelectionDelegate {
    func currentYearInt() -> Int {
        let row = pickerview.selectedRow(inComponent: 0)
        let attrStr = self.pickerView(pickerview, attributedTitleForRow: row, forComponent: 0)
        let value: Int = attrStr?.string.cc_getInt() ?? 1
        return value
    }
    
    func currentMonthInt() -> Int {
        let row = pickerview.selectedRow(inComponent: 1)
        let attrStr = self.pickerView(pickerview, attributedTitleForRow: row, forComponent: 1)
        let value: Int = attrStr?.string.cc_getInt() ?? 1
        return value
    }
    
    func currentDayInt() -> Int {
        let row = pickerview.selectedRow(inComponent: 2)
        let attrStr = self.pickerView(pickerview, attributedTitleForRow: row, forComponent: 2)
        let value: Int = attrStr?.string.cc_getInt() ?? 1
        return value
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
                pickerview.selectRow(mRow, inComponent: 1, animated: false)
                self.pickerView(pickerView, didSelectRow: mRow, inComponent: 1)
            }
        case 1:
            if let dRow = manager?.onMonthRefreshed() {
                pickerview.selectRow(dRow, inComponent: 2, animated: false)
                self.pickerView(pickerView, didSelectRow: dRow, inComponent: 2)
            }
        case 2:
            pickerView.reloadAllComponents()
            self.delegate?.didSelectDate(at: self)
        default: break
        }
    }
}

extension CCDatePicker: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // 年月日
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rowCount = self.dataSource?.datepicker(self, numberOfRowsInComponent: component) ?? 0
        return rowCount
    }
}

extension String {
    fileprivate func cc_getInt() -> Int {
        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number: Int = 0
        scanner.scanInt(&number)
        return number
    }
}
