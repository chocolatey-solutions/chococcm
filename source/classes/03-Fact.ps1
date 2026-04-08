class Fact {
    [string]$name
    [string]$value
    [string]$valueType
    [string]$id
}

class FactGroup {
    [int]$tenantId
    [string]$name
    [string]$categoryId
    [Fact[]]$facts
    [string]$id
}

class FactCategory {
    [string]$name
    [string]$computerFactsId
    [FactGroup[]]$groups
    [Fact[]]$facts
    [string]$id
}

class ComputerFacts {
    [int]$computerId
    [string]$computerName
    [datetime]$reportDateTimeUtc
    [FactCategory[]]$categories
    [string]$id
}