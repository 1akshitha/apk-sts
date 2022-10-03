import ballerina/http;
import ballerina/io;

configurable int STS_PORT = 9443;

listener http:Listener ep0 = new (STS_PORT);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowHeaders: ["*"],
        exposeHeaders: ["*"],
        maxAge: 84900
    }
}

service /api/am/sts/v1 on ep0 {
    resource function post oauth2/token(@http:Payload {mediaType: "application/x-www-form-urlencoded"} map<string> pairs) returns TokenResponse|NotFoundError|InternalServerErrorError {
        io:println("STS oauth2/token request received!");
        TokenResponse tokenResponse = {
            access_token: <string>pairs["subject_token"],
            issued_token_type: <string>pairs["subject_token_type"],
            token_type: "Bearer",
            expires_in: 3600
        };
        return tokenResponse;
    }
}
