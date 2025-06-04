page 50101 "Dataverse Accounts"
{
    ApplicationArea = All;
    Caption = 'Dataverse Accounts';
    PageType = List;
    SourceTable = "Dataverse Account";
    UsageCategory = Lists;
    SourceTableView = sorting("Account Name");
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Account; Rec.Account)
                {
                    ToolTip = 'Specifies the value of the Account field.', Comment = '%';
                    Editable = false;
                    Visible = false;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ToolTip = 'Specifies the value of the Account Name field.', Comment = '%';
                }
                field("Main Phone"; Rec."Main Phone")
                {
                    ToolTip = 'Specifies the value of the Main Phone field.', Comment = '%';
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field.', Comment = '%';
                }
                field("Primary Contact"; Rec."Website Url")
                {
                    ToolTip = 'Specifies the value of the Primary Contact field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GetDataFromDataverse)
            {
                ApplicationArea = All;
                Caption = 'Get Data from Dataverse';
                Promoted = true;
                PromotedCategory = Process;
                Image = GetLines;

                trigger OnAction()
                var
                    DataverseHandler: Codeunit DataverseHandler;
                begin
                    DataverseHandler.GetAccountsFromDataverse();
                end;
            }
        }
    }
}
