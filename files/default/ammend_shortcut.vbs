'# D.Collins - 12:58 03/09/2012
'# Sets a shortcut to have the RunAs flag set.  Drag an LNK file onto this script to test

Option Explicit

Dim oArgs, ret

Set oArgs = WScript.Arguments

If oArgs.Count > 0 Then
    ret = fSetRunAsOnLNK(oArgs(0))    
Else
    MsgBox "No Args"
End If

Function fSetRunAsOnLNK(sInputLNK)
    Dim fso, wshShell, oFile, iSize, aInput(), ts, i
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set wshShell = CreateObject("WScript.Shell")
    If Not fso.FileExists(sInputLNK) Then fSetRunAsOnLNK = 114017 : Exit Function
    Set oFile = fso.GetFile(sInputLNK)
    iSize = oFile.Size
    ReDim aInput(iSize)
    Set ts = oFile.OpenAsTextStream()
    i = 0
    Do While Not ts.AtEndOfStream
        aInput(i) = ts.Read(1)
        i = i + 1
    Loop
    ts.Close
    If UBound(aInput) < 50 Then fSetRunAsOnLNK = 114038 : Exit Function
    If (Asc(aInput(21)) And 32) = 0 Then 
        aInput(21) = Chr(Asc(aInput(21)) + 32)
    Else
        fSetRunAsOnLNK = 99 : Exit Function
    End If
    fso.CopyFile sInputLNK, wshShell.ExpandEnvironmentStrings("%temp%\" & oFile.Name & "." & Hour(Now()) & "-" & Minute(Now()) & "-" & Second(Now()))
    On Error Resume Next
    Set ts = fso.CreateTextFile(sInputLNK, True)
    If Err.Number <> 0 Then fSetRunAsOnLNK = Err.number : Exit Function
    ts.Write(Join(aInput, ""))
    If Err.Number <> 0 Then fSetRunAsOnLNK = Err.number : Exit Function
    ts.Close
    fSetRunAsOnLNK = 0
End Function