codeunit 50120 DataverseHandler
{
    procedure GetAccountsFromDataverse()
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        JsonResponse: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        JsonObjectLoop: JsonObject;
        AuthToken: SecretText;
        DataverseAccountsEndpointUrl: Text;
        ResponseText: Text;
        DataverseAccount: Record "Dataverse Account";
    begin
        DataverseAccount.Reset();
        DataverseAccount.DeleteAll(false);
        // Get OAuth token
        AuthToken := GetOAuthToken();

        if AuthToken.IsEmpty() then
            Error('Failed to obtain access token.');

        // Define the Dataverse Endpoint URL

        DataverseAccountsEndpointUrl := 'https://org2ffa63f6.api.crm.dynamics.com/api/data/v9.2/accounts?$select=name,telephone1,address1_city,websiteurl';
        // Initialize the HTTP request
        HttpRequestMessage.SetRequestUri(DataverseAccountsEndpointUrl);
        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', AuthToken));

        // Send the HTTP request
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            // Log the status code for debugging
            //Message('HTTP Status Code: %1', HttpResponseMessage.HttpStatusCode());

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content.ReadAs(ResponseText);
                JsonResponse.ReadFrom(ResponseText);

                if JsonResponse.Get('value', JsonToken) then begin
                    JsonArray := JsonToken.AsArray();
                    DataverseAccount.Init();
                    foreach JsonTokenLoop in JsonArray do begin
                        JsonObjectLoop := JsonTokenLoop.AsObject();
                        if JsonObjectLoop.Get('accountid', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            DataverseAccount.Account := JsonValue.AsText();
                        end;
                        if JsonObjectLoop.Get('name', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            if JsonValue.IsNull() then
                                DataverseAccount."Account Name" := ''
                            else
                                DataverseAccount."Account Name" := JsonValue.AsText();
                        end;
                        if JsonObjectLoop.Get('address1_city', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            if JsonValue.IsNull() then
                                DataverseAccount.City := ''
                            else
                                DataverseAccount.City := JsonValue.AsText();
                        end;
                        if JsonObjectLoop.Get('telephone1', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            if JsonValue.IsNull() then
                                DataverseAccount."Main Phone" := ''
                            else
                                DataverseAccount."Main Phone" := Format(JsonValue.AsText());
                        end;
                        if JsonObjectLoop.Get('websiteurl', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            if JsonValue.IsNull() then
                                DataverseAccount."Website Url" := ''
                            else
                                DataverseAccount."Website Url" := JsonValue.AsText();
                        end;
                        DataverseAccount.Insert();
                    end;
                end;

                Message('Dataverse Accounts have been updated successfully');

            end else begin
                //Report errors!
                HttpResponseMessage.Content.ReadAs(ResponseText);
                Error('Failed to fetch data from Endpoint: %1 %2', HttpResponseMessage.HttpStatusCode(), ResponseText);
            end;
        end else
            Error('Failed to send HTTP request to Endpoint');
    end;

    procedure InsertAccountsToDataverse(var DataverseAccount: Record "Dataverse Account")
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        AuthToken: SecretText;
        DataverseAccountsEndpointUrl: Text;
        ResponseText: Text;
        JsonRaw: JsonObject;
        JsonRawText: Text;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
    begin
        // Get OAuth token
        AuthToken := GetOAuthToken();

        if AuthToken.IsEmpty() then
            Error('Failed to obtain access token.');

        //Add the fields and values ​​you need to insert 
        JsonRaw.Add('name', DataverseAccount."Account Name");
        JsonRaw.Add('telephone1', DataverseAccount."Main Phone");
        JsonRaw.Add('address1_city', DataverseAccount.City);
        JsonRaw.Add('websiteurl', DataverseAccount."Website Url");

        JsonRaw.WriteTo(JsonRawText);

        // Define the Dataverse Endpoint URL

        DataverseAccountsEndpointUrl := 'https://org2ffa63f6.api.crm.dynamics.com/api/data/v9.2/accounts?$select=name,telephone1,address1_city,websiteurl';
        // Initialize the HTTP request
        HttpRequestMessage.SetRequestUri(DataverseAccountsEndpointUrl);
        HttpRequestMessage.Method := 'Post';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', AuthToken));
        RequestContent.GetHeaders(ContentHeader);
        RequestContent.WriteFrom(JsonRawText);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');
        ContentHeader.Add('Prefer', 'return=representation');
        HttpRequestMessage.Content(RequestContent);

        // Send the HTTP request
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            // Log the status code for debugging
            //Message('HTTP Status Code: %1', HttpResponseMessage.HttpStatusCode());

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content.ReadAs(ResponseText);
                JsonResponse.ReadFrom(ResponseText);
                JsonResponse.Get('accountid', JsonToken);
                DataverseAccount.Account := JsonToken.AsValue().AsText();
            end else begin
                //Report errors!
                HttpResponseMessage.Content.ReadAs(ResponseText);
                Error('Failed to fetch data from Endpoint: %1 %2', HttpResponseMessage.HttpStatusCode(), ResponseText);
            end;
        end else
            Error('Failed to send HTTP request to Endpoint');
    end;

    procedure UpdateAccountsToDataverse(var DataverseAccount: Record "Dataverse Account")
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        AuthToken: SecretText;
        DataverseAccountsEndpointUrl: Text;
        ResponseText: Text;
        JsonRaw: JsonObject;
        JsonRawText: Text;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        // Get OAuth token
        AuthToken := GetOAuthToken();

        if AuthToken.IsEmpty() then
            Error('Failed to obtain access token.');

        //Add the fields and values ​​you need to update 
        JsonRaw.Add('name', DataverseAccount."Account Name");
        JsonRaw.Add('telephone1', DataverseAccount."Main Phone");
        JsonRaw.Add('address1_city', DataverseAccount.City);
        JsonRaw.Add('websiteurl', DataverseAccount."Website Url");

        JsonRaw.WriteTo(JsonRawText);

        // Define the Dataverse Endpoint URL

        DataverseAccountsEndpointUrl := 'https://org2ffa63f6.api.crm.dynamics.com/api/data/v9.2/accounts(' + GraphMgtGeneralTools.GetIdWithoutBrackets(DataverseAccount.Account) + ')';

        // Initialize the HTTP request
        HttpRequestMessage.SetRequestUri(DataverseAccountsEndpointUrl);
        HttpRequestMessage.Method := 'Patch';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', AuthToken));
        RequestContent.GetHeaders(ContentHeader);
        RequestContent.WriteFrom(JsonRawText);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');
        ContentHeader.Add('Prefer', 'return=representation');
        HttpRequestMessage.Content(RequestContent);

        // Send the HTTP request
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            // Log the status code for debugging
            //Message('HTTP Status Code: %1', HttpResponseMessage.HttpStatusCode());

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content.ReadAs(ResponseText);
                JsonResponse.ReadFrom(ResponseText);
            end else begin
                //Report errors!
                HttpResponseMessage.Content.ReadAs(ResponseText);
                Error('Failed to fetch data from Endpoint: %1 %2', HttpResponseMessage.HttpStatusCode(), ResponseText);
            end;
        end else
            Error('Failed to send HTTP request to Endpoint');
    end;

    procedure DeleteAccountsFromDataverse(var DataverseAccount: Record "Dataverse Account")
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        JsonResponse: JsonObject;
        AuthToken: SecretText;
        DataverseAccountsEndpointUrl: Text;
        ResponseText: Text;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        // Get OAuth token
        AuthToken := GetOAuthToken();

        if AuthToken.IsEmpty() then
            Error('Failed to obtain access token.');

        // Define the Dataverse Endpoint URL

        DataverseAccountsEndpointUrl := 'https://org2ffa63f6.api.crm.dynamics.com/api/data/v9.2/accounts(' + GraphMgtGeneralTools.GetIdWithoutBrackets(DataverseAccount.Account) + ')';
        // Initialize the HTTP request
        HttpRequestMessage.SetRequestUri(DataverseAccountsEndpointUrl);
        HttpRequestMessage.Method := 'Delete';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', AuthToken));

        // Send the HTTP request
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            // Log the status code for debugging
            //Message('HTTP Status Code: %1', HttpResponseMessage.HttpStatusCode());

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content.ReadAs(ResponseText);
                //JsonResponse.ReadFrom(ResponseText);
            end else begin
                //Report errors!
                HttpResponseMessage.Content.ReadAs(ResponseText);
                Error('Failed to fetch data from Endpoint: %1 %2', HttpResponseMessage.HttpStatusCode(), ResponseText);
            end;
        end else
            Error('Failed to send HTTP request to Endpoint');
    end;

    procedure GetOAuthToken() AuthToken: SecretText
    var
        ClientID: Text;
        ClientSecret: Text;
        TenantID: Text;
        AccessTokenURL: Text;
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
    begin
        ClientID := 'b4fe1687-f1ab-4bfa-b494-0e2236ed50bd';
        ClientSecret := 'huL8Q~edsQZ4pwyxka3f7.WUkoKNcPuqlOXv0bww';
        TenantID := '7e47da45-7f7d-448a-bd3d-1f4aa2ec8f62';
        AccessTokenURL := 'https://login.microsoftonline.com/' + TenantID + '/oauth2/v2.0/token';
        Scopes.Add('https://org2ffa63f6.api.crm.dynamics.com/.default');
        if not OAuth2.AcquireTokenWithClientCredentials(ClientID, ClientSecret, AccessTokenURL, '', Scopes, AuthToken) then
            Error('Failed to get access token from response\%1', GetLastErrorText());
    end;
}
