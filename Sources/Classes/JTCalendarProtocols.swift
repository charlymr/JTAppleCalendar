//
//  JTCalendarProtocols.swift
//  Pods
//
//  Created by Jeron Thomas on 2016-06-07.
//
//

protocol JTAppleCalendarLayoutProtocol: class {
    var itemSize: CGSize {get set}
    var headerReferenceSize: CGSize {get set}
    var scrollDirection: UICollectionViewScrollDirection {get set}
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] {get set}
    var headerCache: [UICollectionViewLayoutAttributes] {get set}
    
    func targetContentOffsetForProposedContentOffset(_ proposedContentOffset: CGPoint) -> CGPoint
    func sectionFromRectOffset(offset: CGPoint)-> Int
    func sizeOfContentForSection(section: Int)-> CGFloat
    func clearCache()
}

protocol JTAppleCalendarDelegateProtocol: class {
    var itemSize: CGFloat? {get set}
    
    func numberOfRows() -> Int
    func numberOfColumns() -> Int
    func numberOfsectionsPermonth() -> Int
    func numberOfMonthsInCalendar() -> Int
    func numberOfDaysPerSection() -> Int
    
    func referenceSizeForHeaderInSection(_ section: Int) -> CGSize
}
