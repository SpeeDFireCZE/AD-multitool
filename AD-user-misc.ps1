#--------------------------------------viditelné jen GUI-----------------------------------------------#
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)



#---------------------------------okno--------------------------------------#
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form

$main_form.Text ='AD account management'
$main_form.BackColor = “black”
$main_form.ForeColor = “white”
#$main_form.Width = 410
#$main_form.Height = 400
$main_form.AutoSize = $true
$main_form.FormBorderStyle = 'FixedToolWindow'
$main_form.StartPosition = 'CenterScreen'



#---------------------------------načtení popup modulu--------------------------------------#
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             Proměnné sdílené napříč                                                                          #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
$Users = get-aduser -filter * -Properties SamAccountName 

#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             Admin Login                                                                                      #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
$Buttonlogin = New-Object System.Windows.Forms.Button
$Buttonlogin.BackColor =”LightGray”
$Buttonlogin.ForeColor = “black”
$Buttonlogin.Location = New-Object System.Drawing.Size(500,5)

$Buttonlogin.Size = New-Object System.Drawing.Size(90,20)

$Buttonlogin.Text = "AD login"
$Buttonlogin.Cursor="Hand"
$main_form.Controls.Add($Buttonlogin)

$Buttonlogin.Add_Click(
{
if ($Buttonlogin.Text -eq "AD login"){
Do {
$Script:Cred = Get-Credential -Message "Váš AD účet"

if($null -ne $Cred){
   #Get-ADUser -Credential $Cred -Properties LockedOut   
   $exitcodelogin=get-addomain -Credential $Cred | Select-Object -expand name  
}
else{
$credexit="False"
}
}
Until ($null -ne $exitcodelogin -or $credexit -eq "False")

$loggedinname= $cred | select-object -expand UserName
if($null -ne $exitcodelogin){
    $Buttonlogin.Text = $loggedinname
}
}
else{
$Buttonlogin.Text = "AD login"
$Cred > $null
}
}
)


#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             Default menu/menu1                                                                               #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#

#-------------------------------------user-menu-----------------------------------#
$Labelmenu1 = New-Object System.Windows.Forms.Label

$Labelmenu1.Text = "AD users"

$Labelmenu1.Location  = New-Object System.Drawing.Point(0,10)

$Labelmenu1.AutoSize = $true

$main_form.Controls.Add($Labelmenu1)

$ComboBoxmenu1 = New-Object System.Windows.Forms.ComboBox

$ComboBoxmenu1.Width = 300

Foreach ($User in $Users)

{

$ComboBoxmenu1.Items.Add($User.SamAccountName);

}

$ComboBoxmenu1.Location  = New-Object System.Drawing.Point(60,10)
$ComboBoxmenu1.AutoCompleteSource = 'ListItems'
$ComboBoxmenu1.AutoCompleteMode = 'Append'

$main_form.Controls.Add($ComboBoxmenu1)


#==================================================================kdy bylo heslo změněno - menu1=====================================================#
$Label2menu1 = New-Object System.Windows.Forms.Label

$Label2menu1.Text = "Poslední změna hesla:"

$Label2menu1.Location  = New-Object System.Drawing.Point(0,40)

$Label2menu1.AutoSize = $true

$main_form.Controls.Add($Label2menu1)

$Label3menu1 = New-Object System.Windows.Forms.Label

$Label3menu1.Text = ""

$Label3menu1.Location  = New-Object System.Drawing.Point(120,40)

$Label3menu1.AutoSize = $true

$main_form.Controls.Add($Label3menu1)

$Buttonmenu1 = New-Object System.Windows.Forms.Button
$Buttonmenu1.BackColor =”LightGray”
$Buttonmenu1.ForeColor = “black”
$Buttonmenu1.Location = New-Object System.Drawing.Size(210,35)

$Buttonmenu1.Size = New-Object System.Drawing.Size(160,23)

$Buttonmenu1.Text = "Check last password change"
$Buttonmenu1.Cursor="Hand"
$main_form.Controls.Add($Buttonmenu1)

