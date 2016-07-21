//
//  UserInteractionFunctions.swift
//  Pods
//
//  Created by Jay Thomas on 2016-05-12.
//
//


extension JTAppleCalendarView {
    /// Returns the cellStatus of a date that is visible on the screen. If the row and column for the date cannot be found, then nil is returned
    /// - Paramater row: Int row of the date to find
    /// - Paramater column: Int column of the date to find
    /// - returns:
    ///     - CellState: The start date of the current section
    public func cellStatusForDateAtRow(_ row: Int, column: Int) -> CellState? {
        if // the row or column falls within an invalid range
            row < 0 || row >= cachedConfiguration.numberOfRows ||
                column < 0 || column >= MAX_NUMBER_OF_DAYS_IN_WEEK {
            return nil
        }
        
        let Offset: Int
        let convertedRow: Int
        let convertedSection: Int
        if direction == .horizontal {
            Offset = Int(round(calendarView.contentOffset.x / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.width))
            convertedRow = (row * MAX_NUMBER_OF_DAYS_IN_WEEK) + ((column + Offset) % MAX_NUMBER_OF_DAYS_IN_WEEK)
            convertedSection = (Offset + column) / MAX_NUMBER_OF_DAYS_IN_WEEK
        } else {
            Offset = Int(round(calendarView.contentOffset.y / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.height))
            convertedRow = ((row * MAX_NUMBER_OF_DAYS_IN_WEEK) +  column + (Offset * MAX_NUMBER_OF_DAYS_IN_WEEK)) % (MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows)
            convertedSection = (Offset + row) / cachedConfiguration.numberOfRows
        }
        
        let indexPathToFind = IndexPath(item: convertedRow, section: convertedSection)
        if let  date = dateFromPath(indexPathToFind) {
            let stateOfCell = cellStateFromIndexPath(indexPath: indexPathToFind, withDate: date)
            return stateOfCell
        }
        return nil
    }
    
    public func cellStatusForDate(date: NSDate)-> CellState? {
        // validate the path
        let paths = pathsFromDates([date as Date])
        if paths.count < 1 { return nil }
        
        let stateOfCell = cellStateFromIndexPath(indexPath: paths[0], withDate: date)
        return stateOfCell
    }
    
    /// Returns the calendar view's current section boundary dates.
    /// - returns:
    ///     - startDate: The start date of the current section
    ///     - endDate: The end date of the current section
    public func currentCalendarDateSegment() -> (startDate: Date, endDate: Date) {
        guard let dateSegment = dateFromSection(currentSectionPage) else {
            assert(false, "Error in currentCalendarDateSegment method. Report this issue to Jay on github.")
            return (Date(), Date())
        }
        return dateSegment
    }
    
    /// Let's the calendar know which cell xib to use for the displaying of it's date-cells.
    /// - Parameter name: The name of the xib of your cell design
    public func registerCellViewXib(fileName name: String) {
        cellViewSource = JTAppleCallendarCellViewSource.fromXib(name)
    }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The class name of your cell design
    public func registerCellViewClass(fileName name: String) {
        cellViewSource = JTAppleCallendarCellViewSource.fromClassName(name)
    }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The type of your cell design
    public func registerCellViewClass(cellClass: AnyClass) {
        cellViewSource = JTAppleCallendarCellViewSource.fromType(cellClass)
    }
    
    
    /// Register header views with the calender. This needs to be done before the view can be displayed
    /// - Parameter fileNames: A dictionary containing [headerViewNames:HeaderviewSizes]
    public func registerHeaderViewXibs(fileNames headerViewXibNames: [String]) {
        headerViewXibs.removeAll() // remove the already registered xib files if the user re-registers again.
        
        if headerViewXibNames.count < 1 {
            return
        }

        for headerViewXibName in headerViewXibNames {
            let viewObject = Bundle.main.loadNibNamed(headerViewXibName, owner: self, options: [:])
            assert(viewObject?.count > 0, "your nib file name \(headerViewXibName) could not be loaded)")
            
            guard viewObject?[0] is JTAppleHeaderView else {
                assert(false, "xib file class does not conform to the protocol<JTAppleHeaderViewProtocol>")
                return
            }
            
            headerViewXibs.append(headerViewXibName)
            
            self.calendarView.register(JTAppleCollectionReusableView.self,
                                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: headerViewXibName)
        }
    }
    
