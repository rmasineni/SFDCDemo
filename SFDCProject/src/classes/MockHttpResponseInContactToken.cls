@isTest
global class MockHttpResponseInContactToken implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req)
    {
        String response = '{"access_token":"ImIBXrEbkBNT6JSTcFwEpLBh0lDgzPp7XUiOpjvMhwh+pWYaseJti4eGPBlZG+zZbuJEWJDHGb+nbepHfumlY5BWXJOlLHkCLcIRq4e3evd/wnawGhVGKvbqFFlrmZVQ/txkUSrJKX2aIEgQlKC/NyQQM09P3roYaJs7FEBdvHYSEfW4Ool/OIlPN29hUytieYUxQ8VcAHkUpsNr1pYH3UrdDaMQONofXTozh/M1SExzNEmiVtTDtujqxOR/NJHipXcg3vR6bpefGpeZTfEX7gydlYP4k+pqUZxecLMi3fb+k3MHCzu9/oAvRW1FttL0k0jd+pbYrK49rFXaCcJ6AG3Br30IZaYRdvBZKgIz8hqw7sv/0re4Z0IZFrD1tbZ6","token_type":"bearer","expires_in":3600,"refresh_token":"n3e+VNryAkK/InesWSPoZw==","scope":"RealTimeApi AdminApi AgentApi CustomApi AuthenticationApi PatronApi ReportingApi","resource_server_base_uri":"https://api-C16.incontact.com/inContactAPI/","refresh_token_server_uri":"https://api-C16.incontact.com/InContactAuthorizationServer/Token","agent_id":2475571,"team_id":375690,"bus_no":4595152}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }

}