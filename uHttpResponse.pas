unit uHttpResponse;

interface

uses
    Classes, System.SysUtils, System.Generics.Collections, DBXJSON, XMLDoc;

type
    TResponse = class
        private
            FCode: integer;
            FBody: TStringStream;
            function GetBodyAsString: string;
            function GetBodyAsJson: TJSONValue;
            function GetBodyAsJsonObject: TJSONObject;
            function GetBodyAsStream: TStringStream;
        public
            constructor create(body: string; code: integer);
            destructor Destroy; override;
        published
            property StatusCode: Integer read FCode;
            property BodyAsString: string read GetBodyAsString;
            property BodyAsJson: TJSONValue read GetBodyAsJson;
            property BodyAsJsonObject: TJSONObject read GetBodyAsJsonObject;
            property BodyAsStream: TStringStream read GetBodyAsStream;
    end;

implementation

{ Response }

destructor TResponse.Destroy;
begin
    if Assigned(self.FBody) then
        FreeAndNil(self.FBody);

    inherited;
end;

function TResponse.GetBodyAsJson: TJSONValue;
begin
    Result := TJSONObject.ParseJSONValue(self.BodyAsString);
end;

function TResponse.GetBodyAsJsonObject: TJSONObject;
begin
    Result := self.BodyAsJson as TJSONObject;
end;

function TResponse.GetBodyAsStream: TStringStream;
begin
     Result := self.FBody;
end;

function TResponse.GetBodyAsString: string;
begin
    Result := self.FBody.DataString;
end;

constructor TResponse.create(body: string; code: integer);
begin
    self.FCode := code;
    self.FBody := TStringStream.Create(body, TEncoding.UTF8);
end;

end.
