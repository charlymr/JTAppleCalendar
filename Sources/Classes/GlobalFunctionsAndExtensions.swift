//
//  GlobalFunctionsAndExtensions.swift
//  Pods
//
//  Created by Jeron Thomas on 2016-06-26.
//
//

func delayRunOnMainThread(delay:Double, closure:()->()) {
    DispatchQueue.main.after(when: DispatchTime.now() + delay, execute: closure)
}

func delayRunOnGlobalThread(delay:Double, qos: qos_class_t,closure:()->()) {
    let globalQueue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(Int(UInt32(qos.rawValue)))))
    globalQueue.after(when: DispatchTime.now() + delay, execute: closure)}

/// NSDates can be compared with the == and != operators
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs as Date) == .orderedSame
}
/// NSDates can be compared with the > and < operators
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs as Date) == .orderedAscending
}



extension NSDate: Comparable { }
extension Date {
    static func startOfMonthForDate(date: NSDate, usingCalendar calendar:Calendar) -> NSDate? {
        let dayOneComponents = calendar.components([.era, .year, .month], from: date as Date)
        return calendar.date(from: dayOneComponents)
    }
    
    static func endOfMonthForDate(date: NSDate, usingCalendar calendar:Calendar) -> NSDate? {
        var lastDayComponents = calendar.components([Calendar.Unit.era, Calendar.Unit.year, Calendar.Unit.month], from: date as Date)
        lastDayComponents.month = lastDayComponents.month! + 1
        lastDayComponents.day = 0
        return calendar.date(from: lastDayComponents)
    }
}
