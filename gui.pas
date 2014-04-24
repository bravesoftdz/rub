PROGRAM gui;

{ ******************************* REMARK ****************************** }
(* adapted from the example frevision test code. this code will become
   more interesting over time as the adaptations happen.

                                                                       *)
{  This is a basic test program to test the app framework. In use will  }
{  be menus, statuslines, windows, dialogs, scrollbars, statictext,     }
{  radiobuttons, check boxes, list boxes and input lines.               }
{                                                                       }
{  Working compilers:                                                   }
{     Customized for unix/linux due to sounds and ...                   }
{ ****************************** END REMARK *** Leon de Boer, 06Nov99 * }

uses unix, objects, drivers, views, editors, menus, dialogs, app,             { Standard GFV units }
     FVConsts, gadgets, timeddlg, msgbox, stddlg;


const
        cmAppToolbar = 1000;
        cmWindow1    = 1001;
        cmWindow2    = 1002;
        cmWindow3    = 1003;
        cmTimedBox   = 1004;
        cmCloseWindow1    = 1101;
        cmCloseWindow2    = 1102;
        cmCloseWindow3    = 1103;

type
        PGUIApp = ^GUIApp;

        { GUIApp }

        GUIApp = OBJECT (TApplication)
                ClipboardWindow: PEditWindow;
                Clock: PClockView;
                Heap: PHeapView;
                P1,P2,P3 : PGroup;
                CONSTRUCTOR Init;
                PROCEDURE Idle; Virtual;
                PROCEDURE HandleEvent(var Event : TEvent);virtual;
                PROCEDURE InitMenuBar; Virtual;
                PROCEDURE InitDeskTop; Virtual;
                PROCEDURE InitStatusLine; Virtual;
                PROCEDURE Window1;
                PROCEDURE Window2;
                PROCEDURE Window3;
                PROCEDURE TimedBox;
                PROCEDURE ShowAboutBox;
                PROCEDURE NewEditWindow;
                PROCEDURE OpenFile;
                PROCEDURE CloseWindow(var P : PGroup);
        End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                           GUIApp OBJECT METHODS                          }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

CONSTRUCTOR GUIApp.Init;
VAR R: TRect;
BEGIN
  EditorDialog := @StdEditorDialog;
  Inherited Init;
  { Initialize demo gadgets }

  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  GetExtent(R);
  ClipboardWindow := New(PEditWindow, Init(R, '', wnNoNumber));
  if ValidView(ClipboardWindow) <> nil then
  begin
    ClipboardWindow^.Hide;
    ClipboardWindow^.Editor^.CanUndo := False;
    InsertWindow(ClipboardWindow);
    Clipboard := ClipboardWindow^.Editor;
  end;
END;

procedure GUIApp.Idle;

function IsTileable(P: PView): Boolean; far;
begin
  IsTileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;

begin
  inherited Idle;
  Clock^.Update;
  Heap^.Update;
  if Desktop^.FirstThat(@IsTileable) <> nil then
    EnableCommands([cmTile, cmCascade])
  else
    DisableCommands([cmTile, cmCascade]);
end;

PROCEDURE GUIApp.HandleEvent(var Event : TEvent);
BEGIN
   Inherited HandleEvent(Event);                      { Call ancestor }
   If (Event.What = evCommand) Then Begin
     Case Event.Command Of
       cmClipBoard:
         begin
           ClipboardWindow^.Select;
           ClipboardWindow^.Show;
         end;
       cmNew     : NewEditWindow;
       cmOpen    : OpenFile;
       cmWindow1 : Window1;
       cmWindow2 : Window2;
       cmWindow3 : Window3;
       cmTimedBox: TimedBox;
       cmCloseWindow1 : CloseWindow(P1);
       cmCloseWindow2 : CloseWindow(P2);
       cmCloseWindow3 : CloseWindow(P3);
       cmAbout: ShowAboutBox;
       Else Exit;                                     { Unhandled exit }
     End;
   End;
   ClearEvent(Event);
END;

