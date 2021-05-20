unit uHttpClient;

interface

uses
    Classes, System.SysUtils, System.Generics.Collections,
    DBXJSON, XMLDoc, RegularExpressions, DCPbase64, uHttpResponse,
    System.Math, StrUtils, IdURI, IdHTTP, IdSSLOpenSSL;

type
    THttpClient = class
        private
            FIdSSL: TIdSSLIOHandlerSocketOpenSSL;
            FRequestBody: TStringStream;
            FQueryString: TStringList;
            FCustomHeaders: TStringList;
            FResponse: TResponse;
            FBaseUrl: string;
            FUserAgent: string;
            FContentType: string;
            FAccept: string;
            FAcceptCharset: string;
            FCharSet: string;
            FConnection: string;
            FAuthBearerToken: string;
            FAuthBasic: string;
            FRequestTimeout: Integer;
            FConnectionTimeout: Integer;
            function createResponseException(statusCode: integer): boolean;
            procedure rejectionFor(statusCode: integer; response: string);
            function buildUrl(url: String): String;
            function BuildHttpClient(): TIdHttp;
        public
            destructor Destroy; override;
            constructor create(baseUrl: string = '');
            function SetIdSSL(value: TIdSSLIOHandlerSocketOpenSSL): THttpClient;
            function SetResponse(value: TResponse): THttpClient;
            function SetUserAgent(value: string): THttpClient;
            function SetRequestTimeout(value: Integer): THttpClient;
            function SetConnectionTimeout(value: Integer): THttpClient;
            function SetConnection(value: string): THttpClient;
            function SetContentType(value: string): THttpClient;
            function SetCharSet(value: string): THttpClient;
            function SetAccept(value: string): THttpClient;
            function SetAcceptCharset(value: string): THttpClient;
            function SetAuthBearerToken(value: string): THttpClient;
            function SetAuthBasic(user, password: string): THttpClient;
            function SetBaseUrl(value: string): THttpClient;
            function AddCustomHeader(key, value: string): THttpClient;
            function AddQueryString(key, value: string): THttpClient;
            function SetBody(body: TStringStream; const AOwns: Boolean = True): THttpClient; overload;
            function SetBody(body: string): THttpClient; overload;
            function SetBody(body: TJSONObject; const AOwns: Boolean = True): THttpClient; overload;
            function SetBody(body: TJSONArray; const AOwns: Boolean = True): THttpClient; overload;
            function SetBody(body: TXMLDocument; const AOwns: Boolean = True): THttpClient; overload;
            function ClearRequestBody: THttpClient;
            function ClearCustomHeaders: THttpClient;
            function ClearQueryString: THttpClient;
            function ClearResponse: THttpClient;
            function post(url: string): THttpClient;
            function put(url: string): THttpClient;
            function get(url: string): THttpClient;
            function delete(url: string): THttpClient;
         published
            property Response: TResponse read FResponse;
            property RequestBody: TStringStream read FRequestBody;
            property QueryString: TStringList read FQueryString;
            property CustomHeaders: TStringList read FCustomHeaders;
            property BaseUrl: string read FBaseUrl;
            property UserAgent: string read FUserAgent;
            property ContentType: string read FContentType;
            property Accept: string read FAccept;
            property AcceptCharset: string read FAcceptCharset;
            property CharSet: string read FCharSet;
            property Connection: string read FConnection;
            property AuthBasic: string read FAuthBasic;
            property AuthBearerToken: string read FAuthBearerToken;
            property RequestTimeout: Integer read FRequestTimeout;
            property ConnectionTimeout: Integer read FConnectionTimeout;
            property IdSSL: TIdSSLIOHandlerSocketOpenSSL read FIdSSL;
    end;


implementation

{ THttpClient }

uses uHttpException;

function THttpClient.SetBody(body: TStringStream; const AOwns: Boolean = True): THttpClient;
begin
    Result := self;

    self.ClearRequestBody;

    try
        self.FRequestBody := TStringStream.Create;
        TStringStream(self.FRequestBody).CopyFrom(body, body.Size);
        self.FRequestBody.Position := 0;
    finally
        if AOwns then
            FreeAndNil(body);
    end;
end;

function THttpClient.SetBody(body: TJSONObject; const AOwns: Boolean = True): THttpClient;
begin
    Result := Self.SetBody(TStringStream.Create(body.ToString, TEncoding.UTF8), AOwns);
end;

function THttpClient.SetAccept(value: string): THttpClient;
begin
    Result := self;
    self.FAccept := value;
end;

function THttpClient.SetAcceptCharset(value: string): THttpClient;
begin
    Result := self;
    self.FAcceptCharset := value;
end;

function THttpClient.SetBody(body: TXMLDocument; const AOwns: Boolean = True): THttpClient;
begin

end;

function THttpClient.SetBody(body: TJSONArray; const AOwns: Boolean = True): THttpClient;
begin
    Result := Self.SetBody(TStringStream.Create(body.ToString, TEncoding.UTF8), AOwns);
end;

