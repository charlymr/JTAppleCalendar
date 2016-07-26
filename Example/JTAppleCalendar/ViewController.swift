//
//  ViewController.swift
//  testApplicationCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import JTAppleCalendar

class ViewController: UIViewController {
    var numberOfRows = 6
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    let formatter = DateFormatter()
    let testCalendar: Calendar! = Calendar(calendarIdentifier: Calendar.Identifier.gregorian)
    
    @IBAction func changeToThreeRows(_ sender: UIButton) {
        numberOfRows = 3
        calendarView.reloadData()
    }
    
    @IBAction func changeToSixRows(_ sender: UIButton) {
        numberOfRows = 6
        calendarView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy MM dd"
        testCalendar.timeZone = TimeZone(abbreviation: "GMT")!

        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        // Registering your cells is manditory   ******************************************************
        
        calendarView.registerCellViewXib(fileName: "CellView") // Registering your cell is manditory
//         calendarView.registerCellViewClass(fileName: "JTAppleCalendar_Example.CodeCellView")
        
        // ********************************************************************************************
        
        
        // Enable the following code line to show headers. There are other lines of code to uncomment as well
         calendarView.registerHeaderViewXibs(fileNames: ["PinkSectionHeaderView", "WhiteSectionHeaderView"]) // headers are Optional. You can register multiple if you want.
        
        // The following default code can be removed since they are already the default.
        // They are only included here so that you can know what properties can be configured
        calendarView.direction = .horizontal                       // default is horizontal
        calendarView.cellInset = CGPoint(x: 0, y: 0)               // default is (3,3)
        calendarView.allowsMultipleSelection = false               // default is false
        calendarView.bufferTop = 0                                 // default is 0. - still work in progress on this
        calendarView.bufferBottom = 0                              // default is 0. - still work in progress on this
        calendarView.firstDayOfWeek = .sunday                      // default is Sunday
        calendarView.scrollEnabled = true                          // default is true
        calendarView.pagingEnabled = true                          // default is true
        calendarView.scrollResistance = 0.75                       // default is 0.75 - this is only applicable when paging is not enabled.
        calendarView.itemSize = nil                                // default is nil. Use a value here to change the size of your cells
        calendarView.cellSnapsToEdge = true                        // default is true. Disabling this causes calendar to not snap to grid
        calendarView.reloadData()
        
        // After reloading. Scroll to your selected date, and setup your calendar
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false) {
            let currentDate = self.calendarView.currentCalendarDateSegment()
            self.setupViewsOfCalendar(currentDate.startDate, endDate: currentDate.endDate)
        }
    }
    
    @IBAction func select11(_ sender: AnyObject?) {
        calendarView.allowsMultipleSelection = false
        let date = formatter.date(from: "2016 02 11")
        self.calendarView.selectDates([date!], triggerSelectionDelegate: false)
    }
    
    @IBAction func scrollToDate(_ sender: AnyObject?) {
        let date = formatter.date(from: "2016 03 11")
        calendarView.scrollToDate(date!)
    }
    
    @IBAction func printSelectedDates() {
        print("Selected dates --->")
        for date in calendarView.selectedDates {
            print(formatter.string(from: date))
        }
    }

    @IBAction func next(sender: UIButton) {
        self.calendarView.scrollToNextSegment()
        
    }
    @IBAction func previous(sender: UIButton) {
        self.calendarView.scrollToPreviousSegment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupViewsOfCalendar(_ startDate: Date, endDate: Date) {
        let month = testCalendar.component(Calendar.Unit.month, from: startDate)
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = Calendar.current.component(Calendar.Unit.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
}

// MARK : JTAppleCalendarDelegate
extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) {
        
        let firstDate = formatter.date(from: "2016 01 01")
        let secondDate = Date()
        let aCalendar = Calendar.current // Properly configure your calendar to your time zone here
        return (startDate: firstDate!, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }

    func calendar(_ calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date as Date)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        printSelectedDates()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView) {
        (cell as? CellView)?.selectedView.isHidden = true
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        setupViewsOfCalendar(startDate as Date, endDate: endDate as Date)
    }
    
    func calendar(calendar: JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String? {
        let comp = testCalendar.component(.month, from: date.startDate as Date)
        if comp % 2 > 0{
            return "WhiteSectionHeaderView"
        }
        return "PinkSectionHeaderView"
    }
   
    func calendar(calendar: JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize {
        if testCalendar.component(.month, from: date.startDate as Date) % 2 == 1 {
            return CGSize(width: 200, height: 50)
        } else {
            return CGSize(width: 200, height: 100) // Yes you can have different size headers
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) {
        switch identifier {
        case "WhiteSectionHeaderView":
            let headerCell = (header as? WhiteSectionHeaderView)
            headerCell?.title.text = "Design multiple headers"
        default:
            let headerCell = (header as? PinkSectionHeaderView)
            headerCell?.title.text = "In any color or size you want"
        }
    }
}


func delayRunOnMainThread(_ delay:Double, closure:()->()) {
    DispatchQueue.main.after(
        when: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
