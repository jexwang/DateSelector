//
//  DateSelector.swift
//  DateSelector
//
//  Created by Jay on 2017/9/30.
//
//

import UIKit

open class DateSelectorViewController: UIViewController {
    
    var date: Date
    
    required public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, date: Date) {
        self.date = date
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc public protocol DateSelectorDelegate {
    @objc optional func dateSelectorSetViewController() -> DateSelectorViewController.Type
    @objc optional func dateSelector(willChange oldDate: Date, to newDate: Date)
    @objc optional func dateSelector(didChange oldDate: Date, to newDate: Date)
}

@IBDesignable open class DateSelector: UIView, DateSelectorViewDelegate {
    
    @IBInspectable open var themeColor: UIColor! {
        didSet {
            backgroundColor = themeColor
        }
    }
    @IBInspectable open var textColor: UIColor = .black
    @IBInspectable open var dateFormat: String = "yyyy-M-d (eeeee)"
    
    fileprivate var date: Date = Date() {
        willSet {
            delegate?.dateSelector?(willChange: date, to: newValue)
        }
        
        didSet {
            dateButton.setTitle(dateConvertToString(), for: .normal)
            delegate?.dateSelector?(didChange: oldValue, to: date)
        }
    }
    
    weak var delegate: DateSelectorDelegate?
    @IBOutlet weak var containerCollectionView: DateSelectorCollectionView?
    
    private var prevDateButton: UIButton!
    private var prevDateButtonSetting: (title: String?, image: UIImage?) = ("<", nil)
    private var nextDateButton: UIButton!
    private var nextDateButtonSetting: (title: String?, image: UIImage?) = (">", nil)
    private var dateButton: UIButton!
    private var dateSelectorView: DateSelectorView!
    
    fileprivate var dateSelectorMaskView: UIView!
    fileprivate var cancelButtonSetting: (title: String?, image: UIImage?) = ("Cancel", nil)
    fileprivate var doneButtonSetting: (title: String?, image: UIImage?) = ("Done", nil)
    fileprivate var titleLabelSetting: String? = "Select Date"
    fileprivate var todayButtonSetting: (title: String?, textColor: UIColor?, image: UIImage?) = ("Today", nil, nil)
    fileprivate var locale: String?
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        prevDateButtonInit()
        nextDateButtonInit()
        dateButtonInit()
        dateSelectorViewInit()
        dateSelectorMaskViewInit()
    }
    
    func setLocale(identifier: String) {
        locale = identifier
    }
    
    private func prevDateButtonInit() {
        prevDateButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.height, height: frame.height))
        if prevDateButton.frame.width > frame.width / 4 {
            prevDateButton.frame.size.width = frame.width / 4
        }
        prevDateButton.setTitle(prevDateButtonSetting.title, for: .normal)
        prevDateButton.setTitleColor(textColor, for: .normal)
        prevDateButton.setImage(prevDateButtonSetting.image, for: .normal)
        prevDateButton.addTarget(self, action: #selector(prevDateButtonClick), for: .touchUpInside)
        addSubview(prevDateButton)
    }
    
    @objc private func prevDateButtonClick() {
        if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: date) {
            date = newDate
        }
        
        if let containerCollectionView = containerCollectionView {
            containerCollectionView.prevDate()
        }
    }
    
    func setPrevDateButton(title: String?, image: UIImage?) {
        prevDateButtonSetting = (title, image)
    }
    
    private func nextDateButtonInit() {
        nextDateButton = UIButton()
        nextDateButton.frame.size = CGSize(width: frame.height, height: frame.height)
        if nextDateButton.frame.width > frame.width / 4 {
            nextDateButton.frame.size.width = frame.width / 4
        }
        nextDateButton.frame.origin = CGPoint(x: frame.width - nextDateButton.frame.width, y: 0)
        nextDateButton.setTitle(nextDateButtonSetting.title, for: .normal)
        nextDateButton.setTitleColor(textColor, for: .normal)
        nextDateButton.setImage(nextDateButtonSetting.image, for: .normal)
        nextDateButton.addTarget(self, action: #selector(nextDateButtonClick), for: .touchUpInside)
        addSubview(nextDateButton)
    }
    
    @objc private func nextDateButtonClick() {
        if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: date) {
            date = newDate
        }
        
        if let containerCollectionView = containerCollectionView {
            containerCollectionView.nextDate()
        }
    }
    
    func setNextDateButton(title: String?, image: UIImage?) {
        nextDateButtonSetting = (title, image)
    }
    
    private func dateButtonInit() {
        dateButton = UIButton()
        dateButton.frame.size = CGSize(width: frame.width - prevDateButton.frame.width - nextDateButton.frame.width, height: frame.height)
        dateButton.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        dateButton.setTitle(dateConvertToString(), for: .normal)
        dateButton.setTitleColor(textColor, for: .normal)
        dateButton.addTarget(self, action: #selector(dateButtonClick), for: .touchUpInside)
        addSubview(dateButton)
    }
    
    @objc private func dateButtonClick() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appdelegate.window?.rootViewController?.view.addSubview(dateSelectorMaskView!)
        appdelegate.window?.rootViewController?.view.bringSubview(toFront: dateSelectorView)
        
        UIView.animate(withDuration: 0.2) {
            self.dateSelectorView.transform = CGAffineTransform(translationX: 0, y: -self.dateSelectorView.frame.height)
        }
    }
    
    private func dateSelectorViewInit() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        dateSelectorView = DateSelectorView(frame: CGRect(x:0, y: UIScreen.main.bounds.maxY, width: UIScreen.main.bounds.width, height: 306))
        dateSelectorView.delegate = self
        dateSelectorView.backgroundColor = .white
        appdelegate.window?.rootViewController?.view.addSubview(dateSelectorView)
    }
    
    func setCancelButton(title: String?, image: UIImage?) {
        cancelButtonSetting = (title, image)
    }
    
    func setDoneButton(title: String?, image: UIImage?) {
        doneButtonSetting = (title, image)
    }
    
    func setTitleLabel(title: String) {
        titleLabelSetting = title
    }
    
    func setTodayButton(title: String?, titleColor: UIColor?, image: UIImage?) {
        todayButtonSetting = (title, titleColor, image)
    }
    
    private func dateSelectorMaskViewInit() {
        dateSelectorMaskView = UIView(frame: UIScreen.main.bounds)
        dateSelectorMaskView?.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dateSelectorMaskView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateSelectorMaskViewTap)))
    }
    
    @objc private func dateSelectorMaskViewTap() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dateSelectorView.transform = .identity
        }) { _ in
            self.dateSelectorMaskView?.removeFromSuperview()
        }
    }
    
    private func dateConvertToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let locale = locale {
            dateFormatter.locale = Locale(identifier: locale)
        }
        return dateFormatter.string(from: date)
    }
    
    func getDate() -> Date {
        return date
    }
}