{--GUIApp------------------------------------------------------------------}
{  InitMenuBar -> Platforms DOS/DPMI/WIN/NT/OS2 - Updated 05Nov99 LdB       }
{---------------------------------------------------------------------------}
PROCEDURE GUIApp.InitMenuBar;
VAR R: TRect;
BEGIN
   GetExtent(R);                                      { Get view extents }
   R.B.Y := R.A.Y + 1;                                { One line high  }
   MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', 0, NewMenu(
      StdFileMenuItems(Nil)),                         { Standard file menu }
    NewSubMenu('~E~dit', 0, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~V~iew Clipboard', '', kbNoKey, cmClipboard, hcNoContext,
      nil)))),                 { Standard edit menu plus view clipboard}
    NewSubMenu('~T~est', 0, NewMenu(
      NewItem('Window ~1~','',kbNoKey,cmWindow1,hcNoContext,
      NewItem('Window ~2~','',kbNoKey,cmWindow2,hcNoContext,
      NewItem('Window ~3~','',kbNoKey,cmWindow3,hcNoContext,
      NewItem('~T~imed Box','',kbNoKey,cmTimedBox,hcNoContext,
      NewItem('Close Window 1','',kbNoKey,cmCloseWindow1,hcNoContext,
      NewItem('Close Window 2','',kbNoKey,cmCloseWindow2,hcNoContext,
      NewItem('Close Window 3','',kbNoKey,cmCloseWindow3,hcNoContext,
      Nil)))))))),
    NewSubMenu('~W~indow', 0, NewMenu(
      StdWindowMenuItems(Nil)),        { Standard window  menu }
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout...','',kbNoKey,cmAbout,hcNoContext,
      nil)),
    nil))))) //end NewSubMenus
   ))); //end MenuBar
END;

{--GUIApp------------------------------------------------------------------}
{  InitDesktop -> Platforms DOS/DPMI/WIN/NT/OS2 - Updated 08Nov99 LdB       }
{---------------------------------------------------------------------------}
PROCEDURE GUIApp.InitDesktop;
VAR R: TRect; {ToolBar: PToolBar;}
BEGIN
   GetExtent(R);                                      { Get app extents }
   Inc(R.A.Y);               { Adjust top down }
   Dec(R.B.Y);            { Adjust bottom up }
   Desktop := New(PDeskTop, Init(R));
END;

procedure GUIApp.InitStatusLine;
var
   R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  R.B.X := R.B.X - 12;
  New(StatusLine,
    Init(R,
      NewStatusDef(0, $EFFF,
        NewStatusKey('~F3~ Open', kbF3, cmOpen,
        NewStatusKey('~F4~ New', kbF4, cmNew,
        NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
        StdStatusKeys(nil
        )))),nil
      )
    )
  );

  GetExtent(R);
  R.A.X := R.B.X - 12; R.A.Y := R.B.Y - 1;
  Heap := New(PHeapView, Init(R));
  Insert(Heap);
end;

PROCEDURE GUIApp.Window1;
VAR R: TRect; P: PGroup;
BEGIN
   { Create a basic window with static text and radio }
   { buttons. The buttons should be orange and white  }
   R.Assign(5, 1, 35, 16);                            { Assign area }
   P := New(PWindow, Init(R, 'TEST WINDOW 1', 1));    { Create a window }
   If (P <> Nil) Then Begin                           { Window valid }
     R.Assign(5, 5, 20, 6);                           { Assign area }
     P^.Insert(New(PInputLine, Init(R, 30)));
     R.Assign(5, 8, 20, 9);                           { Assign area }
     P^.Insert(New(PRadioButtons, Init(R,
       NewSItem('Test',
       NewSITem('Item 2', Nil)))));                   { Red radio button }
     R.Assign(5, 10, 28, 11);                         { Assign area }
     P^.Insert(New(PStaticText, Init(R,
       'SOME STATIC TEXT')));                         { Insert static text }
   End;
   Desktop^.Insert(P);                                { Insert into desktop }
   P1:=P;
END;

PROCEDURE GUIApp.ShowAboutBox;
begin
  MessageBox(#3'Rubikon GUI Application'#13 +
    #3'Written in Free Pascal Free Vision'#13+
    #3'(www.freepascal.org)',
    nil, mfInformation or mfOKButton);
end;

PROCEDURE GUIApp.NewEditWindow;
var
  R: TRect;
begin
  R.Assign(0, 0, 60, 20);
  InsertWindow(New(PEditWindow, Init(R, '', wnNoNumber)));
end;

PROCEDURE GUIApp.OpenFile;
var
  R: TRect;
  FileDialog: PFileDialog;
  FileName: FNameStr;
const
  FDOptions: Word = fdOKButton or fdOpenButton;
begin
  FileName := '*.*';
  New(FileDialog, Init(FileName, 'Open file', '~F~ile name', FDOptions, 1));
  if ExecuteDialog(FileDialog, @FileName) <> cmCancel then
  begin
    R.Assign(0, 0, 75, 20);
    InsertWindow(New(PEditWindow, Init(R, FileName, wnNoNumber)));
  end;
end;

PROCEDURE GUIApp.TimedBox;
var
  X: longint;
  S: string;
begin
  X := TimedMessageBox ('Everything OK?', nil, mfConfirmation or mfOKCancel, 10);
  case X of
   cmCancel: MessageBox ('cmCancel', nil, mfOKButton);
   cmOK: MessageBox ('cmOK', nil, mfOKButton);
  else
   begin
    Str (X, S);
    MessageBox (S, nil, mfOKButton);
   end;
  end;
