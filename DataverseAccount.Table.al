table 50112 "Dataverse Account"
{
    DataClassification = CustomerContent;
    Caption = 'Dataverse Account';

    fields
    {
        field(1; Account; Guid)
        {
            Caption = 'Account';
            DataClassification = CustomerContent;
        }
        field(2; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
        }
        field(3; "Main Phone"; Text[30])
        {
            ExtendedDatatype = PhoneNo;
            Caption = 'Main Phone';
            DataClassification = CustomerContent;
        }
        field(4; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(5; "Website Url"; Text[100])
        {
            Caption = 'Website URL';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Account)
        {
            Clustered = true;
        }
        key(Key1; "Account Name")
        {
        }
    }

    trigger OnInsert()
    var
        DataverseHandler: Codeunit DataverseHandler;
    begin
        DataverseHandler.InsertAccountsToDataverse(Rec);
    end;

    trigger OnModify()
    var
        DataverseHandler: Codeunit DataverseHandler;
    begin
        DataverseHandler.UpdateAccountsToDataverse(Rec);
    end;

    trigger OnDelete()
    var
        DataverseHandler: Codeunit DataverseHandler;
    begin
        DataverseHandler.DeleteAccountsFromDataverse(Rec);
    end;
}