extension DateSelector: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DateSelectorCollectionViewCell
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? DateSelectorCollectionViewCell, let viewController = delegate?.dateSelectorSetViewController?() {
            switch indexPath.item {
            case 0:
                if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: date) {
                    cell.viewController = viewController.init(nibName: String(describing: viewController), bundle: nil, date: newDate)
                }
            case 1:
                cell.viewController = viewController.init(nibName: String(describing: viewController), bundle: nil, date: date)
            case 2:
                if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: date) {
                    cell.viewController = viewController.init(nibName: String(describing: viewController), bundle: nil, date: newDate)
                }
            default:
                break
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let dateSelectorCollectionView = scrollView as? DateSelectorCollectionView else {
            return
        }
        
        let visibleItems = dateSelectorCollectionView.indexPathsForVisibleItems
        var visibleItem: IndexPath
        if visibleItems.count > 1 {
            visibleItem = visibleItems.first(where: { (indexPath) -> Bool in
                return indexPath.row != 1
            })!
        } else {
            visibleItem = visibleItems.first!
        }
        
        switch visibleItem.row {
        case 0:
            if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: date) {
                date = newDate
            }
            
            UIView.setAnimationsEnabled(false)
            dateSelectorCollectionView.performBatchUpdates({
                dateSelectorCollectionView.deleteItems(at: [IndexPath(item: 2, section: 0)])
                dateSelectorCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                dateSelectorCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
            }, completion: { _ in
                UIView.setAnimationsEnabled(true)
            })
        case 2:
            if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: date) {
                date = newDate
            }
            
            UIView.setAnimationsEnabled(false)
            dateSelectorCollectionView.performBatchUpdates({
                dateSelectorCollectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
                dateSelectorCollectionView.insertItems(at: [IndexPath(item: 2, section: 0)])
                dateSelectorCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
            }, completion: { _ in
                UIView.setAnimationsEnabled(true)
            })
        default:
            break
        }
    }
}

fileprivate protocol DateSelectorViewDelegate {
    var themeColor: UIColor! { get }
    var textColor: UIColor { get }
    var date: Date { get set }
    var containerCollectionView: DateSelectorCollectionView? { get }
    var dateSelectorMaskView: UIView! { get set }
    var cancelButtonSetting: (title: String?, image: UIImage?) { get }
    var doneButtonSetting: (title: String?, image: UIImage?) { get }
    var titleLabelSetting: String? { get }
    var todayButtonSetting: (title: String?, textColor: UIColor?, image: UIImage?) { get }
    var locale: String? { get }
}

