# CCDatePicker
仿造原生UIDatePicker的自定义年月日选择器，可自定义外观



---
# CCDatePicker
-------------

### 效果:
<img src="https://raw.githubusercontent.com/xiaosao6/CCDatePicker/master/SnapShot.png" width = "300" height = "240" />



### 示例:  
```Swift
let minDate = Date().addingTimeInterval((365 * 24 * 60 * 60) * -10)
let maxDate = Date().addingTimeInterval((  1 * 24 * 60 * 60))
let datepicker = CCDatePicker.init(minDate: minDate, maxDate: maxDate)!
datepicker.frame = frame
datepicker.delegate = self
self.view.addSubview(datepicker)
datepicker.setDate(Date())

```

Delegate：

```Swift
extension ViewController: CCDatePickerDelegate {
    func didSelectDate(at picker: CCDatePicker) {
        let description = picker.currentDate.description(with: Locale.current)
        NSLog(description)
    }
}
```

### 特性
- 内部使用`UIPickerView`实现
- 可配置项: 单位字符、文字字体、文字颜色、行高、分割线颜色、日期上下限，可设定/获取当前日期。


### 使用方法
直接下载工程，引用`CCDatePicker`，配置参数后即可使用

### 注意事项
- iOS 8.0+,   Swift 4.0

## License
none

