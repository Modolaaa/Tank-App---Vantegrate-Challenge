// mock class
@isTest
global class BitlyMockResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(201);
        res.setBody('{"link": "https://bit.ly/abc123"}');
        return res;
    }
}