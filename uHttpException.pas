unit uHttpException;

interface

uses
    System.SysUtils, uHttpResponse;

const CONTINUE                          = 100;
const SWITCHING_PROTOCOLS               = 101;
const PROCESSING                        = 102;
const CHECKPOINT                        = 103;
const OK                                = 200;
const CREATED                           = 201;
const ACCEPTED                          = 202;
const NON_AUTHORITATIVE_INFORMATION     = 203;
const NO_CONTENT                        = 204;
const RESET_CONTENT                     = 205;
const PARTIAL_CONTENT                   = 206;
const MULTI_STATUS                      = 207;
const ALREADY_REPORTED                  = 208;
const IM_USED                           = 226;
const MULTIPLE_CHOICES                  = 300;
const MOVED_PERMANENTLY                 = 301;
const FOUND                             = 302;
const SEE_OTHER                         = 303;
const NOT_MODIFIED                      = 304;
const USE_PROXY                         = 305;
const TEMPORARY_REDIRECT                = 307;
const PERMANENT_REDIRECT                = 308;
const BAD_REQUEST                       = 400;
const UNAUTHORIZED                      = 401;
const PAYMENT_REQUIRED                  = 402;
const FORBIDDEN                         = 403;
const NOT_FOUND                         = 404;
const METHOD_NOT_ALLOWED                = 405;
const NOT_ACCEPTABLE                    = 406;
const PROXY_AUTHENTICATION_REQUIRED     = 407;
const REQUEST_TIMEOUT                   = 408;
const CONFLICT                          = 409;
const GONE                              = 410;
const LENGTH_REQUIRED                   = 411;
const PRECONDITION_FAILED               = 412;
const PAYLOAD_TOO_LARGE                 = 413;
const URI_TOO_LONG                      = 414;
const UNSUPPORTED_MEDIA_TYPE            = 415;
const REQUESTED_RANGE_NOT_SATISFIABLE   = 416;
const EXPECTATION_FAILED                = 417;
const I_AM_A_TEAPOT                     = 418;
const UNPROCESSABLE_ENTITY              = 422;
const LOCKED                            = 423;
const FAILED_DEPENDENCY                 = 424;
const TOO_EARLY                         = 425;
const UPGRADE_REQUIRED                  = 426;
const PRECONDITION_REQUIRED             = 428;
const TOO_MANY_REQUESTS                 = 429;
const REQUEST_HEADER_FIELDS_TOO_LARGE   = 431;
const UNAVAILABLE_FOR_LEGAL_REASONS     = 451;
const INTERNAL_SERVER_ERROR             = 500;
const NOT_IMPLEMENTED                   = 501;
const BAD_GATEWAY                       = 502;
const SERVICE_UNAVAILABLE               = 503;
const GATEWAY_TIMEOUT                   = 504;
const HTTP_VERSION_NOT_SUPPORTED        = 505;
const VARIANT_ALSO_NEGOTIATES           = 506;
const INSUFFICIENT_STORAGE              = 507;
const LOOP_DETECTED                     = 508;
const BANDWIDTH_LIMIT_EXCEEDED          = 509;
const NOT_EXTENDED                      = 510;
const NETWORK_AUTHENTICATION_REQUIRED   = 511;

type
    TRequestException = class(Exception)
        private
            FCode: Integer;
            FResponse: string;
        public
            constructor Create(msg: string; Code: Integer; response: string);
        published
            property Code: Integer read FCode;
            property Response: string read FResponse;
    end;

    TBadRequestException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TUnauthorizedException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TForbiddenException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TNotFoundException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TConflictException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TUnprocessableEntityException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TInternalServerErrorException = class(TRequestException)
        constructor Create(Response: string);
    end;

    TServiceUnavailableException = class(TRequestException)
        constructor Create(Response: string);
    end;

implementation


{ TRequestException }

constructor TRequestException.Create(msg: string; Code: Integer; Response: string);
begin
    self.FResponse  := Response;
    self.FCode      := code;
    inherited Create(msg);
end;

{ TBadRequestException }

constructor TBadRequestException.Create(response: string);
begin
    inherited create('Bad Request', BAD_REQUEST, response);
end;

{ TUnauthorizedException }

constructor TUnauthorizedException.Create(response: string);
begin
    inherited create('Unauthorized', UNAUTHORIZED, response);
end;

{ TServiceUnavailableException }

constructor TServiceUnavailableException.Create(response: string);
begin
    inherited create('Service Unavailable', SERVICE_UNAVAILABLE, Response);
end;

{ TForbiddenException }

constructor TForbiddenException.Create(Response: string);
begin
    inherited create('Forbidden', FORBIDDEN, Response);
end;

{ TConflictException }

constructor TConflictException.Create(Response: string);
begin
    inherited create('Conflict', CONFLICT, Response);
end;

{ TInternalServerErrorException }

constructor TInternalServerErrorException.Create(Response: string);
begin
    inherited create('Internal Server Error', INTERNAL_SERVER_ERROR, Response);
end;

{ TNotFoundException }

constructor TNotFoundException.Create(Response: string);
begin
    inherited create('Not Found', NOT_FOUND, Response);
end;

{ TUnprocessableEntityException }

constructor TUnprocessableEntityException.Create(Response: string);
begin
    inherited create('Unprocessable Entity', UNPROCESSABLE_ENTITY, Response);
end;

end.
