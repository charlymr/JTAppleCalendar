//
//  JTAppleCalendarLayout.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//


/// Base class for the Horizontal layout
public class JTAppleCalendarLayout: UICollectionViewLayout, JTAppleCalendarLayoutProtocol {
    var itemSize: CGSize = CGSize.zero
    var headerReferenceSize: CGSize = CGSize.zero
    var scrollDirection: UICollectionViewScrollDirection = .horizontal
    var maxSections: Int = 0
    var daysPerSection: Int = 0
    
    var numberOfColumns: Int { get { return delegate!.numberOfColumns() } }
    var numberOfMonthsInCalendar: Int { get { return delegate!.numberOfMonthsInCalendar() } }
    var numberOfSectionsPerMonth: Int { get { return delegate!.numberOfsectionsPermonth() } }
    var numberOfDaysPerSection: Int { get { return delegate!.numberOfDaysPerSection() } }
    var numberOfRows: Int { get { return delegate!.numberOfRows() } }
    
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] = [:]
    var headerCache: [UICollectionViewLayoutAttributes] = []
    
    
    weak var delegate: JTAppleCalendarDelegateProtocol?
    
    var currentHeader: (section: Int, size: CGSize)? // Tracks the current header size
    var currentCell: (section: Int, itemSize: CGSize)? // Tracks the current cell size
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
    }
    
    /// Tells the layout object to update the current layout.
    public override func prepare() {
        if !cellCache.isEmpty {
            return
        }
        
        maxSections = numberOfMonthsInCalendar * numberOfSectionsPerMonth
        daysPerSection = numberOfDaysPerSection
        
        // // Generate and cache the headers
        for section in 0..<maxSections {
            // generate header views
            let sectionIndexPath = IndexPath(item: 0, section: section)
            if let aHeaderAttr = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: sectionIndexPath) {
                headerCache.append(aHeaderAttr)
            }
            
            // Generate and cache the cells
            for item in 0..<daysPerSection {
                let indexPath = IndexPath(item: item, section: section)
                if let attribute = layoutAttributesForItem(at: indexPath) {
                    if cellCache[section] == nil {
                        cellCache[section] = []
                    }
                    cellCache[section]!.append(attribute)
                } else {
                    print("error.")
                }
            }
        }
    }
    
    /// Returns the width and height of the collection view’s contents. The width and height of the collection view’s contents.
    public override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        
        if scrollDirection == .horizontal {
            size.width = self.collectionView!.bounds.size.width * CGFloat(numberOfMonthsInCalendar * numberOfSectionsPerMonth)
        } else {
            size.height = self.collectionView!.bounds.size.height * CGFloat(numberOfMonthsInCalendar * numberOfSectionsPerMonth)
            size.width = self.collectionView!.bounds.size.width
        }
        return size
    }
    
    /// Returns the layout attributes for all of the cells and views in the specified rectangle.
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var startSectionIndex = scrollDirection == .horizontal ? Int(floor(rect.origin.x / collectionView!.frame.width)): Int(floor(rect.origin.y / collectionView!.frame.height))
        if startSectionIndex < 0 { startSectionIndex = 0 }
        if startSectionIndex > cellCache.count { startSectionIndex = cellCache.count }
        