    /// Reloads the data on the calendar view. Scroll delegates are not triggered with this function.
    public func reloadData(withAnchorDate date:Date? = nil, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        reloadData(checkDelegateDataSource: true, withAnchorDate: date, withAnimation: animation, completionHandler: completionHandler)
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified dates will be reloaded
    public func reloadDates(_ dates: [Date]) {
        reloadIndexPathsIfVisible(pathsFromDates(dates))
    }
    
    /// Select a date-cell range
    /// - Parameter startDate: Date to start the selection from
    /// - Parameter endDate: Date to end the selection from
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(from startDate:Date, to endDate:Date, triggerSelectionDelegate: Bool = true) {
        selectDates(generatedDateRange(from: startDate, to: endDate), triggerSelectionDelegate: triggerSelectionDelegate)
    }
    
    /// Select a date-cells
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(_ dates: [NSDate], triggerSelectionDelegate: Bool = true) {
        var allIndexPathsToReload: [IndexPath] = []
        for date in dates {
            let components = self.calendar.components([.year, .month, .day],  from: date as Date)
            let firstDayOfDate = self.calendar.date(from: components)!
            
            if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                // If the date is not within valid boundaries, then exit
                continue
            }
            
            let pathFromDates = self.pathsFromDates([date as Date])
            
            // If the date path youre searching for, doesnt exist, then return
            if pathFromDates.count < 0 {
                continue
            }
            
            let sectionIndexPath = pathFromDates[0]
            
            
            let selectTheDate = {
                delayRunOnMainThread(delay: 0.0) {
                    self.calendarView.selectItem(at: sectionIndexPath, animated: false, scrollPosition: [])
                }
                
                // If triggereing is enabled, then let their delegate handle the reloading of view, else we will reload the data
                if triggerSelectionDelegate {
                    delayRunOnMainThread(delay: 0.0) {
                        self.collectionView(self.calendarView, didSelectItemAt: sectionIndexPath)
                    }
                } else { // Although we do not want the delegate triggered, we still want counterpart cells to be selected
                    
                    // Because there is no triggering of the delegate, the cell will not be added to selection and it will not be reloaded. We need to do this here
                    self.addCellToSelectedSetIfUnselected(sectionIndexPath, date: date as Date)
                    allIndexPathsToReload.append(sectionIndexPath)
                    
                    let cellState = self.cellStateFromIndexPath(indexPath: sectionIndexPath, withDate: date)
                    if let aSelectedCounterPartIndexPath = self.selectCounterPartCellIndexPathIfExists(sectionIndexPath, date: date as Date, dateOwner: cellState.dateBelongsTo) {
                        // If there was a counterpart cell then it will also need to be reloaded
                        allIndexPathsToReload.append(aSelectedCounterPartIndexPath)
                    }
                }
            }
            
            let deSelectTheDate = { (indexPath: NSIndexPath) -> Void in
                allIndexPathsToReload.append(indexPath as IndexPath)
                delayRunOnMainThread(delay: 0.0) {
                    self.calendarView.deselectItem(at: indexPath as IndexPath, animated: false)
                }
                if
                    self.theSelectedIndexPaths.contains(indexPath as IndexPath),
                    let index = self.theSelectedIndexPaths.index(of: indexPath as IndexPath) {
                    
                    self.theSelectedIndexPaths.remove(at: index)
                    self.theSelectedDates.remove(at: index)
                }
                // If delegate triggering is enabled, let the delegate function handle the cell
                if triggerSelectionDelegate {
                    delayRunOnMainThread(delay: 0.0) {
                        self.collectionView(self.calendarView, didDeselectItemAt: indexPath as IndexPath)
                    }
                } else { // Although we do not want the delegate triggered, we still want counterpart cells to be deselected
                    let cellState = self.cellStateFromIndexPath(indexPath: sectionIndexPath, withDate: date)
                    if let anUnselectedCounterPartIndexPath = self.deselectCounterPartCellIndexPath(indexPath as IndexPath, date: date as Date, dateOwner: cellState.dateBelongsTo) {
                        // If there was a counterpart cell then it will also need to be reloaded
                         allIndexPathsToReload.append(anUnselectedCounterPartIndexPath)
                    }
                }
            }
            
            // Remove old selections
            if self.calendarView.allowsMultipleSelection == false { // If single selection is ON
                for indexPath in self.theSelectedIndexPaths {
                    if indexPath != sectionIndexPath {
                        deSelectTheDate(indexPath)
                    }
                }
                
                // Add new selections
                // Must be added here. If added in delegate didSelectItemAtIndexPath
                selectTheDate()
            } else { // If multiple selection is on. Multiple selection behaves differently to singleselection. It behaves like a toggle.
                
                if self.theSelectedIndexPaths.contains(sectionIndexPath) { // If this cell is already selected, then deselect it
                    deSelectTheDate(sectionIndexPath)
                } else {
                    // Add new selections
                    // Must be added here. If added in delegate didSelectItemAtIndexPath
                    selectTheDate()
                }
            }
        }
        
        // If triggering was false, although the selectDelegates weren't called, we do want the cell refreshed. Reload to call itemAtIndexPath
        if triggerSelectionDelegate == false {
            delayRunOnMainThread(delay: 0.0) {
                self.reloadIndexPathsIfVisible(allIndexPathsToReload)
            }
        }
    }
    
