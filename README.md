# DateSelector

可簡單的使用 UIView 製作出選擇日期的工具，並將選中的日期反映在客製化的頁面上。

### 範例圖片：
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo1.png?raw=true)
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo2.png?raw=true)

### 使用方法：
於 StoryBoard 新增一 UIView 作為日期選擇器（即為範例圖片中深灰色底的物件）並設定所要的大小後，將 class 改為 DateSelector，待 StoryBoard 更新完成後可接著於右邊的屬性區塊設定主題顏色、文字顏色和日期格式（如下圖左），最後記得將 delegate 設定給 viewController (XCode8 以下的版本需先設定 outlet 後再用程式碼指定 delegate)。
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo3.png?raw=true)
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo4.png?raw=true)

以上設定完成後接著繼續撰寫程式碼，首先

    import DateSelector
    
，並讓 ViewController 繼承 DateSelectorDelegate，之後即可使用

    func dateSelector(didChange oldDate: Date, to newDate: Date) {
        
    }
    
來取得異動後的日期，若需要 **立刻取得當前日期** 可將 DateSelector 設定 outlet 後使用 getDate() 取得。

    @IBOutlet weak var dateSelector: DateSelector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(dateSelector.getDate())
    }