//        let requestedSections = scrollDirection == .Horizontal ? Int(ceil(rect.width / collectionView!.frame.width)) : Int(ceil(rect.height / collectionView!.frame.height))
//        let endsection = startSectionIndex + requestedSections
        
        // keep looping until there were no interception rects
        var attributes: [UICollectionViewLayoutAttributes] = []
        let maxMissCount = scrollDirection == .horizontal ? 6 : 7
        for sectionIndex in startSectionIndex..<cellCache.count {
//            print("checking section: \(sectionIndex)")
            if let validSection = cellCache[sectionIndex] where validSection.count > 0 {
                
                // Add header view attributes
                var interceptCount: Int  = 0
                if headerViewXibs.count > 0 {
                    interceptCount += 1
                    if headerCache[sectionIndex].frame.intersects(rect) {
                        attributes.append(headerCache[sectionIndex])
                    }
                }
                
                var missCount = 0
                var beganIntercepting = false
                for val in validSection {
                    if val.frame.intersects(rect) {
                        missCount = 0
                        beganIntercepting = true
                        attributes.append(val)
//                        print("s: \(sectionIndex) i: \(index)")
                    } else {
                        missCount += 1
                        if missCount > maxMissCount && beganIntercepting { // If there are at least 8 misses in a row since intercepting began, then this section has no more interceptions. So break
//                            print("There are no more interceptions for section: \(sectionIndex)")
                            break
                        }
                    }
                }
                if missCount > maxMissCount && beganIntercepting {
//                    print("breaking also from outter loop. Rect was: \(rect)")
                    break
                }
            }
        }
        return attributes
    }
    
    /// Returns the layout attributes for the item at the specified index path. A layout attributes object containing the information to apply to the item’s cell.
    override  public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // If this index is already cached, then return it else, apply a new layout attribut to it
        if let alreadyCachedCellAttrib = cellCache[indexPath.section] where indexPath.item < alreadyCachedCellAttrib.count, let item = indexPath.item {
            return alreadyCachedCellAttrib[item]
        }
        
        applyLayoutAttributes(attr)
        return attr
    }
    
    /// Returns the layout attributes for the specified supplementary view.
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        // We cache the header here so we dont call the delegate so much
        let headerSize = cachedHeaderSizeForSection((indexPath as NSIndexPath).section)
        let modifiedSize = CGSize(width: collectionView!.frame.size.width, height: headerSize.height)
        let stride = scrollDirection == .horizontal ? collectionView!.frame.size.width : collectionView!.frame.size.height
        let offset = CGFloat(attributes.indexPath.section) * stride
        
        attributes.frame = scrollDirection == .horizontal ? CGRect(x: offset, y: 0, width: modifiedSize.width, height: modifiedSize.height) : CGRect(x: 0, y: offset, width: modifiedSize.width, height: modifiedSize.height)
        if attributes.frame == CGRect.zero { return nil }
        
        return attributes
    }
    
    func cachedHeaderSizeForSection(_ section: Int) -> CGSize {
        // We cache the header here so we dont call the delegate so much
        let headerSize: CGSize
        if let cachedHeader  = currentHeader where cachedHeader.section == section {
            headerSize = cachedHeader.size
        } else {
            headerSize = delegate!.referenceSizeForHeaderInSection(section)
            currentHeader = (section, headerSize)
        }
        return headerSize
    }
    
    func applyLayoutAttributes(_ attributes : UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil { return }
        
        if let collectionView = self.collectionView {
            
            let sectionStride: CGFloat = scrollDirection == .horizontal ? collectionView.frame.size.width : collectionView.frame.size.height
            let sectionOffset = CGFloat(attributes.indexPath.section) * sectionStride
            var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item! % 7) * self.itemSize.width
            var yCellOffset :CGFloat = CGFloat(attributes.indexPath.item! / 7) * self.itemSize.height
            
            if headerViewXibs.count > 0 {
                let sizeOfItem = sizeForitemAtIndexPath(attributes.indexPath)
                itemSize.height = sizeOfItem.height
            }
            
            if scrollDirection == .horizontal {
                xCellOffset += sectionOffset
            } else {
                yCellOffset += sectionOffset
            }
            
            if headerViewXibs.count > 0 {
                let headerSize = cachedHeaderSizeForSection(attributes.indexPath.section)
                yCellOffset += headerSize.height
            }
            attributes.frame = CGRect(x: xCellOffset, y: yCellOffset, width: self.itemSize.width, height: self.itemSize.height)
        }
    }
    
    func sizeForitemAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        let headerSize = cachedHeaderSizeForSection((indexPath as NSIndexPath).section)
        let currentItemSize = itemSize
        let size = CGSize(width: currentItemSize.width, height: (collectionView!.frame.height - headerSize.height) / CGFloat(numberOfRows))
        currentCell = (section: (indexPath as NSIndexPath).section, itemSize: size)
        return size
    }
    
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
    
    func clearCache() {
        headerCache.removeAll()
        cellCache.removeAll()
        currentHeader = nil
        currentCell = nil
    }
}