end;

PROCEDURE GUIApp.CloseWindow(var P : PGroup);
BEGIN
  If Assigned(P) then
    BEGIN
      Desktop^.Delete(P);
      Dispose(P,Done);
      P:=Nil;
    END;
END;

PROCEDURE GUIApp.Window2;
VAR R: TRect; P: PGroup;
BEGIN
   { Create a basic window with check boxes. The  }
   { check boxes should be orange and white       }
   R.Assign(15, 3, 45, 18);                           { Assign area }
   P := New(PWindow, Init(R, 'TEST WINDOW 2', 2));    { Create window 2 }
   If (P <> Nil) Then Begin                           { Window valid }
     R.Assign(5, 5, 20, 7);                           { Assign area }
     P^.Insert(New(PCheckBoxes, Init(R,
       NewSItem('Test check',
       NewSITem('Item 2', Nil)))));                   { Create check box }
   End;
   Desktop^.Insert(P);                                { Insert into desktop }
   P2:=P;
END;

PROCEDURE GUIApp.Window3;
VAR R: TRect; P: PGroup; B: PScrollBar;
    List: PStrCollection; Lb: PListBox;
BEGIN
   { Create a basic dialog box. In it are buttons,  }
   { list boxes, scrollbars, inputlines, checkboxes }
   R.Assign(32, 2, 77, 18);                           { Assign screen area }
   P := New(PDialog, Init(R, 'TEST DIALOG'));         { Create dialog }
   If (P <> Nil) Then Begin                           { Dialog valid }
     R.Assign(5, 5, 20, 7);                          { Allocate area }
     P^.Insert(New(PCheckBoxes, Init(R,
       NewSItem('Test',
       NewSITem('Item 2', Nil)))));                   { Insert check box }
     R.Assign(5, 2, 20, 3);                           { Assign area }
     B := New(PScrollBar, Init(R));                   { Insert scroll bar }
     If (B <> Nil) Then Begin                         { Scrollbar valid }
       B^.SetRange(0, 100);                           { Set scrollbar range }
       B^.SetValue(50);                               { Set position }
       P^.Insert(B);                                  { Insert scrollbar }
     End;
     R.Assign(5, 10, 20, 11);                         { Assign area }
     P^.Insert(New(PInputLine, Init(R, 60)));         { Create input line }
     R.Assign(5, 13, 20, 14);                         { Assign area }
     P^.Insert(New(PInputLine, Init(R, 60)));         { Create input line }
     R.Assign(40, 8, 41, 14);                         { Assign area }
     B := New(PScrollBar, Init(R));                   { Create scrollbar }
     P^.Insert(B);                                    { Insert scrollbar }
     R.Assign(25, 8, 40, 14);                         { Assign area }
     Lb := New(PListBox, Init(R, 1, B));              { Create listbox }
     P^.Insert(Lb);                                   { Insert listbox }
     List := New(PStrCollection, Init(10, 5));        { Create string list }
     List^.AtInsert(0, NewStr('Zebra'));              { Insert text }
     List^.AtInsert(1, NewStr('Apple'));              { Insert text }
     List^.AtInsert(2, NewStr('Third'));              { Insert text }
     List^.AtInsert(3, NewStr('Peach'));              { Insert text }
     List^.AtInsert(4, NewStr('Rabbit'));             { Insert text }
     List^.AtInsert(5, NewStr('Item six'));           { Insert text }
     List^.AtInsert(6, NewStr('Jaguar'));             { Insert text }
     List^.AtInsert(7, NewStr('Melon'));              { Insert text }
     List^.AtInsert(8, NewStr('Ninth'));              { Insert text }
     List^.AtInsert(9, NewStr('Last item'));          { Insert text }
     Lb^.Newlist(List);                               { Give list to listbox }
     R.Assign(30, 2, 40, 4);                          { Assign area }
     P^.Insert(New(PButton, Init(R, '~O~k', 100, bfGrabFocus)));{ Create okay button }
     R.Assign(30, 15, 40, 17);                        { Assign area }
     Desktop^.Insert(P);                              { Insert dialog }
     P3:=P;
   End;
END;

        procedure play(n: ansistring);
        begin
                shell('aplay ' + n + ' 2> /dev/null &');
        end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                             MAIN PROGRAM START                            }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
VAR
        I: Integer;
        R: TRect;
        P: PGroup;
        MyApp: GUIApp;

BEGIN

   play('explode.wav');
   MyApp.Init;                                        { Initialize app }
   MyApp.Run;                                         { Run the app }
   MyApp.Done;                                        { Dispose of app }

END.
