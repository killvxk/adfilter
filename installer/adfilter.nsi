; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "adfilter"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\adfilter.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

!include "x64.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "..\license.txt"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\adfilter.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "Setup.exe"
InstallDir "$PROGRAMFILES\adfilter"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

; install


Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

; net 4.5
; see:https://stackoverflow.com/questions/12849352/nsis-installer-with-net-4-5
Function CheckAndInstallDotNet
    ; Magic numbers from http://msdn.microsoft.com/en-us/library/ee942965.aspx
    ClearErrors
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Release"

    IfErrors NotDetected

    ${If} $0 >= 378389

        DetailPrint "Microsoft .NET Framework 4.5 is installed ($0)"
    ${Else}
    NotDetected:
        DetailPrint "Installing Microsoft .NET Framework 4.5"
        File "res\dotNetFx45_Full_setup.exe"        
        SetDetailsPrint listonly
        ExecWait '"$INSTDIR\dotNetFx45_Full_setup.exe" /passive /norestart' $0
        ${If} $0 == 3010 
        ${OrIf} $0 == 1641
            DetailPrint "Microsoft .NET Framework 4.5 installer requested reboot"
            SetRebootFlag true
        ${EndIf}
        SetDetailsPrint lastused
        DetailPrint "Microsoft .NET Framework 4.5 installer returned $0"
    ${EndIf}

FunctionEnd
; net 4.5 end

Section "MainSection" SEC01
  
  
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "res\user.txt"
  File "res\sys.txt"
  File "res\except.txt"
  
  File "res\adfcon.exe"
  File "res\adfilter.exe"
  File "res\MahApps.Metro.dll"
  File "res\System.Windows.Interactivity.dll"
  CreateDirectory "$SMPROGRAMS\adfilter"
  CreateShortCut "$SMPROGRAMS\adfilter\adfilter.lnk" "$INSTDIR\adfilter.exe"
  CreateShortCut "$DESKTOP\adfilter.lnk" "$INSTDIR\adfilter.exe"
  File "res\adf.dll"

  ;font
  ; see:https://superuser.com/questions/201896/how-do-i-install-a-font-from-the-windows-command-prompt
   IfFileExists "$FONTS\segmdl2.ttf" Continue InstallFont
InstallFont:
  DetailPrint "install font"
  SetOutPath "$FONTS"
  File "res\segmdl2.ttf"
  nsExec::Exec "reg add $\"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts$\" /v $\"Segoe MDL2 Assets (TrueType)$\" /t REG_SZ /d segmdl2.ttf /f"
Continue:
  # Continue in installation...
  
  ; install driver
  DetailPrint "install driver..."
  ; x64 :https://stackoverflow.com/questions/13229212/how-to-detect-windows-32bit-or-64-bit-using-nsis-script
  ${If} ${RunningX64}
    DetailPrint "64-bit Windows"
    File "/oname=C:\Windows\System32\Drivers\adfilter.sys" "res\adfilter64.sys"    
  ${Else}
    DetailPrint "32-bit Windows"
    File "/oname=C:\Windows\System32\Drivers\adfilter.sys" "res\adfilter.sys"    
  ${EndIf} 
  nsExec::Exec "sc create adfilter binpath= system32\drivers\adfilter.sys start= auto type= kernel"
  WriteRegDWORD HKLM "SYSTEM\CurrentControlSet\services\adfilter" "Pause" "0"
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\adfilter" "SysFilePath" "$INSTDIR\sys.txt"
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\adfilter" "UserFilePath" "$INSTDIR\user.txt"
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\adfilter" "ExceptFilePath" "$INSTDIR\except.txt"
  nsExec::Exec "net start adfilter"

  ; check net 4.5
  Call CheckAndInstallDotNet


SectionEnd




Section -AdditionalIcons
  CreateShortCut "$SMPROGRAMS\adfilter\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\adfilter.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\adfilter.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
SectionEnd
; install end

; uninstall
Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "[adfilter] 已成功地从你的计算机移除。"
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你确实要完全移除 [adfilter] ，其及所有的组件？" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\dotNetFx45_Full_setup.exe"
  Delete "$INSTDIR\adf.dll"
  Delete "$INSTDIR\adfilter.exe"
  Delete "$INSTDIR\except.txt"
  Delete "$INSTDIR\sys.txt"
  Delete "$INSTDIR\user.txt"

  Delete "$INSTDIR\adfcon.exe"
  Delete "$INSTDIR\MahApps.Metro.dll"
  Delete "$INSTDIR\System.Windows.Interactivity.dll"

  Delete "$SMPROGRAMS\adfilter\Uninstall.lnk"
  Delete "$DESKTOP\adfilter.lnk"
  Delete "$SMPROGRAMS\adfilter\adfilter.lnk"
  Delete "$INSTDIR\segmdl2.ttf"


  RMDir "$SMPROGRAMS\adfilter"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"

  
  ;uninstall driver
  Delete "C:\Windows\System32\Drivers\adfilter.sys"
  nsExec::Exec "sc delete adfilter"

    MessageBox MB_YESNO|MB_ICONQUESTION "You reboot the system to finish uninstall." IDNO +2
    Reboot
  SetAutoClose true
SectionEnd
; uninstall end