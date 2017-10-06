# DateSelector

可簡單的使用 UIView 製作出選擇日期的工具，並將選中的日期反映在客製化的頁面上。
進階功能可讓客製化的頁面帶有左右滑動切換日期之功能。

### 範例圖片：

![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo1.png?raw=true)
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo2.png?raw=true)

### 使用方法：

於 StoryBoard 新增一 UIView 作為日期選擇器（即為範例圖片中深灰色底的物件）並設定所要的大小後，將 class 改為 DateSelector，待 StoryBoard 更新完成後可接著於右邊的屬性區塊設定主題顏色、文字顏色和日期格式（如下圖），最後記得將 delegate 設定給 viewController (XCode8 以下的版本需先設定 outlet 後再用程式碼指定 delegate)。

![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo3.png?raw=true)
-
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo4.png?raw=true)

以上設定完成後接著撰寫程式碼，首先 import 套件

    import DateSelector
    
再讓 ViewController 繼承 DateSelectorDelegate，之後即可使用 dateSelector 方法來取得異動後的日期

    class ViewController: UIViewController, DateSelectorDelegate {
    
        func dateSelector(didChange oldDate: Date, to newDate: Date) {
            print(newDate)
        }
    }
    
若需要 **立刻取得當前日期** 可將 DateSelector 設定 outlet 後使用 getDate() 取得。

    @IBOutlet weak var dateSelector: DateSelector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dateSelector.getDate())
    }

### 進階用法：

於 StoryBoard 額外新增一 UICollectionView 作為客製化頁面的容器並設定好 AutoLayout（此為客製化頁面的最終位置與大小），接著設定 class 為 DateSelectorCollectionView，預設帶有的 Cell 可以刪除不會用到，再對 DateSelectorCollectionView 按右鍵將 DateSelector 連結至先前做好的 DateSelector，同時將 DateSelector 的 ContainerCollectionView 也連結至 DateSelectorCollectionView。

![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo5.png?raw=true)
-
![image](https://github.com/jexwang/DateSelector/blob/master/DemoImage/DateSelectorDemo6.png?raw=true)

新增一個 CocoaTouchClass，Subclass 使用 DateSelectorViewController 並將創建 XIB 選項打勾，客製化頁面於此 class 實作並記得 import DateSelector，實作完成後再於先前的 ViewController 將此 class 用以下方法回傳即可！

    func dateSelectorSetViewController() -> DateSelectorViewController.Type {
        return CustomViewController.self
    }
