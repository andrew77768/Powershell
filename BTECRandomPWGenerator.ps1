$3RandomWords = (Invoke-WebRequest "https://random-word-api.herokuapp.com/word?number=1&length=6").Content

$Out1 = $3RandomWords.Replace('"','')
$Out2 = $Out1.Replace('[','')
$Out3 = $Out2.Replace(']','')
$Out4 = $Out3.Replace(',','.')
$FinalOutRandomWord = (Get-Culture).TextInfo.ToTitleCase($Out4)

$SpecialChars = Get-Random ("!","@","#","$","%","&","*","?",".")


$Colour = Get-Random ("black","blue","gray","green","navy","orange","purple","red","silver","white","yellow")
$Number = Get-Random -Minimum -0 -Maximum 100

Write-Output "$FinalOutRandomWord$SpecialChars$Colour$Number"
