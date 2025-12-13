; LangM Installer Script for Inno Setup
; 下载 Inno Setup: https://jrsoftware.org/isinfo.php

#define MyAppName "LangM"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "LangM"
#define MyAppURL "https://github.com/user/langm"
#define MyAppExeName "langm.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=LangM-Setup-{#MyAppVersion}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ChangesEnvironment=yes
; 简化安装界面
DisableWelcomePage=no
DisableDirPage=yes
DisableReadyPage=yes
DisableProgramGroupPage=yes

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\target\release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
; 创建 .langm 目录结构
Name: "{userappdata}\..\\.langm"
Name: "{userappdata}\..\\.langm\\current"
Name: "{userappdata}\..\\.langm\\current\\bin"

[Registry]
; 添加 langm.exe 所在目录到 PATH
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; \
    Check: NeedsAddPath('{app}')

; 添加 ~/.langm/current/bin 到 PATH（运行时切换后的路径）
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{%USERPROFILE}\.langm\current\bin"; \
    Check: NeedsAddPath('{%USERPROFILE}\.langm\current\bin')

[Code]
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
  ExpandedParam: string;
begin
  ExpandedParam := ExpandConstant(Param);
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + ExpandedParam + ';', ';' + OrigPath + ';') = 0;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  Path: string;
  AppPath: string;
  LangmPath: string;
  P: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE,
      'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
      'Path', Path) then
    begin
      // 移除安装目录
      AppPath := ExpandConstant('{app}');
      P := Pos(';' + AppPath, Path);
      if P > 0 then
        Delete(Path, P, Length(';' + AppPath));
      
      // 移除 .langm\current\bin
      LangmPath := ExpandConstant('{%USERPROFILE}\.langm\current\bin');
      P := Pos(';' + LangmPath, Path);
      if P > 0 then
        Delete(Path, P, Length(';' + LangmPath));
        
      RegWriteStringValue(HKEY_LOCAL_MACHINE,
        'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
        'Path', Path);
    end;
  end;
end;

[Messages]
chinesesimplified.WelcomeLabel1=欢迎安装 LangM
chinesesimplified.WelcomeLabel2=LangM 是一个多语言运行时管理器%n让你在 Node.js、JDK 和 GraalVM 之间自由切换。%n%n点击"下一步"开始安装。
chinesesimplified.FinishedHeadingLabel=安装完成
chinesesimplified.FinishedLabel=LangM 已成功安装！%n%n[重要] 请重新打开终端窗口，然后输入：%n%n  langm --help%n%n开始使用。
