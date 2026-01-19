struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money: Equatable {
    public let amount: Int
    public let currency: String

    private static let ratesToCurrencyPerUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 0.5,
        "EUR": 1.5,
        "CAN": 1.25
    ]

    public init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }

    public func convert(_ target: String) -> Money {
        guard let fromPerUSD = Money.ratesToCurrencyPerUSD[self.currency],
              let toPerUSD = Money.ratesToCurrencyPerUSD[target] else {
            return self
        }

        let usdValue = Double(self.amount) / fromPerUSD
        let targetValue = usdValue * toPerUSD

        return Money(amount: Int(targetValue), currency: target)
    }

    public func add(_ other: Money) -> Money {
        let selfInOther = self.convert(other.currency)
        return Money(amount: selfInOther.amount + other.amount, currency: other.currency)
    }

    public func subtract(_ other: Money) -> Money {
        let selfInOther = self.convert(other.currency)
        return Money(amount: selfInOther.amount - other.amount, currency: other.currency)
    }

}


////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }

    public let title: String
    public var type: JobType

    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }

    public func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case .Salary(let yearly):
            return Int(yearly)
        case .Hourly(let rate):
            return Int(rate * Double(hours))
        }
    }

    public func raise(byAmount amount: Double) {
        switch type {
        case .Salary(let yearly):
            let newVal = max(0, Int(yearly) + Int(amount))
            type = .Salary(UInt(newVal))
        case .Hourly(let rate):
            type = .Hourly(rate + amount)
        }
    }

    public func raise(byPercent percent: Double) {
        switch type {
        case .Salary(let yearly):
            let newVal = Int(Double(yearly) * (1.0 + percent))
            type = .Salary(UInt(max(0, newVal)))
        case .Hourly(let rate):
            type = .Hourly(rate * (1.0 + percent))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public let firstName: String
    public let lastName: String
    public let age: Int

    public var job: Job? {
        didSet {
            if age < 16 { job = nil }
        }
    }

    public var spouse: Person? {
        didSet {
            if age < 18 { spouse = nil }
        }
    }

    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }

    public func toString() -> String {
        let jobDesc: String
        if let j = job {
            jobDesc = j.title
        } else {
            jobDesc = "nil"
        }

        let spouseDesc: String
        if let s = spouse {
            spouseDesc = "\(s.firstName) \(s.lastName)"
        } else {
            spouseDesc = "nil"
        }

        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobDesc) spouse:\(spouseDesc)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public private(set) var members: [Person] = []

    public init(spouse1: Person, spouse2: Person) {
        members.append(spouse1)
        members.append(spouse2)

        if spouse1.age >= 18 && spouse2.age >= 18 {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
        }
    }

    public func haveChild(_ child: Person) -> Bool {
        let hasAdult = members.contains { $0.age >= 21 }
        if !hasAdult { return false }

        members.append(child)
        return true
    }

    public func householdIncome() -> Int {
        var total = 0
        for p in members {
            if let j = p.job {
                total += j.calculateIncome(2000)
            }
        }
        return total
    }
}
