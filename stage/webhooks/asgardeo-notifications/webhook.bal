import ballerinax/twilio;
import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;

configurable asgardeo:ListenerConfig config = ?;
configurable string sid = ?;
configurable string token = ?;
configurable string fromMobile = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:NotificationService on webhookListener {
  
    remote function onSmsOtp(asgardeo:SmsOtpNotificationEvent event ) returns error? {
        
        //logging the event.
        log:printInfo(event.toJsonString());

        //read data from the event.
        asgardeo:SmsOtpNotificationData? eventData = event.eventData;
        string toNumber = <string> check eventData.toJson().sendTo;
        string message = <string> check eventData.toJson().messageBody;

        //Configure twilio account.
        twilio:Client twilioClient = check new (config = {
            twilioAuth: {
                accountSId: sid,
                authToken: token
            }
        });

        twilio:SmsResponse response = check twilioClient -> sendSms(fromMobile, toNumber, message);
        log:printInfo("SMS_SID: " + response.sid.toString() + ", Body: " + response.body.toString());
    }
}

service /ignore on httpListener {}
