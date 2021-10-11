unit psf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, Tlhelp32, Grids;

const
  whProcess = 1;
  whThread = 2;
  whModule = 3;

type
  TForm1 = class(TForm)
    Grid: TStringGrid;
    PopupMenu1: TPopupMenu;
    Refresh1: TMenuItem;
    N1: TMenuItem;
    Closeprocess1: TMenuItem;
    Threads1: TMenuItem;
    Modules1: TMenuItem;
    N2: TMenuItem;
    About1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure Closeprocess1Click(Sender: TObject);
    procedure Threads1Click(Sender: TObject);
    procedure Modules1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    What: Byte;
  public
    procedure MakeProcessList;
    procedure MakeThreadList;
    procedure MakeModuleList;
  end;

var
  Form1: TForm1;

resourcestring
  sPS = 'Processess, Threads, Modules - %s';
  sPL = 'processes';
  sML = 'modules';
  sTL = 'threads';
  sAbout = 'PS Copyright (c) 2002 by MandysSoft';
implementation
uses
  AuxStr;

{$R *.DFM}

procedure TForm1.MakeProcessList;
var
  H: THandle;
  pe: TProcessEntry32;
  B: Boolean;
  R: Integer;
begin
  What:= whProcess;
  Caption:= Format(sPS, [sPL]);
  R:= Grid.Row;
  Grid.ColCount:= 8;
  Grid.DefaultColWidth:= 64;
  Grid.ColWidths[0]:= 250;
  Grid.RowCount:= 2;
  Grid.Cells[0,0]:= 'Exe';
  Grid.Cells[1,0]:= 'PId';
  Grid.Cells[2,0]:= 'Usage';
  Grid.Cells[3,0]:= 'ModuleId';
  Grid.Cells[4,0]:= 'HeapId';
  Grid.Cells[5,0]:= '#Threads';
  Grid.Cells[6,0]:= 'PPId';
  Grid.Cells[7,0]:= 'PriClassBase';
  H:= CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  try
    pe.dwSize:= SizeOf(pe);
    B:= Process32First(H, pe);
    while B do
    begin
      Grid.Cells[0,Grid.RowCount-1]:= StrPas(pe.szExeFile);
      Grid.Cells[1,Grid.RowCount-1]:= NumToHexStrI(pe.th32ProcessId, 8);
      Grid.Cells[2,Grid.RowCount-1]:= IntToStr(pe.cntUsage);
      Grid.Cells[3,Grid.RowCount-1]:= NumToHexStrI(pe.th32ModuleId, 8);
      Grid.Cells[4,Grid.RowCount-1]:= NumToHexStrI(pe.th32DefaultHeapId, 8);
      Grid.Cells[5,Grid.RowCount-1]:= IntToStr(pe.cntThreads);
      Grid.Cells[6,Grid.RowCount-1]:= NumToHexStrI(pe.th32ParentProcessId, 8);
      Grid.Cells[7,Grid.RowCount-1]:= IntToStr(pe.pcPriClassBase);

      B:= Process32Next(H, pe);
      if B then
        Grid.RowCount:= Grid.RowCount+1;
    end;
  finally
    CloseHandle(H);
  end;
  if Grid.RowCount > R then
    Grid.Row:= R;
  Closeprocess1.Enabled:= True;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  MakeProcessList;
end;

procedure TForm1.Refresh1Click(Sender: TObject);
begin
  MakeProcessList;
end;

procedure TForm1.Closeprocess1Click(Sender: TObject);
var
  Id: Integer;
  H: THandle;
  P: PChar;
  Fl: Boolean;
begin
  Fl:= True;
  case What of
    whProcess:
      begin
        Id:= StrToNum(Grid.Cells[1, Grid.Row]);
        H:= OpenProcess(PROCESS_ALL_ACCESS, True, Id);
        Fl:= TerminateProcess(H, 0);
        CloseHandle(H);
        MakeProcessList;
      end;
    whThread:
      begin
//        Id:= StrToNum(Grid.Cells[0, Grid.Row]);
//        Fl:= TerminateThread(H, 0);
      end;
  end;
  if not Fl then
  begin
    FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError(), 0, @P, 0, nil);
    ShowMessage(StrPas(P));
  end;
