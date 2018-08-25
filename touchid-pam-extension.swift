import LocalAuthentication

// MARK: (Re)define PAM constants here so we don't need to import .h files.

private let PAM_SUCCESS = 0
private let PAM_AUTH_ERR = 9
private let PAM_IGNORE = 25
private let DEFAULT_REASON = "perform an action that requires authentication"

public typealias vchar = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>
public typealias pam_handler_t = UnsafeRawPointer

// MARK: Biometric (touchID) authentication

@_silgen_name("pam_sm_authenticate")
public func pam_sm_authenticate(pamh: pam_handler_t, flags: Int, argc: Int, argv: vchar) -> Int {
    let arguments = parseArguments(argc: argc, argv: argv)
    var reason = arguments["reason"] ?? DEFAULT_REASON
    reason = reason.isEmpty ? DEFAULT_REASON : reason

    let semaphore = DispatchSemaphore(value: 0)

    var result = PAM_AUTH_ERR
    let policy = LAPolicy.deviceOwnerAuthenticationIgnoringUserID
    LAContext().evaluatePolicy(policy, localizedReason: reason) { success, error in
        defer { semaphore.signal() }

        if let error = error {
            fputs("\(error.localizedDescription)\n", stderr)
        }

        result = success ? PAM_SUCCESS : PAM_AUTH_ERR
    }

    semaphore.wait()
    return result
}

private func parseArguments(argc: Int, argv: vchar) -> [String: String] {
    var parsed = [String: String]()
    let arguments = (0 ..< argc)
       .map { String(cString: argv[$0]) }
       .joined(separator: " ")

    let regex = try? NSRegularExpression(pattern: "[^\\s\"']+|\"([^\"]*)\"|'([^']*)'",
                                         options: .dotMatchesLineSeparators)

    let matches = regex?.matches(in: arguments, options: .withoutAnchoringBounds,
                                 range: NSRange(location: 0, length: arguments.count))

    let nsArguments = arguments as NSString
    let groups = matches?
        .map { nsArguments.substring(with: $0.range) }
        .map { ($0 as String).trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }

    for argument in groups ?? [] {
        let pieces = argument.components(separatedBy: "=")
        if pieces.count == 2, let key = pieces.first, let value = pieces.last {
            parsed[key] = value
        }
    }

    return parsed
}

private extension LAPolicy {
    static var deviceOwnerAuthenticationIgnoringUserID: LAPolicy {
        return LAPolicy(rawValue: 0x3f0) ?? .deviceOwnerAuthenticationWithBiometrics
    }
}

// MARK: - Ignored (unhandled) PAM events

@_silgen_name("pam_sm_chauthtok")
public func pam_sm_chauthtok(pamh: pam_handler_t, flags: Int, argc: Int, argv: vchar) -> Int {
    return PAM_IGNORE
}

@_silgen_name("pam_sm_setcred")
public func pam_sm_setcred(pamh: pam_handler_t, flags: Int, argc: Int, argv: vchar) -> Int {
    return PAM_IGNORE
}

@_silgen_name("pam_sm_acct_mgmt")
public func pam_sm_acct_mgmt(pamh: pam_handler_t, flags: Int, argc: Int, argv: vchar) -> Int {
    return PAM_IGNORE
}
