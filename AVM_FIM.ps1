#Add the presentation framework for a windows message box
Add-Type -AssemblyName PresentationFramework


#Function to populate_dictionary

Function populate_dictionary()
{
#retrieve the value from baseline.txt
$dict1 = @{}
$cur_baseline = Get-Content "E:\Cyber security Projects\File Integrity Monitor\baseline.txt" 

foreach ($l in $cur_baseline)
{
$dict1.add($l.Split("|")[0],$l.Split("|")[1])
}
return $dict1
}




#Function to create a new base line

Function create_new_baseline($file_arr)
{
foreach ($f in $file_arr)
{
$hash = calculate_hash_value $f.FullName

#display the hash object. it contains 3 values Algorithm, Path and Hash.
#Retrieve the Path and Hash vales and store them in the baseline.txt file. Here Path is the key and Hash is the value

$k = $hash.Path
$v = $hash.Hash
"$k|$v"| Out-File -FilePath "E:\Cyber security Projects\File Integrity Monitor\baseline.txt" -Append

}

}



#Function to calculate hash value

Function calculate_hash_value($file)
{
$hash_val = Get-FileHash -Path $file -Algorithm SHA512
return $hash_val
}




#Function to check whether the base line already exists

Function delete_existing_baseline()
{
$exists = Test-Path -Path "E:\Cyber security Projects\File Integrity Monitor\baseline.txt"
if ($exists -eq $true)
{
Remove-Item -Path "E:\Cyber security Projects\File Integrity Monitor\baseline.txt" -Force
}
else
{
echo "baseline does not exist. Creating a new Baseline"
}

}




Write-Host "Welcome to File Integrity Monitor" -ForegroundColor Green
Write-Host ""
 
#ask the user to provide the path to the file or folder that is to be checked

echo "Please enter the path to the file or folder that is to be checked."
Write-Host ""
$file_path = Read-Host "Please specify the file path." 
Write-Host ""
#Once the path has been received check whether it points to a file (leaf) or a directory (container)
Write-Host ""


$value = Test-Path -Path $file_path -PathType Leaf
Write-Host ""
# here value is a variable that contains a boolean value. This would be true of the path points to a file and false otherwise
Write-Host ""

if ($value -eq $False)
{
# go through the directory to get the child items
$global:files = Get-ChildItem -Path $file_path
Write-Host ""
echo "files found"
Write-Host ""
}




#once files have been identified ask the user whether he or she wants to create a new baseline or proceed with an existing baseline.
Write-Host "Please enter A to create a new Baseline"
Write-Host ""
Write-Host "Please enter B to proceed with  existing baseline "
Write-Host ""
$usr_input = Read-Host "Please enter your choice"
Write-Host ""

if ($usr_input -eq "A".ToUpper())
{
delete_existing_baseline
create_new_baseline $files

#retrive contents of the new base line
$bl = Get-Content "E:\Cyber security Projects\File Integrity Monitor\baseline.txt"

#displaying the new baseline
echo $bl
}
elseif ($usr_input -eq "B".ToUpper())
{

$new_dict = populate_dictionary

#check if a new file has been added 

$child = Get-ChildItem -Path $file_path

foreach ($c in $child)
{
$hash = calculate_hash_value $c.FullName

if ($new_dict[$hash.Path] -eq $null)
{
echo "new file has been found"
delete_existing_baseline
create_new_baseline $child
}

else
{
$dict2 = populate_dictionary


$x  = calculate_hash_value $c.FullName


#if the hashes are different the value has been changed

#compare the existing hash in baseline.txt to  a newly generated hash value

if ($x.Hash -eq $dict2[$x.Path])
{
echo $x.Path " hash value has not changed"
Write-Host ""
}
else
{

#displays a pop up message if there is achange in the hash value

[System.Windows.MessageBox]::Show($x.Path,  ' hash value changed. File has been changed')


#echo  $x.Path   "hash value changed. File has been changed"
Write-Host ""

}
}



}
}