function THttpClient.AddCustomHeader(key, value: string): THttpClient;
begin
    Result := self;

    if not Assigned(self.FCustomHeaders) then
        self.FCustomHeaders := TStringList.Create;

    self.FCustomHeaders.Add(Format('%s:%s', [Trim(key), Trim(value)]));
end;

function THttpClient.AddQueryString(key, value: string): THttpClient;
begin
    Result := self;

    if not Assigned(self.FQueryString) then
        self.FQueryString := TStringList.Create;

    self.FQueryString.Add(Format('%s=%s', [Trim(key), Trim(value)]));
end;

function THttpClient.BuildHttpClient(): TIdHttp;
var
    i: Integer;
begin
    Result := TIdHTTP.Create(nil);
    Result.Request.Clear;
    Result.Request.CustomHeaders.Clear;
    Result.IOHandler                        := self.IdSSL;
    Result.Request.ContentType              := self.ContentType;
    Result.Request.UserAgent                := self.UserAgent;
    Result.Request.CharSet                  := self.CharSet;
    Result.Request.AcceptCharSet            := self.AcceptCharset;
    Result.Request.Accept                   := self.Accept;
    Result.Request.Connection               := self.Connection;
    Result.ConnectTimeout                   := self.ConnectionTimeout;
    Result.ReadTimeout                      := self.RequestTimeout;
    Result.Request.CustomHeaders.FoldLines  := False;

    if self.AuthBearerToken <> '' then
    begin
        Result.Request.CustomHeaders.Add(Format('Authorization:Bearer %s', [
            trim(self.AuthBearerToken)
        ]));
    end;

    if self.AuthBasic <> '' then
    begin
        Result.Request.CustomHeaders.Add(Format('Authorization:Basic %s', [
            trim(self.AuthBasic)
        ]));
    end;

    if Assigned(self.CustomHeaders) then
    begin
        for I := 0 to self.CustomHeaders.Count - 1 do
        begin
            Result.Request.CustomHeaders.Add(self.CustomHeaders[i]);
        end;
    end;
end;

function THttpClient.SetAuthBasic(user, password: string): THttpClient;
begin
    Result := self;
    self.FAuthBasic := Base64EncodeStr(Format('%s:%s', [trim(user), trim(password)]));
end;

function THttpClient.SetAuthBearerToken(value: string): THttpClient;
begin
    self.FAuthBearerToken := value;
    Result := self;
end;

function THttpClient.SetBaseUrl(value: string): THttpClient;
begin
    Result := self;
    Self.FBaseUrl := value;
end;

function THttpClient.buildUrl(url: String): String;
var
    i : Integer;
begin
    Result := Trim(self.FBaseUrl);

    if (Length(Result)> 0) and not EndsStr('/', Result) then
        Result := Result + '/';

    if StartsStr('/', Url) then
        System.Delete(Url, 1, 1);

    Result := Result + url;

    if not TRegEx.IsMatch(Result, '^(https?://)') then
        Result := 'https://' + Result;

    if Assigned(self.FQueryString) then
    begin
        Result := Result + '?';

        for I := 0 to (self.FQueryString.Count-1) do
        begin
            if i > 0 then
                Result := Result + '&';

            Result := Result + self.FQueryString[i];
        end;
    end;

    Result := TIdURI.URLEncode(Result);
end;

function THttpClient.SetCharSet(value: string): THttpClient;
begin
    Result := self;
    self.FCharSet := value;
end;

function THttpClient.ClearRequestBody: THttpClient;
begin
    Result := self;

    if Assigned(self.FRequestBody) then
        FreeAndNil(self.FRequestBody);
end;

function THttpClient.ClearCustomHeaders: THttpClient;
begin
    Result := self;

    if Assigned(self.FCustomHeaders) then
        FreeAndNil(self.FCustomHeaders);
end;

function THttpClient.ClearQueryString: THttpClient;
begin
    Result := self;

    if Assigned(self.FQueryString) then
        FreeAndNil(self.FQueryString);
end;

function THttpClient.ClearResponse: THttpClient;
begin
    Result := self;

    if Assigned(self.FResponse) then
        FreeAndNil(self.FResponse);
end;

function THttpClient.SetConnection(value: string): THttpClient;
begin
    self.FConnection := value;
end;

function THttpClient.SetConnectionTimeout(value: Integer): THttpClient;
begin
    Result := self;
    self.FConnectionTimeout := value;
end;

function THttpClient.SetContentType(value: string): THttpClient;
begin
    Result := self;
    self.FContentType := value;
end;

function THttpClient.SetIdSSL(value: TIdSSLIOHandlerSocketOpenSSL): THttpClient;
begin
    Result := self;
    self.FIdSSL := value;
end;

constructor THttpClient.create(baseUrl: string);
var
    IdSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
    IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    IdSSL.SSLOptions.SSLVersions := [
        sslvTLSv1,
        sslvSSLv3,
        sslvSSLv23,
        sslvSSLv2
    ];

    self.SetIdSSL(IdSSL);
    self.SetBaseUrl(baseUrl);
    self.SetConnectionTimeout(5000);
    self.SetRequestTimeout(5000);
    self.SetConnection('Keep-Alive');
    self.SetUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '+
                                '(KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36');
end;

function THttpClient.createResponseException(StatusCode: Integer): boolean;
begin
    Result := not((StatusCode >= 200) and (StatusCode < 299));
end;

function THttpClient.delete(url: string): THttpClient;
var
    httpClient : TIdHTTP;
begin
    Result := self;

    httpClient := self.BuildHttpClient;

    try
        try
            httpClient.delete(TIdURI.URLEncode(self.buildUrl(url)));
        except
            on E: EIdHTTPProtocolException do begin
                if self.createResponseException(httpClient.ResponseCode) then
                begin
                   self.rejectionFor(httpClient.ResponseCode, e.ErrorMessage);
                end;
            end;
        end;
    finally
        FreeAndNil(httpClient);
    end;
end;

destructor THttpClient.Destroy;
begin
    self.ClearRequestBody;
    self.ClearCustomHeaders;
    self.ClearQueryString;
    self.ClearResponse;

    if Assigned(self.FIdSSL) then
        FreeAndNil(self.FIdSSL);

    inherited;
end;

function THttpClient.get(url: string): THttpClient;
var
    httpClient : TIdHTTP;
    response: string;
begin
    Result := self;

    httpClient := self.BuildHttpClient;

    try
        try
            response := httpClient.get(TIdURI.URLEncode(self.buildUrl(url)));
            self.FResponse := TResponse.create(response, httpClient.ResponseCode);
        except
            on E: EIdHTTPProtocolException do begin
                if self.createResponseException(httpClient.ResponseCode) then
                begin
                   self.rejectionFor(httpClient.ResponseCode, e.ErrorMessage);
                end;
            end;
        end;
    finally
        FreeAndNil(httpClient);
    end;
end;

function THttpClient.post(url: string): THttpClient;
var
    httpClient : TIdHTTP;
    response: string;
begin
    Result := self;

    httpClient := self.BuildHttpClient;

    try
        try
            response := httpClient.post(TIdURI.URLEncode(self.buildUrl(url)), self.RequestBody);
            self.FResponse := TResponse.create(response, httpClient.ResponseCode);
        except
            on E: EIdHTTPProtocolException do begin
                if self.createResponseException(httpClient.ResponseCode) then
                begin
                   self.rejectionFor(httpClient.ResponseCode, e.ErrorMessage);
                end;
            end;
        end;
    finally
        FreeAndNil(httpClient);
    end;
end;

function THttpClient.put(url: string): THttpClient;
var
    httpClient : TIdHTTP;
    response: string;
begin
    Result := self;

    httpClient := self.BuildHttpClient;

    try
        try
            response := httpClient.put(TIdURI.URLEncode(self.buildUrl(url)), self.RequestBody);
            self.FResponse := TResponse.create(response, httpClient.ResponseCode);
        except
            on E: EIdHTTPProtocolException do begin
                if self.createResponseException(httpClient.ResponseCode) then
                begin
                   self.rejectionFor(httpClient.ResponseCode, e.ErrorMessage);
                end;
            end;
        end;
    finally
        FreeAndNil(httpClient);
    end;
end;

procedure THttpClient.rejectionFor(statusCode: integer; response: string);
var
    level: Integer;
begin
    if StatusCode = BAD_REQUEST then
    begin
        raise TBadRequestException.Create(Response);
    end
    else if StatusCode = UNAUTHORIZED then
    begin
        raise TUnauthorizedException.Create(Response);
    end
    else if StatusCode = FORBIDDEN then
    begin
        raise TForbiddenException.Create(Response);
    end
    else if StatusCode = NOT_FOUND then
    begin
        raise TNotFoundException.Create(Response);
    end
    else if StatusCode = CONFLICT then
    begin
        raise TConflictException.Create(Response);
    end
    else if StatusCode = UNPROCESSABLE_ENTITY then
    begin
        raise TUnprocessableEntityException.Create(Response);
    end
    else if StatusCode = INTERNAL_SERVER_ERROR then
    begin
        raise TInternalServerErrorException.Create(Response);
    end
    else if StatusCode = SERVICE_UNAVAILABLE then
    begin
        raise TServiceUnavailableException.Create(Response);
    end
    else begin
        level := Floor(statusCode/100);

        if level = 4 then
        begin
            raise TRequestException.Create('Client error', StatusCode, Response);
        end
        else if level = 5 then
        begin
            raise TRequestException.Create('Server error', StatusCode, Response);
        end
        else begin
            raise TRequestException.Create('Unsuccessful request', StatusCode, Response);
        end;
    end;
end;

function THttpClient.SetRequestTimeout(value: Integer): THttpClient;
begin
    Result := self;
    self.FRequestTimeout := value;
end;

function THttpClient.SetResponse(value: TResponse): THttpClient;
begin
    Result := self;
    self.FResponse := value;
end;

function THttpClient.SetUserAgent(value: string): THttpClient;
begin
    Result := Self;
    self.FUserAgent := value;
end;

function THttpClient.SetBody(body: string): THttpClient;
begin
    Result := self.SetBody(TStringStream.Create(body, TEncoding.UTF8));
end;

end.