end;

procedure TForm1.MakeModuleList;
var
  H: THandle;
  pe: TModuleEntry32;
  B: Boolean;
  R: Integer;
begin
  What:= whModule;
  Caption:= Format(sPS, [sML]);
  R:= Grid.Row;
  Grid.ColCount:= 7;
  Grid.DefaultColWidth:= 64;
  Grid.ColWidths[0]:= 100;
  Grid.ColWidths[1]:= 250;
  Grid.RowCount:= 2;
  Grid.Cells[0,0]:= 'Name';
  Grid.Cells[1,0]:= 'Path';
  Grid.Cells[2,0]:= 'MId';
  Grid.Cells[3,0]:= 'PId';
  Grid.Cells[4,0]:= 'GUsage';
  Grid.Cells[5,0]:= 'PUsage';
  Grid.Cells[6,0]:= 'HModule';
  H:= CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  try
    pe.dwSize:= SizeOf(pe);
    B:= Module32First(H, pe);
    while B do
    begin
      Grid.Cells[0,Grid.RowCount-1]:= StrPas(pe.szModule);
      Grid.Cells[1,Grid.RowCount-1]:= StrPas(pe.szExePath);
      Grid.Cells[2,Grid.RowCount-1]:= NumToHexStrI(pe.th32ModuleId, 8);
      Grid.Cells[3,Grid.RowCount-1]:= NumToHexStrI(pe.th32ProcessId, 8);
      Grid.Cells[4,Grid.RowCount-1]:= IntToStr(pe.GlblcntUsage);
      Grid.Cells[5,Grid.RowCount-1]:= IntToStr(pe.ProccntUsage);
      Grid.Cells[6,Grid.RowCount-1]:= NumToHexStrI(pe.hModule, 8);

      B:= Module32Next(H, pe);
      if B then
        Grid.RowCount:= Grid.RowCount+1;
    end;
  finally
    CloseHandle(H);
  end;
  if Grid.RowCount > R then
    Grid.Row:= R;
  Closeprocess1.Enabled:= False;
end;

procedure TForm1.MakeThreadList;
var
  H: THandle;
  pe: TThreadEntry32;
  B: Boolean;
  R: Integer;
begin
  What:= whThread;
  Caption:= Format(sPS, [sTL]);
  R:= Grid.Row;
  Grid.ColCount:= 5;
  Grid.DefaultColWidth:= 64;
  Grid.RowCount:= 2;
  Grid.Cells[0,0]:= 'TId';
  Grid.Cells[1,0]:= 'Usage';
  Grid.Cells[2,0]:= 'PId';
  Grid.Cells[3,0]:= 'BasePri';
  Grid.Cells[4,0]:= 'DeltaPri';
  H:= CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  try
    pe.dwSize:= SizeOf(pe);
    B:= Thread32First(H, pe);
    while B do
    begin
      Grid.Cells[0,Grid.RowCount-1]:= NumToHexStrI(pe.th32ThreadId, 8);
      Grid.Cells[1,Grid.RowCount-1]:= IntToStr(pe.cntUsage);
      Grid.Cells[2,Grid.RowCount-1]:= NumToHexStrI(pe.th32OwnerProcessId, 8);
      Grid.Cells[3,Grid.RowCount-1]:= IntToStr(pe.tpBasePri);
      Grid.Cells[4,Grid.RowCount-1]:= IntToStr(pe.tpDeltaPri);

      B:= Thread32Next(H, pe);
      if B then
        Grid.RowCount:= Grid.RowCount+1;
    end;
  finally
    CloseHandle(H);
  end;
  if Grid.RowCount > R then
    Grid.Row:= R;
  Closeprocess1.Enabled:= False;
end;

procedure TForm1.Threads1Click(Sender: TObject);
begin
  MakeThreadList;
end;

procedure TForm1.Modules1Click(Sender: TObject);
begin
  MakeModuleList;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  MessageDlg(sAbout, mtInformation, [mbOk], 0);
end;

end.
