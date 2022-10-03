import ballerina/http;

public type InternalServerErrorError record {|
    *http:InternalServerError;
    Error body;
|};

public type NotFoundError record {|
    *http:NotFound;
    Error body;
|};

# Description
#
# + access_token - Field Description  
# + issued_token_type - Field Description  
# + token_type - Field Description  
# + expires_in - Field Description  
# + scope - Field Description
public type TokenResponse record {
    string access_token?;
    string issued_token_type?;
    string token_type?;
    int expires_in?;
    string scope?;
};

public type ErrorListItem record {
    string code;
    # Description about individual errors occurred
    string message;
    # A detail description about the error message.
    string description?;
};

public type TokenRequest record {
    string client_id;
    string grant_type;
    string subject_token_type;
    string requested_token_type?;
    string scope?;
    string subject_token;
    string org_handle?;
};

public type Error record {
    int code;
    # Error message.
    string message;
    # A detail description about the error message.
    string description?;
    # Preferably an url with more details about the error.
    string moreInfo?;
    # If there are more than one error list them out.
    # For example, list out validation errors by each field.
    ErrorListItem[] 'error?;
};
