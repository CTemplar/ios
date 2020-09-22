enum ComposeSection: CaseIterable {
    case prefix
    case subject
    case menu
    case body
    
    func rows(isCollapsed: Bool, attachmentCount: Int, includeAttachments: Bool) -> [ComposeRow] {
        switch self {
        case .prefix:
            return isCollapsed ? [.from, .to] : [.from, .to, .cc, .bcc]
        case .subject:
            return [.subject]
        case .menu:
            return [.menu]
        case .body:
            return includeAttachments == false ? [.body] : (attachmentCount == 0 ? [.body] : [.attachment, .body])
        }
    }
}

enum ComposeRow {
    case from
    case to
    case cc
    case bcc
    case subject
    case menu
    case attachment
    case body
}
