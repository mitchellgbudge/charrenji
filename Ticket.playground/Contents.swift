import UIKit

enum TicketType {
    case demo, defect, spike, story, technicalStory

    var projectId: Int {
        return self == .demo ? Jira.demoId : Jira.projectId
    }

    var engineeringOwner: String? {
        switch self {
        case .demo: return nil
        default: return Jira.engineeringOwner
        }
    }

    var qaOwner: String? {
        switch self {
        case .demo: return nil
        case .technicalStory, .spike: return Jira.engineeringOwner
        default: return Jira.engineeringOwner
        }
    }

    var scrumTeam: String? {
        return self == .demo ? nil : Jira.scrumTeam
    }

    var uatNeeded: String? {
        switch self {
        case .demo: return nil
        case .story: return "Yes"
        default: return "No"
        }
    }
}

struct Ticket {
    let ticketType: TicketType
    let title: String
    let issueType: String
    let components: [Component]
    let description: String
    let acceptanceCriteria: String
    var systemRequirements: String?
    var priority: Int?
}

struct Component: Encodable {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

struct ScrumTeam: Encodable {
    let value: String

    init(_ value: String) {
        self.value = value
    }
}

extension Ticket: Encodable {
    enum CodingKeys: String, CodingKey {
        case fields
    }

    enum FieldsCodingKeys: String, CodingKey {
        case project
        case issuetype
        case description
        case summary
        case components
        case acceptanceCriteria = "customfield_10130"
        case systemRequirements = "customfield_14640"
        case priority = "customfield_12940"
        case engineeringOwner = "customfield_11742"
        case qaOwner = "customfield_10469"
        case scrumTeam = "customfield_11342"
        case uatNeeded = "customfield_15146"
    }

    enum AdditionalInfoCodingKeys: String, CodingKey {
        case id
        case name
        case value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)

        try fieldsContainer.encode(title, forKey: .summary)

        try fieldsContainer.encode(description, forKey: .description)

        var projectContainer = fieldsContainer.nestedContainer(keyedBy: AdditionalInfoCodingKeys.self, forKey: .project)
        try projectContainer.encode(ticketType.projectId, forKey: .id)

        var issueTypeContainer = fieldsContainer.nestedContainer(keyedBy: AdditionalInfoCodingKeys.self, forKey: .issuetype)
        try issueTypeContainer.encode(issueType, forKey: .name)

        try fieldsContainer.encode(components, forKey: .components)

        try fieldsContainer.encode(acceptanceCriteria, forKey: .acceptanceCriteria)

        try fieldsContainer.encodeIfPresent(systemRequirements, forKey: .systemRequirements)

        try fieldsContainer.encodeIfPresent(priority, forKey: .priority)

        if let engineeringOwner = ticketType.engineeringOwner {
            var engOwnerContainer = fieldsContainer.nestedContainer(keyedBy: AdditionalInfoCodingKeys.self, forKey: .engineeringOwner)
            try engOwnerContainer.encode(engineeringOwner, forKey: .name)
        }

        if let qaOwner = ticketType.qaOwner {
            var qaOwnerContainer = fieldsContainer.nestedContainer(keyedBy: AdditionalInfoCodingKeys.self, forKey: .qaOwner)
            try qaOwnerContainer.encodeIfPresent(qaOwner, forKey: .name)
        }

        try fieldsContainer.encode(ticketType.scrumTeam, forKey: .scrumTeam)

        if let uatNeeded = ticketType.uatNeeded {
            var uatNeededContainer = fieldsContainer.nestedContainer(keyedBy: AdditionalInfoCodingKeys.self, forKey: .uatNeeded)
            try uatNeededContainer.encode(uatNeeded, forKey: .value)
        }

    }
}
let ticket = Ticket(ticketType: ., title: <#T##String#>, issueType: <#T##String#>, components: <#T##[Component]#>, description: <#T##String#>, acceptanceCriteria: <#T##String#>, systemRequirements: <#T##String?#>, priority: <#T##Int?#>)
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let encoded = try encoder.encode(ticket)
let json = String(data: encoded, encoding: .utf8)
print(json!)
