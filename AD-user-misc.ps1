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

$Cred = Get-Credential
$locked = Get-ADUser -Credential $Cred -identity $ComboBoxmenu1.selectedItem -Properties * | Select-Object -expand LockedOut

if($? -eq "True"){

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
(New-Object -ComObject Wscript.Shell -ErrorAction Stop).Popup("Chybně zadané heslo/ uživatelské jméno",0,"Chyba",64)
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
$buttonmenu2.Location = New-Object System.Drawing.Size(210,85)

$buttonmenu2.Size = New-Object System.Drawing.Size(160,23)

$buttonmenu2.Text = "Zobrazit už. v oddělení"
$buttonmenu2.Cursor="Hand"
$main_form.Controls.Add($buttonmenu2)

$buttonmenu2.Add_Click(

{
    
    $infotextBoxmenu2.Text= Get-ADUser -filter * -Property department | Where-Object { $_.department -Like $ComboBoxmenu2.selectedItem } | Select-Object -Property sAMAccountName | Out-String | ForEach-Object { $_.Trim("`r","`n") }
    $infotextBoxmenu2.Text=$infotextBoxmenu2.Text.Replace("sAMAccountName","Jméno")

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
$findtextboxmenu2.Location = New-Object System.Drawing.Point(0,60)
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
$button2menu2.Location = New-Object System.Drawing.Size(210,60)

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
#                                                                             Vypsání už. ve skupině/menu3                                                                     #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#

#-------------------------------------user-menu-----------------------------------#

$Labelmenu3 = New-Object System.Windows.Forms.Label

$Labelmenu3.Text = "AD users"

$Labelmenu3.Location  = New-Object System.Drawing.Point(0,10)

$Labelmenu3.AutoSize = $true

$main_form.Controls.Add($Labelmenu3)

$ComboBoxmenu3 = New-Object System.Windows.Forms.ComboBox

$ComboBoxmenu3.Width = 300

Foreach ($User in $Users)

{

$ComboBoxmenu3.Items.Add($User.SamAccountName);

}

$ComboBoxmenu3.Location  = New-Object System.Drawing.Point(60,10)
$ComboBoxmenu3.AutoCompleteSource = 'ListItems'
$ComboBoxmenu3.AutoCompleteMode = 'Append'

$main_form.Controls.Add($ComboBoxmenu3)

#=========================================================================infobox-menu3===========================================================================================#

$infotextBoxmenu3 = New-Object System.Windows.Forms.TextBox
$infotextBoxmenu3.Multiline=$true 
$infotextBoxmenu3.ReadOnly=$true
$infotextBoxmenu3.ScrollBars="vertical"
$infotextBoxmenu3.Location = New-Object System.Drawing.Point(5,120)
$infotextBoxmenu3.Size = New-Object System.Drawing.Size(600,250)
$main_form.Controls.Add($infotextBoxmenu3)


$buttonmenu3 = New-Object System.Windows.Forms.Button
$buttonmenu3.BackColor =”LightGray”
$buttonmenu3.ForeColor = “black”
$buttonmenu3.Location = New-Object System.Drawing.Size(210,85)

$buttonmenu3.Size = New-Object System.Drawing.Size(160,23)

$buttonmenu3.Text = "Zobrazit výsledek"
$buttonmenu3.Cursor="Hand"
$main_form.Controls.Add($buttonmenu3)

$buttonmenu3.Add_Click(

{
    
    

}

)

#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
#                                                                             checkbox menu                                                                                    #
#==============================================================================================================================================================================#
#==============================================================================================================================================================================#
Get-Variable -Exclude *menu1* |  ForEach-Object{ ($_.Value).Visible = $false }

#============================================================================checkbox menu1====================================================================================#

$checkBox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.Location  = New-Object System.Drawing.Point(430,10)
$checkBox1.AutoSize=$true
$checkBox1.Cursor="Hand"
$main_form.Controls.Add($checkBox1)
$checkBox1.Checked = $true
$checkBox1.Enabled=$false
$checkBox1.Add_CheckStateChanged({
    if($checkBox1.CheckState -eq "Checked"){
        $checkBox2.Checked=$false
        $checkBox3.Checked=$false
        Get-Variable *menu1* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBox1.Enabled=$false
    }
    else{
        Get-Variable *menu1* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBox1.Enabled=$true
    }
    })

    $Label6 = New-Object System.Windows.Forms.Label
    $Label6.Text="default menu info"
    $Label6.Location  = New-Object System.Drawing.Point(444,10)
    $Label6.AutoSize = $true
    $main_form.Controls.Add($Label6)

#============================================================================checkbox menu2====================================================================================#


$checkBox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.Location  = New-Object System.Drawing.Point(430,25)
$checkBox2.AutoSize=$true
$checkBox2.Cursor="Hand"
$main_form.Controls.Add($checkBox2)
$checkBox2.Add_CheckStateChanged({
    if($checkBox2.CheckState -eq "Checked"){
        $checkBox1.Checked=$false
        $checkBox3.Checked=$false
        Get-Variable *menu2* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBox2.Enabled=$false
    }
    else{
        Get-Variable *menu2* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBox2.Enabled=$true
    }
    }) 
    $Label7 = New-Object System.Windows.Forms.Label
    $Label7.Text="Vypsání už. v oddělení"
    $Label7.Location  = New-Object System.Drawing.Point(444,25)
    $Label7.AutoSize = $true
    $main_form.Controls.Add($Label7)

#============================================================================checkbox menu3====================================================================================#

$checkBox3 = New-Object System.Windows.Forms.CheckBox
$checkbox3.Location  = New-Object System.Drawing.Point(430,40)
$checkBox3.AutoSize=$true
$checkBox3.Cursor="Hand"
$main_form.Controls.Add($checkBox3)
$checkBox3.Add_CheckStateChanged({
    if($checkBox3.CheckState -eq "Checked"){
        $checkBox1.Checked=$false
        $checkBox2.Checked=$false
        Get-Variable *menu3* |  ForEach-Object{ ($_.Value).Visible = $true }
        $checkBox3.Enabled=$false
    }
    else{
        Get-Variable *menu3* |  ForEach-Object{ ($_.Value).Visible = $false }
        $checkBox3.Enabled=$true
    }
    }) 
    $Label8 = New-Object System.Windows.Forms.Label
    $Label8.Text="NEDOKONČENO"
    $Label8.Location  = New-Object System.Drawing.Point(444,40)
    $Label8.AutoSize = $true
    $main_form.Controls.Add($Label8)


$main_form.ShowDialog()