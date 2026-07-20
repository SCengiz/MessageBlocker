import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let response = ILMessageFilterQueryResponse()
        if let body = queryRequest.messageBody, KeywordStore.matches(body) {
            response.action = .junk
        } else {
            response.action = .none
        }
        completion(response)
    }
}
