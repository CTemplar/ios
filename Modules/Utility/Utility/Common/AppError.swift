import Foundation

public enum AppError: Error {
    case downcastingFailed
    case cryptoFailed
    case connectivityIssue
    case serverError(value: String)
    case unknown

    public var isConnectionError: Bool {
        if case .connectivityIssue = self { return true }
        return false
    }
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .downcastingFailed:
            return Strings.AppError.downcastFailure.localized
        case .cryptoFailed:
            return Strings.AppError.hashingFailure.localized
        case .connectivityIssue:
            return Strings.AppError.conectionError.localized
        case .unknown:
            return Strings.AppError.unknownError.localized
        case .serverError(let value):
            return value
        }
    }
}
