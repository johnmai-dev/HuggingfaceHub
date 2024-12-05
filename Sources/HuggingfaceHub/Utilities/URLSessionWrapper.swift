//
//  URLSessionWrapper.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/12/2.
//

import Foundation

// def _request_wrapper(
//    method: HTTP_METHOD_T, url: str, *, follow_relative_redirects: bool = False, **params
// ) -> requests.Response:
//    """Wrapper around requests methods to follow relative redirects if `follow_relative_redirects=True` even when
//    `allow_redirection=False`.
//
//    Args:
//        method (`str`):
//            HTTP method, such as 'GET' or 'HEAD'.
//        url (`str`):
//            The URL of the resource to fetch.
//        follow_relative_redirects (`bool`, *optional*, defaults to `False`)
//            If True, relative redirection (redirection to the same site) will be resolved even when `allow_redirection`
//            kwarg is set to False. Useful when we want to follow a redirection to a renamed repository without
//            following redirection to a CDN.
//        **params (`dict`, *optional*):
//            Params to pass to `requests.request`.
//    """
//    # Recursively follow relative redirects
//    if follow_relative_redirects:
//        response = _request_wrapper(
//            method=method,
//            url=url,
//            follow_relative_redirects=False,
//            **params,
//        )
//
//        # If redirection, we redirect only relative paths.
//        # This is useful in case of a renamed repository.
//        if 300 <= response.status_code <= 399:
//            parsed_target = urlparse(response.headers["Location"])
//            if parsed_target.netloc == "":
//                # This means it is a relative 'location' headers, as allowed by RFC 7231.
//                # (e.g. '/path/to/resource' instead of 'http://domain.tld/path/to/resource')
//                # We want to follow this relative redirect !
//                #
//                # Highly inspired by `resolve_redirects` from requests library.
//                # See https://github.com/psf/requests/blob/main/requests/sessions.py#L159
//                next_url = urlparse(url)._replace(path=parsed_target.path).geturl()
//                return _request_wrapper(method=method, url=next_url, follow_relative_redirects=True, **params)
//        return response
//
//    # Perform request and return if status_code is not in the retry list.
//    response = get_session().request(method=method, url=url, **params)
//    hf_raise_for_status(response)
//    return response

class URLSessionWrapper: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func data(for request: URLRequest, followRelativeRedirects: Bool = false) async throws -> (Data, URLResponse) {
        if followRelativeRedirects {
            let (data, response) = try await self.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if (300 ... 399).contains(httpResponse.statusCode) {
                let parsedTarget = URL(string: httpResponse.allHeaderFields["Location"] as? String ?? "")
                if parsedTarget?.host == nil {
                    let nextURL = URL(string: request.url?.absoluteString ?? "")?.appendingPathComponent(parsedTarget?.path ?? "")
                    return try await self.data(for: URLRequest(url: nextURL!), followRelativeRedirects: true)
                }
                return (data, response)
            }
        }

        return try await session.data(for: request, delegate: self)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        nil
    }
}