fileprivate class DateSelectorView: UIView {
    fileprivate var delegate: DateSelectorViewDelegate?
    private var toolbarView: UIView!
    private var cancelButton: UIButton!
    private var doneButton: UIButton!
    private var todayButton: UIButton!
    private var datePicker: UIDatePicker!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        toolbarViewInit()
        cancelButtonInit()
        doneButtonInit()
        titleLabelInit()
        todayButtonInit()
        datePickerInit()
    }
    
    private func toolbarViewInit() {
        toolbarView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        toolbarView.backgroundColor = delegate?.themeColor
        addSubview(toolbarView)
    }
    
    private func cancelButtonInit() {
        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: toolbarView.frame.height * 1.5, height: toolbarView.frame.height))
        cancelButton.setTitle(delegate?.cancelButtonSetting.title, for: .normal)
        cancelButton.setTitleColor(delegate?.textColor, for: .normal)
        cancelButton.setImage(delegate?.cancelButtonSetting.image, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        toolbarView.addSubview(cancelButton)
    }
    
    @objc private func cancelButtonClick() {
        putDownDateSelectorView()
    }
    
    private func doneButtonInit() {
        doneButton = UIButton(frame: CGRect(x: toolbarView.frame.width - toolbarView.frame.height * 1.5, y: 0, width: toolbarView.frame.height * 1.5, height: toolbarView.frame.height))
        doneButton.setTitle(delegate?.doneButtonSetting.title, for: .normal)
        doneButton.setTitleColor(delegate?.textColor, for: .normal)
        doneButton.setImage(delegate?.doneButtonSetting.image, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        toolbarView.addSubview(doneButton)
    }
    
    @objc private func doneButtonClick() {
        delegate?.date = datePicker.date
        if let containerCollectionView = delegate?.containerCollectionView {
            containerCollectionView.selectedDate()
        }
        putDownDateSelectorView()
    }
    
    private func titleLabelInit() {
        let titleLabel = UILabel()
        titleLabel.frame.size = CGSize(width: toolbarView.frame.width - (cancelButton.frame.width + doneButton.frame.width), height: toolbarView.frame.height)
        titleLabel.center = toolbarView.center
        titleLabel.text = delegate?.titleLabelSetting
        titleLabel.textColor = delegate?.textColor
        titleLabel.textAlignment = .center
        toolbarView.addSubview(titleLabel)
    }
    
    private func todayButtonInit() {
        todayButton = UIButton(type: .system)
        todayButton.frame = CGRect(x: 0, y: toolbarView.frame.height + 10, width: frame.width, height: 30)
        todayButton.setTitle(delegate?.todayButtonSetting.title, for: .normal)
        todayButton.setTitleColor(delegate?.todayButtonSetting.textColor, for: .normal)
        todayButton.setImage(delegate?.todayButtonSetting.image, for: .normal)
        todayButton.addTarget(self, action: #selector(todayButtonClick), for: .touchUpInside)
        addSubview(todayButton)
    }
    
    @objc private func todayButtonClick() {
        if let datePicker = datePicker {
            datePicker.setDate(Date(), animated: true)
        }
    }
    
    private func datePickerInit() {
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: toolbarView.frame.height + todayButton.frame.height, width: frame.width, height: frame.height - (toolbarView.frame.height + todayButton.frame.height)))
        datePicker.datePickerMode = .date
        if let locale = delegate?.locale {
            datePicker.locale = Locale(identifier: locale)
        }
        addSubview(datePicker)
    }
    
    private func putDownDateSelectorView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = .identity
        }) { _ in
            self.delegate?.dateSelectorMaskView?.removeFromSuperview()
        }
    }
}

open class DateSelectorCollectionView: UICollectionView {
    
    @IBOutlet weak open var dateSelector: DateSelector? {
        didSet {
            dataSource = dateSelector
            delegate = dateSelector
            reloadData()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register(DateSelectorCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        bounces = false
        scrollsToTop = false
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: frame.width, height: frame.height)
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    @objc internal func prevDate() {
        performBatchUpdates({ 
            self.deleteItems(at: [IndexPath(item: 2, section: 0)])
            self.insertItems(at: [IndexPath(item: 0, section: 0)])
        }, completion: nil)
    }
    
    @objc internal func nextDate() {
        performBatchUpdates({
            self.deleteItems(at: [IndexPath(item: 0, section: 0)])
            self.insertItems(at: [IndexPath(item: 2, section: 0)])
        }, completion: nil)
    }
    
    @objc internal func selectedDate() {
        reloadData()
    }
}

private class DateSelectorCollectionViewCell: UICollectionViewCell {
    var viewController: DateSelectorViewController? {
        didSet {
            view = viewController!.view!
        }
    }
    
    private var view: UIView? {
        willSet {
            if let view = view {
                view.removeFromSuperview()
            }
        }
        
        didSet {
            view!.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view!)
//            view!.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
//            view!.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
//            view!.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
//            view!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view!, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view!, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        }
    }
}