    /// Scrolls the calendar view to the next section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToNextSegment(_ animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage + 1
        if page < monthInfo.count {
            scrollToSection(section: page,  animateScroll: animateScroll, completionHandler: completionHandler)
        }
    }
    /// Scrolls the calendar view to the previous section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToPreviousSegment(_ animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage - 1
        if page > -1 {
            scrollToSection(section: page, animateScroll: animateScroll, completionHandler: completionHandler)
        }
    }

    /// Scrolls the calendar view to the start of a section view containing a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell containing this date if it exists
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Paramater preferredScrollPositionIndex: Integer indicating the end scroll position on the screen. This value indicates column number for Horizontal scrolling and row number for a vertical scrolling calendar
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToDate(_ date: Date, triggerScrollToDateDelegate: Bool = true, animateScroll: Bool = true, preferredScrollPosition: UICollectionViewScrollPosition? = nil, completionHandler:(()->Void)? = nil) {
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let components = calendar.components([.year, .month, .day],  from: date)
        let firstDayOfDate = calendar.date(from: components)!
        
        scrollInProgress = true
        delayRunOnMainThread(delay: 0.0, closure: {
            // This part should be inside the mainRunLoop
            if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                self.scrollInProgress = false
                return
            }
            
            let retrievedPathsFromDates = self.pathsFromDates([date])
            
            if retrievedPathsFromDates.count > 0 {
                let sectionIndexPath =  self.pathsFromDates([date])[0]
                var position: UICollectionViewScrollPosition = self.direction == .horizontal ? .left : .top
                if !self.pagingEnabled {
                    if let validPosition:UICollectionViewScrollPosition = preferredScrollPosition {
                        if self.direction == .horizontal {
                            if validPosition == .left || validPosition == .right || validPosition == .centeredHorizontally {
                                position = validPosition
                            } else {
                                position = .left
                            }
                        } else {
                            if validPosition == .top || validPosition == .bottom || validPosition == .centeredVertically {
                                position = validPosition
                            } else {
                                position = .top
                            }
                        }
                    }
                }
                
                let scrollToIndexPath = {(iPath: IndexPath, withAnimation: Bool)-> Void in
                    if let validCompletionHandler = completionHandler { self.delayedExecutionClosure.append(validCompletionHandler) }
                    // regular movement
                    self.calendarView.scrollToItem(at: iPath, at: position, animated: animateScroll)
                    
                    
                    if animateScroll {
                        if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forIndexPath: iPath), check == true {
                                self.scrollViewDidEndScrollingAnimation(self.calendarView)
                                self.scrollInProgress = false
                                return
                        }
                    }
                }
                
                if self.pagingEnabled {
                    if headerViewXibs.count > 0 {
                        // If both paging and header is on, then scroll to the actual date
                        // If direction is vertical and user has a custom size that is at least the size of the collectionview.
                        // If this check is not done, it will scroll to header, and have white space at bottom because view is smaller due to small custom user itemSize
                        if self.direction == .vertical && (self.calendarView.collectionViewLayout as! JTAppleCalendarLayout).sizeOfSection(section: sectionIndexPath.section) >= self.calendarView.frame.height {
                            self.scrollToHeaderInSection(sectionIndexPath.section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animateScroll, completionHandler: completionHandler)
                            return
                        } else {
                            scrollToIndexPath(IndexPath(item: 0, section: (sectionIndexPath as NSIndexPath).section), animateScroll)
                        }
                    } else {
                        // If paging is on and header is off, then scroll to the start date in section
                        scrollToIndexPath(IndexPath(item: 0, section: (sectionIndexPath as NSIndexPath).section), animateScroll)
                    }
                } else {
                    // If paging is off, then scroll to the actual date in the section
                    scrollToIndexPath(sectionIndexPath, animateScroll)
                }
                
                // Jt101 put this into a function to reduce code between this and the scroll to header function
                delayRunOnMainThread(delay: 0.0, closure: {
                    if  !animateScroll  {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                })
            }
        })
    }
    
    /// Scrolls the calendar view to the start of a section view header. If the calendar has no headers registered, then this function does nothing
    /// - Paramater date: The calendar view will scroll to the header of a this provided date
    public func scrollToHeaderForDate(_ date: Date, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        let path = pathsFromDates([date])
        // Return if date was incalid and no path was returned
        if path.count < 1 { return }
        scrollToHeaderInSection((path[0] as NSIndexPath).section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animation, completionHandler: completionHandler)
    }
}
