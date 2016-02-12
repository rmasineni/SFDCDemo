@isTest
global class MockHttpResponseForAPI1 implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        String response = '{"response": {"code": "200","message": "OK: The request was successful. See response body for additional data.","data": {"referring_ambassador": {"first_name": null,"last_name": null,"email": null,"uid": null,"platform_id": null,"commission": null,"balance_money": 0,"balance_points": 0,"memorable_url": "http://mbsy.co","unique_referrals": 0,"sandbox": null,"custom1": "","custom2": "","custom3": ""},"ambassador": {"first_name":"melissa1234","last_name": "north91343345","created_at": "2015-07-31T08:15:22.066+0000","email":"north913345@yopmail.com","uid": null,"platform_id": 19564502,"balance_money": 0.00,"balance_points": 0.00,"memorable_url": "http://mbsy.co/sunrun-TEST/19374282","unique_referrals": null,"count_shares": null,"sandbox": 0,"custom1": "","custom2": "","custom3": "","groups": "3","campaign_links": [{"campaign_uid": "28927",    "campaign_name": "Sunrun Employee TEST",    "campaign_description": "Sunrun Ambassador Referral\\\n\\\n* URL will be updated at later date","initial_reward": {"type_text": "Flat Monetary","type_code": "F","amount": "350"},"recurring_reward": {"type_text": "None","type_code": "D","amount": 0},"sandbox": 0,"private": "1","facebook_enabled": 0,"url": "http://mbsy.co/cvG7z","total_money_earned": 0.00,"total_points_earned": 0.00,"unique_referrals": 0}]},"company": {"company_name": "sunrun-TEST","company_url": "","company_email": "srajan+test@sunrun.com","point_name": "points","outgoing_email": null,"avatar_url": ""}}}}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}