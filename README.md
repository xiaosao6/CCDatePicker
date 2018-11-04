# CCDatePicker
仿造原生UIDatePicker的自定义年月日选择器，可自定义外观



---
# CCDatePicker
-------------

### 效果:
![image](https:)



### 示例:  
```Swift
let datepicker = CCDatePicker.init(frame: frame)
datepicker.delegate = self
self.view.addSubview(datepicker)
   
datepicker.setDate(Date())
```

Delegate：

```Swift
extension ViewController: CCDatePickerDelegate {
    func didSelectDate(at picker: CCDatePicker) {
    	
    }
}
```

### 特性
- 内部使用`UIPickerView`实现
- 可配置项: 文字字体、文字颜色、行高、分割线颜色、日期上下限，可设定/获取当前日期。


### 使用方法
直接下载工程，引用`CCDatePicker`，配置参数后即可使用

### 注意事项
- iOS 8.0+,   Swift 4.0

## License
none

