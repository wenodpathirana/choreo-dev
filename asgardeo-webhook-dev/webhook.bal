import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:NotificationService on webhookListener {
  
    remote function onSmsOtp(asgardeo:SmsOtpNotificationEvent event ) returns error? {
      log:printInfo(event.toJsonString());

      asgardeo:SmsOtpNotificationData? eventData = event.eventData;

      json eventd = eventData.toJson();
      json messageBody = check eventd.messageBody;

      log:printInfo(messageBody.toBalString());
      log:printInfo(<string> messageBody);

      final http:Client clientEndpoint = check new ("https://6385d011875ca3273d46475a.mockapi.io");

      json resp = check clientEndpoint -> post("/api/v1/sms/custom", { "body": messageBody.toString() });

      log:printInfo(resp.toBalString());
    }
}

service /ignore on httpListener {}