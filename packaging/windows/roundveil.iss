#ifndef AppVersion
  #define AppVersion "1.0.0-alpha.2"
#endif
#ifndef AppNumericVersion
  #define AppNumericVersion "1.0.0.2"
#endif

#define AppName "ROUNDVEIL"
#define AppPublisher "ROUNDVEIL"
#define AppExeName "roundveil.exe"

[Setup]
AppId={{5EFDA2D4-6C83-4739-AD1F-4BA6CF90A487}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={localappdata}\Programs\ROUNDVEIL
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}
OutputDir=..\..\dist
OutputBaseFilename=ROUNDVEIL-Setup-v{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppNumericVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &Desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\ROUNDVEIL"; Filename: "{app}\roundveil.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\ROUNDVEIL"; Filename: "{app}\roundveil.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\roundveil.exe"; Description: "Launch ROUNDVEIL"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent
