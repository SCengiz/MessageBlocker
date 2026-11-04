import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let response = ILMessageFilterQueryResponse()

        // .junk -> mesaj İstenmeyen klasörüne gider, bildirim gösterilmez.
        // .none -> karışmıyoruz; mesaj normal akışında kalır.
        if KeywordStore.shouldBlock(sender: queryRequest.sender, body: queryRequest.messageBody) {
            response.action = .junk
        } else {
            response.action = .none
        }

        completion(response)
    }
}
