class Fact {
    [string]$Name
    [string]$Value
    [string]$ValueType
    [string]$Id
}

class FactGroup {
    [int]$TenantId
    [string]$Name
    [string]$CategoryId
    [Fact[]]$Facts
    [string]$Id
}

class FactCategory {
    [string]$Name
    [string]$ComputerFactsId
    [FactGroup[]]$Groups
    [Fact[]]$Facts
    [string]$Id
}

class ComputerFacts {
    [int]$ComputerId
    [string]$ComputerName
    [datetime]$ReportDateTimeUtc
    [FactCategory[]]$Categories
    [string]$Id
}