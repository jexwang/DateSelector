//
//  DateSelector.swift
//  DateSelector
//
//  Created by Jay on 2017/9/30.
//
//

import UIKit

open class DateSelectorViewController: UIViewController {
    
    open let date: Date
    
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
    
    @IBOutlet weak open var delegate: DateSelectorDelegate?
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustContainerCollectionViewFlowLayout), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        prevDateButtonInit()
        nextDateButtonInit()
        dateButtonInit()
        dateSelectorViewInit()
        dateSelectorMaskViewInit()
    }
    
    @objc private func adjustContainerCollectionViewFlowLayout() {
        if let containerCollectionView = containerCollectionView {
            let flowLayout = containerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = containerCollectionView.frame.size
            containerCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    open func setLocale(identifier: String) {
        locale = identifier
    }
    
    private func prevDateButtonInit() {
        prevDateButton = UIButton()
        prevDateButton.setTitle(prevDateButtonSetting.title, for: .normal)
        prevDateButton.setTitleColor(textColor, for: .normal)
        prevDateButton.setImage(prevDateButtonSetting.image, for: .normal)
        prevDateButton.addTarget(self, action: #selector(prevDateButtonClick), for: .touchUpInside)
        addSubview(prevDateButton)
        prevDateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: prevDateButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: prevDateButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: prevDateButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        if frame.height < frame.width / 4 {
            NSLayoutConstraint(item: prevDateButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0).isActive = true
        } else {
            NSLayoutConstraint(item: prevDateButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.25, constant: 0).isActive = true
        }
    }
    
    @objc private func prevDateButtonClick() {
        if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: date) {
            date = newDate
        }
        
        if let containerCollectionView = containerCollectionView {
            containerCollectionView.prevDate()
        }
    }
    
    open func setPrevDateButton(title: String?, image: UIImage?) {
        prevDateButtonSetting = (title, image)
    }
    
    private func nextDateButtonInit() {
        nextDateButton = UIButton()
        nextDateButton.setTitle(nextDateButtonSetting.title, for: .normal)
        nextDateButton.setTitleColor(textColor, for: .normal)
        nextDateButton.setImage(nextDateButtonSetting.image, for: .normal)
        nextDateButton.addTarget(self, action: #selector(nextDateButtonClick), for: .touchUpInside)
        addSubview(nextDateButton)
        nextDateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nextDateButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: nextDateButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: nextDateButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        if frame.height < frame.width / 4 {
            NSLayoutConstraint(item: nextDateButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0).isActive = true
        } else {
            NSLayoutConstraint(item: nextDateButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.25, constant: 0).isActive = true
        }
    }
    
    @objc private func nextDateButtonClick() {
        if let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: date) {
            date = newDate
        }
        
        if let containerCollectionView = containerCollectionView {
            containerCollectionView.nextDate()
        }
    }
    
    open func setNextDateButton(title: String?, image: UIImage?) {
        nextDateButtonSetting = (title, image)
    }
    
    private func dateButtonInit() {
        dateButton = UIButton()
        dateButton.setTitle(dateConvertToString(), for: .normal)
        dateButton.setTitleColor(textColor, for: .normal)
        dateButton.addTarget(self, action: #selector(dateButtonClick), for: .touchUpInside)
        addSubview(dateButton)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: dateButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateButton, attribute: .left, relatedBy: .equal, toItem: prevDateButton, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateButton, attribute: .right, relatedBy: .equal, toItem: nextDateButton, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    @objc private func dateButtonClick() {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else {
            return
        }
        
        guard let view = window.rootViewController?.view else {
            return
        }
        
        view.addSubview(dateSelectorMaskView)
        dateSelectorMaskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: dateSelectorMaskView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateSelectorMaskView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateSelectorMaskView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateSelectorMaskView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        view.bringSubview(toFront: dateSelectorView)
        
        dateSelectorView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.dateSelectorView.transform = CGAffineTransform(translationX: 0, y: -self.dateSelectorView.frame.height)
        }
    }
    
    private func dateSelectorViewInit() {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else {
            return
        }
        
        guard let view = window.rootViewController?.view else {
            return
        }
        
        dateSelectorView = DateSelectorView(frame: CGRect(x:0, y: UIScreen.main.bounds.maxY, width: UIScreen.main.bounds.width, height: 306))
        dateSelectorView.delegate = self
        dateSelectorView.backgroundColor = .white
        dateSelectorView.isHidden = true
        view.addSubview(dateSelectorView)
        dateSelectorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: dateSelectorView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateSelectorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 306).isActive = true
        NSLayoutConstraint(item: dateSelectorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateSelectorView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    open func setCancelButton(title: String?, image: UIImage?) {
        cancelButtonSetting = (title, image)
    }
    
    open func setDoneButton(title: String?, image: UIImage?) {
        doneButtonSetting = (title, image)
    }
    
    open func setTitleLabel(title: String) {
        titleLabelSetting = title
    }
    
    open func setTodayButton(title: String?, titleColor: UIColor?, image: UIImage?) {
        todayButtonSetting = (title, titleColor, image)
    }
    
    private func dateSelectorMaskViewInit() {
        dateSelectorMaskView = UIView()
        dateSelectorMaskView?.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dateSelectorMaskView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateSelectorMaskViewTap)))
    }
    
    @objc private func dateSelectorMaskViewTap() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dateSelectorView.transform = .identity
        }) { _ in
            self.dateSelectorView.isHidden = true
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
    
    open func getDate() -> Date {
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
        toolbarView = UIView()
        toolbarView.backgroundColor = delegate?.themeColor
        addSubview(toolbarView)
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: toolbarView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbarView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbarView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
    }
    
    private func cancelButtonInit() {
        cancelButton = UIButton()
        cancelButton.setTitle(delegate?.cancelButtonSetting.title, for: .normal)
        cancelButton.setTitleColor(delegate?.textColor, for: .normal)
        cancelButton.setImage(delegate?.cancelButtonSetting.image, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        toolbarView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: toolbarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: toolbarView, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: toolbarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: toolbarView, attribute: .height, multiplier: 1.5, constant: 0).isActive = true
    }
    
    @objc private func cancelButtonClick() {
        putDownDateSelectorView()
    }
    
    private func doneButtonInit() {
        doneButton = UIButton()
        doneButton.setTitle(delegate?.doneButtonSetting.title, for: .normal)
        doneButton.setTitleColor(delegate?.textColor, for: .normal)
        doneButton.setImage(delegate?.doneButtonSetting.image, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        toolbarView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: toolbarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: doneButton, attribute: .right, relatedBy: .equal, toItem: toolbarView, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: toolbarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: toolbarView, attribute: .height, multiplier: 1.5, constant: 0).isActive = true
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
        titleLabel.text = delegate?.titleLabelSetting
        titleLabel.textColor = delegate?.textColor
        titleLabel.textAlignment = .center
        toolbarView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: toolbarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: cancelButton, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: doneButton, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: toolbarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    private func todayButtonInit() {
        todayButton = UIButton(type: .system)
        todayButton.setTitle(delegate?.todayButtonSetting.title, for: .normal)
        todayButton.setTitleColor(delegate?.todayButtonSetting.textColor, for: .normal)
        todayButton.setImage(delegate?.todayButtonSetting.image, for: .normal)
        todayButton.addTarget(self, action: #selector(todayButtonClick), for: .touchUpInside)
        addSubview(todayButton)
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: todayButton, attribute: .top, relatedBy: .equal, toItem: toolbarView, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: todayButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: todayButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: todayButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true
    }
    
    @objc private func todayButtonClick() {
        if let datePicker = datePicker {
            datePicker.setDate(Date(), animated: true)
        }
    }
    
    private func datePickerInit() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if let locale = delegate?.locale {
            datePicker.locale = Locale(identifier: locale)
        }
        addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: datePicker, attribute: .top, relatedBy: .equal, toItem: todayButton, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: datePicker, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: datePicker, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: datePicker, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    private func putDownDateSelectorView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = .identity
        }) { _ in
            self.isHidden = true
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
        flowLayout.itemSize = rect.size
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
            NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view!, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view!, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        }
    }
}
