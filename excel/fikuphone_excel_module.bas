Attribute VB_Name = "Module1"

Public Function HasCountryCallerPrefix(ByVal phoneNumber As String) As Boolean
   Dim callerPrefixArray() As String
   callerPrefixArray = Split("1-242,1-246,1-264,1-268,1-284,1-340,1-345,1-441,1-473,1-649,1-664,1-670,1-671,1-684,1-758,1-767,1-784,1-787,1-809,1-829,1-868,1-869,1-876,1-939,20,212,213,216,218,220,221,222,223,224,225,226,227,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,248,249,250,251,252,253,254,255,256,257,258,260,261,262,263,264,265,266,267,268,269,269,27,290,291,297,298,299,30,31,32,33,34,350,351,352,353,354,355,356,357,358,359,36,370,371,372,373,374,375,376,377,378,380,385,386,387,389,39,40,41,418,420,421,423,43,44,45,46,47,48,49,500,501,502,503,504,505,506,507,508,509,51,52,53,53,54,55,56,57,58,590,591,592,593,594,595,596,597,598,599,60,61,61,62,63,64,65,66,670,672,672,673,674,675,676,677,678,679,680,681,682,683,685,686,687,688,689,690,691,692,7,81,82,84,850,852,853,855,856,86,880,886,90,91,92,93,94,95,960,961,962,963,964,965,966,967,968,970,971,972,973,974,975,976,977,98,992,993,994,995,996,998", ",")

   For Each callerPrefix In callerPrefixArray
      If StartWithSubString("\+" & callerPrefix, Trim(phoneNumber)) Or StartWithSubString("00" & callerPrefix, Trim(phoneNumber)) Then
        HasCountryCallerPrefix = True
        Exit Function
      End If
   Next
   HasCountryCallerPrefix = False
   
End Function

Public Function StartWithSubString(ByVal substring As String, ByVal testString As String) As Boolean
    Set re = New RegExp
    re.Pattern = "^" & substring

    StartWithSubString = re.test(testString)
    
End Function

Public Function FormatPhoneNumber(ByVal numberPrefix As String, ByVal phoneNumber As String) As String
    Dim phoneNumberCut As String
    'ce se stevilka zacne s prefixom npr 386 brez plusa, pocisti vso nesnago znakov in dodaj +
    If StartWithSubString(numberPrefix, phoneNumber) Then
        FormatPhoneNumber = "+" & GetNumericValue(phoneNumber)
        Exit Function
    End If
    
    If Not HasCountryCallerPrefix(phoneNumber) Then
        phoneNumberCut = GetNumericValue(phoneNumber)
        'Ce obstaja vodilna nicla jo odstranimo
        If StartWithSubString("0", phoneNumberCut) Then
            phoneNumberCut = Right(phoneNumberCut, Len(phoneNumberCut) - 1)
        End If
        FormatPhoneNumber = "+" & numberPrefix & phoneNumberCut
        Exit Function
    End If
    
    phoneNumberCut = GetNumericValue(phoneNumber)
    If Not StartWithSubString("00", phoneNumberCut) Then
        FormatPhoneNumber = "+" & phoneNumberCut
    End If
    
    
End Function


Public Function GetNumericValue(ByVal phoneNumber As String)
    Set myRegExp = New RegExp
    myRegExp.IgnoreCase = True
    myRegExp.Global = True
    myRegExp.Pattern = "[\D]"

    GetNumericValue = myRegExp.Replace(phoneNumber, "")
End Function

Public Function FikusovTeleasistent(ByVal numberPrefix As String, ParamArray cells() As Variant) As Variant

    Dim Cell As Variant
    Dim SubCell As Variant

    For Each Cell In cells
        If VarType(Cell) > vbArray Then
            For Each SubCell In Cell
                If VarType(SubCell) <> vbEmpty Then
                    FikusovTeleasistent = FormatPhoneNumber(numberPrefix, SubCell)
                    Exit Function
                End If
            Next
        Else
            If VarType(Cell) <> vbEmpty Then
                FikusovTeleasistent = FormatPhoneNumber(numberPrefix, Cell)
                Exit Function
            End If
        End If
    Next
    FikusovTeleasistent = ""

End Function