$Buttonmenu1.Add_Click(

{

$Label3menu1.Text =  [datetime]::FromFileTime((Get-ADUser -identity $ComboBoxmenu1.selectedItem -Properties pwdLastSet).pwdLastSet).ToString('dd.MM.yy   hh:ss')



}

)





#============================================odemčení účtu-menu1============================================#


$Label4menu1 = New-Object System.Windows.Forms.Label

$Label4menu1.Text = "Uzamčeno/odemčeno:"

$Label4menu1.Location  = New-Object System.Drawing.Point(0,65)

$Label4menu1.AutoSize = $true


$main_form.Controls.Add($Label4menu1)

$Label5menu1 = New-Object System.Windows.Forms.Label

$Label5menu1.Text = ""

$Label5menu1.Location  = New-Object System.Drawing.Point(120,60)

$Label5menu1.AutoSize = $true

$main_form.Controls.Add($Label5menu1)

$button2menu1 = New-Object System.Windows.Forms.Button
$button2menu1.BackColor =”LightGray”
$button2menu1.ForeColor = “black”
$button2menu1.Location = New-Object System.Drawing.Size(210,60)

$button2menu1.Size = New-Object System.Drawing.Size(160,23)

$button2menu1.Text = "Odemknout účet"
$button2menu1.Cursor="Hand"
$main_form.Controls.Add($button2menu1)
$button2menu1.Add_Click(

{
#$Cred = Get-Credential
if($Buttonlogin.Text -ne "AD login"){
if($null -ne $ComboBoxmenu1.selectedItem){
    $locked = Get-ADUser -Credential $Cred -identity $ComboBoxmenu1.selectedItem -Properties * | Select-Object -expand LockedOut
    if($locked -eq "True"){
        Unlock-ADAccount -Credential $Cred -Identity $ComboBoxmenu1.selectedItem
        $Label5menu1.ForeColor = "yellow"
        $Label5menu1.Text = "Odemykám"
            start-sleep 5
            $locked = Get-ADUser -identity $ComboBoxmenu1.selectedItem -Properties * | Select-Object -expand LockedOut
         if ($locked -eq "True"){
            $Label5menu1.ForeColor = "red"
            $Label5menu1.Text = "Nelze odemknout"
            (New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Chyba, účet nelze odemknout",0,"Chyba",64)
         }
         else{
            $Label5menu1.ForeColor = "green"
            $Label5menu1.Text = "Odemčený"
         }
    }
    else{
        $Label5menu1.ForeColor = "green"
        $Label5menu1.Text = "Odemčený"

    }


}

else{
(New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Vyberte uživatele",0,"Chyba",64)
}
}
else{
    (New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Pro tuto funkci je vyžadován AD login",0,"Chyba",64)
}


}

)
#=========================================================================infobox-menu1===========================================================================================#
$infotextBoxmenu1 = New-Object System.Windows.Forms.TextBox
$infotextBoxmenu1.Multiline=$true 
$infotextBoxmenu1.ReadOnly=$true
$infotextBoxmenu1.ScrollBars="vertical"
$infotextBoxmenu1.Location = New-Object System.Drawing.Point(5,170)
$infotextBoxmenu1.Size = New-Object System.Drawing.Size(600,200)
$main_form.Controls.Add($infotextBoxmenu1)

$infotextBoxmenu1.Add_KeyDown({
    if (($_.Control) -and ($_.KeyCode -eq 'A')) {
       $infotextBoxmenu1.SelectAll()
    }
  })

$button3menu1 = New-Object System.Windows.Forms.Button
$button3menu1.BackColor =”LightGray”
$button3menu1.ForeColor = “black”
$button3menu1.Location = New-Object System.Drawing.Size(5,85)

$button3menu1.Size = New-Object System.Drawing.Size(365,23)

$button3menu1.Text = "Získat kompletní info"
$button3menu1.Cursor="Hand"
$main_form.Controls.Add($button3menu1)

$button3menu1.Add_Click(

{

$infotextBoxmenu1.Text= Get-ADUser -Identity $ComboBoxmenu1.selectedItem -Property * | Select-Object -Property * 
$infotextBoxmenu1.Text=$infotextBoxmenu1.Text.Replace(";","`r`n")
$infotextBoxmenu1.Text=$infotextBoxmenu1.Text.Replace("@{","")

$lines = $infotextBoxmenu1.Lines
    foreach ($line in $lines.Trim()){
        $findtextboxmenu1.Items.Add($line.split("=")[0]);
    }
    $findtextboxmenu1.AutoCompleteSource = 'ListItems'
    $findtextboxmenu1.AutoCompleteMode = 'Append'

}

)

#=========================================================================find-menu1===========================================================================================#



$findtextboxmenu1 = New-Object System.Windows.Forms.ComboBox
$findtextboxmenu1.Location = New-Object System.Drawing.Point(5,110)
$findtextboxmenu1.Size = New-Object System.Drawing.Size(180,20)

$main_form.Controls.Add($findtextboxmenu1)

$findtextboxmenu1.Add_KeyDown({
    if (($_.Control) -and ($_.KeyCode -eq 'A')) {
       $findtextboxmenu1.SelectAll()
    }
  })

$button4menu1 = New-Object System.Windows.Forms.Button
$button4menu1.BackColor =”LightGray”
$button4menu1.ForeColor = “black”
$button4menu1.Location = New-Object System.Drawing.Size(210,110)

$button4menu1.Size = New-Object System.Drawing.Size(160,23)

$button4menu1.Text = "Vyhledat v kompletním infu"
$button4menu1.Cursor="Hand"
$main_form.Controls.Add($button4menu1)

$button4menu1.Add_Click(

{
    $pos = 0
 
    $pos = $infotextBoxmenu1.Text.IndexOf($findtextboxmenu1.text, [System.StringComparison]::OrdinalIgnoreCase)
if ($pos -ne -1) { 
    $infotextBoxmenu1.SelectionStart = $pos
    $infotextBoxmenu1.SelectionLength = $($($findtextboxmenu1.text).Length)
    #$find=$infotextBoxmenu1.Select() 
    $infotextBoxmenu1.Focus() 
    $infotextBoxmenu1.ScrollToCaret()
    #[System.Windows.Forms.MessageBox]::Show($pos)  

    }
 else{
    [System.Windows.Forms.MessageBox]::Show("Nenalezeno")
     }    

}
)

#=========================================================================time decode-menu1===========================================================================================#

$timedecodeboxmenu1 = New-Object System.Windows.Forms.TextBox
$timedecodeboxmenu1.Location = New-Object System.Drawing.Point(5,135)
$timedecodeboxmenu1.Size = New-Object System.Drawing.Size(180,20)

$main_form.Controls.Add($timedecodeboxmenu1)

$timedecodeboxmenu1.Add_KeyDown({
    if (($_.Control) -and ($_.KeyCode -eq 'A')) {
       $timedecodeboxmenu1.SelectAll()
    }
  })


$button5menu1 = New-Object System.Windows.Forms.Button
$button5menu1.BackColor =”LightGray”
$button5menu1.ForeColor = “black”
$button5menu1.Location = New-Object System.Drawing.Size(210,135)

$button5menu1.Size = New-Object System.Drawing.Size(160,23)

$button5menu1.Text = "Dešifrovat čas z infa"
$button5menu1.Cursor="Hand"
$main_form.Controls.Add($button5menu1)

$button5menu1.Add_Click(

{
    $vysledek= w32tm.exe /ntte $timedecodeboxmenu1.text
    $timedecodeboxmenu1.text=$vysledek.split("-")[1]
}
)

#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             Vypsání už. v oddělení/menu2                                                                     #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#

#-------------------------------------Department-menu-----------------------------------#
$Labelmenu2 = New-Object System.Windows.Forms.Label

$Labelmenu2.Text = "Oddělení"

$Labelmenu2.Location = New-Object System.Drawing.Point(0,10)

$Labelmenu2.AutoSize = $true

$main_form.Controls.Add($Labelmenu2)

$ComboBoxmenu2 = New-Object System.Windows.Forms.ComboBox

$ComboBoxmenu2.Width = 300

$Departments = get-aduser -filter * -Properties Department | Select-Object -expand Department -Unique

Foreach ($Department in $Departments)

{

$ComboBoxmenu2.Items.Add($Department);

}

$ComboBoxmenu2.Location  = New-Object System.Drawing.Point(60,10)
$ComboBoxmenu2.AutoCompleteSource = 'ListItems'
$ComboBoxmenu2.AutoCompleteMode = 'Append'

$main_form.Controls.Add($ComboBoxmenu2)


#=========================================================================infobox-menu2===========================================================================================#

$infotextBoxmenu2 = New-Object System.Windows.Forms.TextBox
$infotextBoxmenu2.Multiline=$true 
$infotextBoxmenu2.ReadOnly=$true
$infotextBoxmenu2.ScrollBars="vertical"
$infotextBoxmenu2.Location = New-Object System.Drawing.Point(5,120)
$infotextBoxmenu2.Size = New-Object System.Drawing.Size(600,250)
$main_form.Controls.Add($infotextBoxmenu2)
$infotextBoxmenu2.Add_KeyDown({
    if (($_.Control) -and ($_.KeyCode -eq 'A')) {
       $infotextBoxmenu2.SelectAll()
    }
  })


$buttonmenu2 = New-Object System.Windows.Forms.Button
$buttonmenu2.BackColor =”LightGray”
$buttonmenu2.ForeColor = “black”
$buttonmenu2.Location = New-Object System.Drawing.Size(210,60)

$buttonmenu2.Size = New-Object System.Drawing.Size(160,23)

$buttonmenu2.Text = "Zobrazit už. v oddělení"
$buttonmenu2.Cursor="Hand"
$main_form.Controls.Add($buttonmenu2)

$buttonmenu2.Add_Click(

{
    
    $infotextBoxmenu2.Text= Get-ADUser -filter * -Property department | Where-Object { $_.department -Like $ComboBoxmenu2.selectedItem } | Select-Object -Property sAMAccountName | Out-String | ForEach-Object { $_.Trim("`r","`n") }
    $infotextBoxmenu2.Text=$infotextBoxmenu2.Text.Replace("sAMAccountName","").Trim("`r","`n")
    $infotextBoxmenu2.Text=$infotextBoxmenu2.Text.Replace("--------------","").Trim("`r","`n")

    $lines = $infotextBoxmenu2.Lines
    foreach ($line in $lines.Trim()){
        $findtextboxmenu2.Items.Add($line);
    }
    $findtextboxmenu2.AutoCompleteSource = 'ListItems'
    $findtextboxmenu2.AutoCompleteMode = 'Append'

}

)

#=========================================================================find-menu2===========================================================================================#



$findtextboxmenu2 = New-Object System.Windows.Forms.ComboBox 
$findtextboxmenu2.ScrollBars="vertical"
$findtextboxmenu2.Location = New-Object System.Drawing.Point(0,85)
$findtextboxmenu2.Size = New-Object System.Drawing.Size(180,20)
$main_form.Controls.Add($findtextboxmenu2)

$findtextboxmenu2.Add_KeyDown({
    if (($_.Control) -and ($_.KeyCode -eq 'A')) {
       $findtextboxmenu2.SelectAll()
    }
  })

$button2menu2 = New-Object System.Windows.Forms.Button
$button2menu2.BackColor =”LightGray”
$button2menu2.ForeColor = “black”
$button2menu2.Location = New-Object System.Drawing.Size(210,85)

$button2menu2.Size = New-Object System.Drawing.Size(160,23)

$button2menu2.Text = "Vyhledat"
$button2menu2.Cursor="Hand"
$main_form.Controls.Add($button2menu2)

$button2menu2.Add_Click(

{
    $pos = $infotextBoxmenu2.Text.IndexOf($findtextboxmenu2.text, [System.StringComparison]::OrdinalIgnoreCase)
    if ($pos -ne -1) { 
        $infotextBoxmenu2.SelectionStart = $pos
        $infotextBoxmenu2.SelectionLength = $($($findtextboxmenu2.text).Length)
        #$find=$infotextBoxmenu2.Select() 
        
        $infotextBoxmenu2.Focus()
        $infotextBoxmenu2.ScrollToCaret()
        
        }
     else{
        [System.Windows.Forms.MessageBox]::Show("Nenalezeno")
     }    
    
}

)


#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             uživatelský-reset-hesla/menu3                                                                    #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#

#-------------------------------------Staré-heslo-----------------------------------#

$Labelmenu3 = New-Object System.Windows.Forms.Label

$Labelmenu3.Text = "Staré heslo:"

$Labelmenu3.Location  = New-Object System.Drawing.Point(0,10)

$Labelmenu3.AutoSize = $true

$main_form.Controls.Add($Labelmenu3)

$stareheslomenu3 = New-Object System.Windows.Forms.Textbox

$stareheslomenu3.Location = New-Object System.Drawing.Point(70,10)
$stareheslomenu3.Size = New-Object System.Drawing.Size(180,20)
$main_form.Controls.Add($stareheslomenu3)


$checkBoxmenu3 = New-Object System.Windows.Forms.CheckBox
$checkBoxmenu3.Location  = New-Object System.Drawing.Point(260,12)
$checkBoxmenu3.AutoSize=$true
$checkBoxmenu3.Cursor="Hand"
#$checkBox2menu3.Checked = $false
$stareheslomenu3.PasswordChar = '*'
$main_form.Controls.Add($checkBoxmenu3)
$checkBoxmenu3.Add_CheckStateChanged({
    if($checkBoxmenu3.CheckState -eq "Checked"){
        $stareheslomenu3.PasswordChar = $null
        
    }
    else{
        $stareheslomenu3.PasswordChar = "*"
    }
    }) 


#-------------------------------------Nové heslo-----------------------------------#
$Label2menu3 = New-Object System.Windows.Forms.Label

$Label2menu3.Text = "Nové heslo:"

$Label2menu3.Location  = New-Object System.Drawing.Point(0,40)

$Label2menu3.AutoSize = $true

$main_form.Controls.Add($Label2menu3)

$noveheslomenu3 = New-Object System.Windows.Forms.Textbox
$noveheslomenu3.Location = New-Object System.Drawing.Point(70,40)
$noveheslomenu3.Size = New-Object System.Drawing.Size(180,20)
$main_form.Controls.Add($noveheslomenu3)

$checkBox2menu3 = New-Object System.Windows.Forms.CheckBox
$checkBox2menu3.Location  = New-Object System.Drawing.Point(260,42)
$checkBox2menu3.AutoSize=$true
$checkBox2menu3.Cursor="Hand"
#$checkBox2menu3.Checked = $false
$noveheslomenu3.PasswordChar = '*'
$main_form.Controls.Add($checkBox2menu3)
$checkBox2menu3.Add_CheckStateChanged({
    if($checkBox2menu3.CheckState -eq "Checked"){
        $noveheslomenu3.PasswordChar = $null
        
    }
    else{
        $noveheslomenu3.PasswordChar = "*"
    }
    }) 



#-------------------------------------Uživatel-----------------------------------#
$Label3menu3 = New-Object System.Windows.Forms.Label

$Label3menu3.Text = "Uživatel:"

$Label3menu3.Location  = New-Object System.Drawing.Point(0,70)

$Label3menu3.AutoSize = $true

$main_form.Controls.Add($Label3menu3)

$uzivatelmenu3 = New-Object System.Windows.Forms.Textbox
#$uzivatelmenu3.PasswordChar = '*'
$uzivatelmenu3.Location = New-Object System.Drawing.Point(70,70)
$uzivatelmenu3.Size = New-Object System.Drawing.Size(180,20)
$main_form.Controls.Add($uzivatelmenu3)

#-------------------------------------Potvrdit-----------------------------------#

$potvrditmenu3 = New-Object System.Windows.Forms.Button
$potvrditmenu3.BackColor =”LightGray”
$potvrditmenu3.ForeColor = “black”
$potvrditmenu3.Location = New-Object System.Drawing.Size(210,120)
$potvrditmenu3.Cursor="Hand"

$potvrditmenu3.Size = New-Object System.Drawing.Size(160,23)

$potvrditmenu3.Text = "Potvrdit"

$main_form.Controls.Add($potvrditmenu3)

$infotextBoxmenu3 = New-Object System.Windows.Forms.TextBox
$infotextBoxmenu3.Multiline=$true 
$infotextBoxmenu3.ReadOnly=$true
$infotextBoxmenu3.ScrollBars="vertical"
$infotextBoxmenu3.Location = New-Object System.Drawing.Point(5,170)
$infotextBoxmenu3.Size = New-Object System.Drawing.Size(600,200)
$main_form.Controls.Add($infotextBoxmenu3)

$potvrditmenu3.Add_Click(

{

    #Set-ADAccountPassword -Identity $uzivatelmenu3.text -OldPassword $stareheslomenu3_secure -NewPassword $noveheslomenu3.text

    if (($noveheslomenu3.text -eq "") -or ($uzivatelmenu3 -eq "")){
        (New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Jedno nebo více políček je prázdných, prosím doplň políčka",0,"Chyba",64)

    }
    else{

        $noveheslomenu3_secure= ConvertTo-SecureString -String $noveheslomenu3.Text -AsPlainText -Force
        $stareheslomenu3_secure= ConvertTo-SecureString -String $stareheslomenu3.Text -AsPlainText -Force

        #Set-ADAccountPassword -Identity $uzivatelmenu3.text -OldPassword $stareheslomenu3_secure -NewPassword $noveheslomenu3_secure 3>&1 2>&1 | 
        $outputmenu3 = try{Set-ADAccountPassword -Identity $uzivatelmenu3.text -OldPassword $stareheslomenu3_secure -NewPassword $noveheslomenu3_secure *>&1}catch{$_}

        #Set-ADAccountPassword -Identity $uzivatelmenu3.text -OldPassword $stareheslomenu3_secure -NewPassword $noveheslomenu3_secure

        $infotextBoxmenu3.Text=$outputmenu3

    }


}
)

#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             Admin-reset-hesla/menu4                                                                    #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#

#-------------------------------------user-menu-----------------------------------#
$Labelmenu4 = New-Object System.Windows.Forms.Label

$Labelmenu4.Text = "Uživatel:"

$Labelmenu4.Location  = New-Object System.Drawing.Point(0,10)

$Labelmenu4.AutoSize = $true

$main_form.Controls.Add($Labelmenu4)

$ComboBoxmenu4 = New-Object System.Windows.Forms.ComboBox

$ComboBoxmenu4.Width = 300

Foreach ($User in $Users)

{

$ComboBoxmenu4.Items.Add($User.SamAccountName);

}

$ComboBoxmenu4.Location  = New-Object System.Drawing.Point(60,10)
$ComboBoxmenu4.AutoCompleteSource = 'ListItems'
$ComboBoxmenu4.AutoCompleteMode = 'Append'

$main_form.Controls.Add($ComboBoxmenu4)


#-------------------------------------Nové heslo-----------------------------------#
$Label2menu4 = New-Object System.Windows.Forms.Label

$Label2menu4.Text = "Nové heslo:"

$Label2menu4.Location  = New-Object System.Drawing.Point(0,40)

$Label2menu4.AutoSize = $true

$main_form.Controls.Add($Label2menu4)

$noveheslomenu4 = New-Object System.Windows.Forms.Textbox
$noveheslomenu4.Location = New-Object System.Drawing.Point(70,40)
$noveheslomenu4.Size = New-Object System.Drawing.Size(180,20)
$main_form.Controls.Add($noveheslomenu4)

$checkBox2menu4 = New-Object System.Windows.Forms.CheckBox
$checkBox2menu4.Location  = New-Object System.Drawing.Point(260,42)
$checkBox2menu4.AutoSize=$true
$checkBox2menu4.Cursor="Hand"
#$checkBox2menu4.Checked = $false
$noveheslomenu4.PasswordChar = '*'
$main_form.Controls.Add($checkBox2menu4)
$checkBox2menu4.Add_CheckStateChanged({
    if($checkBox2menu4.CheckState -eq "Checked"){
        $noveheslomenu4.PasswordChar = $null
        
    }
    else{
        $noveheslomenu4.PasswordChar = "*"
    }
    }) 

#-------------------------------------Potvrdit-----------------------------------#

$potvrditmenu4 = New-Object System.Windows.Forms.Button
$potvrditmenu4.BackColor =”LightGray”
$potvrditmenu4.ForeColor = “black”
$potvrditmenu4.Location = New-Object System.Drawing.Size(210,120)
$potvrditmenu4.Cursor="Hand"

$potvrditmenu4.Size = New-Object System.Drawing.Size(160,23)

$potvrditmenu4.Text = "Potvrdit"

$main_form.Controls.Add($potvrditmenu4)

$infotextBoxmenu4 = New-Object System.Windows.Forms.TextBox
$infotextBoxmenu4.Multiline=$true 
$infotextBoxmenu4.ReadOnly=$true
$infotextBoxmenu4.ScrollBars="vertical"
$infotextBoxmenu4.Location = New-Object System.Drawing.Point(5,170)
$infotextBoxmenu4.Size = New-Object System.Drawing.Size(600,200)
$main_form.Controls.Add($infotextBoxmenu4)

$potvrditmenu4.Add_Click(

{

    #Set-ADAccountPassword -Identity $uzivatelmenu4.text -OldPassword $stareheslomenu4_secure -NewPassword $noveheslomenu4.text
    if($Buttonlogin.Text -ne "AD login"){
    if (($noveheslomenu4.text -eq "") -or ($stareheslomenu4.text -eq "") -or ($uzivatelmenu4 -eq "")){
        (New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Jedno nebo více políček je prázdných, prosím doplň políčka",0,"Chyba",64)

    }
    else{

        $noveheslomenu4_secure= ConvertTo-SecureString -String $noveheslomenu4.Text -AsPlainText -Force

        #Set-ADAccountPassword -Identity $uzivatelmenu4.text -OldPassword $stareheslomenu4_secure -NewPassword $noveheslomenu4_secure 3>&1 2>&1 | 
        $outputmenu4 = try{Set-ADAccountPassword -Credential $Cred -Identity $ComboBoxmenu4.text -NewPassword $noveheslomenu4_secure *>&1}catch{$_}

        #Set-ADAccountPassword -Identity $uzivatelmenu4.text -OldPassword $stareheslomenu4_secure -NewPassword $noveheslomenu4_secure

        $infotextBoxmenu4.Text=$outputmenu4

    }
}
    else{
        (New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Pro tuto funkci je vyžadován AD login",0,"Chyba",64)
    }
}
)

#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             checkbox menu                                                                                    #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
Get-Variable -Exclude *menu1*,*login* |  ForEach-Object{ ($_.Value).Visible = $false }

#============================================================================checkbox menu1====================================================================================#

$checkBoxfork1 = New-Object System.Windows.Forms.CheckBox
$checkboxfork1.Location  = New-Object System.Drawing.Point(430,25)
$checkBoxfork1.AutoSize=$true
$checkBoxfork1.Cursor="Hand"
$main_form.Controls.Add($checkBoxfork1)
$checkBoxfork1.Checked = $true
$checkBoxfork1.Enabled=$false
$checkBoxfork1.Add_CheckStateChanged({
    if($checkBoxfork1.CheckState -eq "Checked"){
        $checkBoxfork2.Checked=$false
        $checkBoxfork3.Checked=$false
        $checkBoxfork4.Checked=$false
        Get-Variable *menu1*,*login* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBoxfork1.Enabled=$false
    }
    else{
        Get-Variable *menu1*,*login* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBoxfork1.Enabled=$true
    }
    })

    $LabelcheckBoxfork1 = New-Object System.Windows.Forms.Label
    $LabelcheckBoxfork1.Text="default menu info"
    $LabelcheckBoxfork1.Location  = New-Object System.Drawing.Point(444,25)
    $LabelcheckBoxfork1.AutoSize = $true
    $main_form.Controls.Add($LabelcheckBoxfork1)

#============================================================================checkbox menu2====================================================================================#


$checkBoxfork2 = New-Object System.Windows.Forms.CheckBox
$checkboxfork2.Location  = New-Object System.Drawing.Point(430,40)
$checkBoxfork2.AutoSize=$true
$checkBoxfork2.Cursor="Hand"
$main_form.Controls.Add($checkBoxfork2)
$checkBoxfork2.Add_CheckStateChanged({
    if($checkBoxfork2.CheckState -eq "Checked"){
        $checkBoxfork1.Checked=$false
        $checkBoxfork3.Checked=$false
        $checkBoxfork4.Checked=$false
        Get-Variable *menu2*,*login* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBoxfork2.Enabled=$false
    }
    else{
        Get-Variable *menu2*,*login* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBoxfork2.Enabled=$true
    }
    })

    $LabelcheckBoxfork2 = New-Object System.Windows.Forms.Label
    $LabelcheckBoxfork2.Text="Už. ve skupinách"
    $LabelcheckBoxfork2.Location  = New-Object System.Drawing.Point(444,40)
    $LabelcheckBoxfork2.AutoSize = $true
    $main_form.Controls.Add($LabelcheckBoxfork2)

#============================================================================checkbox menu3====================================================================================#

$checkBoxfork3 = New-Object System.Windows.Forms.CheckBox
$checkBoxfork3.Location  = New-Object System.Drawing.Point(430,55)
$checkBoxfork3.AutoSize=$true
$checkBoxfork3.Cursor="Hand"
$main_form.Controls.Add($checkBoxfork3)
$checkBoxfork3.Add_CheckStateChanged({
    if($checkBoxfork3.CheckState -eq "Checked"){
        $checkBoxfork1.Checked=$false
        $checkBoxfork2.Checked=$false
        $checkBoxfork4.Checked=$false
        Get-Variable *menu3*,*login* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBoxfork3.Enabled=$false
    }
    else{
        Get-Variable *menu3*,*login* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBoxfork3.Enabled=$true
    }
    }) 
    $LabelcheckBoxfork3 = New-Object System.Windows.Forms.Label
    $LabelcheckBoxfork3.Text="Uživatelský reset hesla"
    $LabelcheckBoxfork3.Location  = New-Object System.Drawing.Point(444,55)
    $LabelcheckBoxfork3.AutoSize = $true
    $main_form.Controls.Add($LabelcheckBoxfork3)

#============================================================================checkbox menu4====================================================================================#

$checkBoxfork4 = New-Object System.Windows.Forms.CheckBox
$checkBoxfork4.Location  = New-Object System.Drawing.Point(430,70)
$checkBoxfork4.AutoSize=$true
$checkBoxfork4.Cursor="Hand"
$main_form.Controls.Add($checkBoxfork4)
$checkBoxfork4.Add_CheckStateChanged({
    if($checkBoxfork4.CheckState -eq "Checked"){
        $checkBoxfork1.Checked=$false
        $checkBoxfork2.Checked=$false
        $checkBoxfork3.Checked=$false
        Get-Variable *menu4*,*login* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBoxfork4.Enabled=$false
    }
    else{
        Get-Variable *menu4*,*login* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBoxfork4.Enabled=$true
    }
    }) 
    $LabelcheckBoxfork4 = New-Object System.Windows.Forms.Label
    $LabelcheckBoxfork4.Text="Admin reset hesla"
    $LabelcheckBoxfork4.Location  = New-Object System.Drawing.Point(444,70)
    $LabelcheckBoxfork4.AutoSize = $true
    $main_form.Controls.Add($LabelcheckBoxfork4)


$main_form.ShowDialog()
