Add-Type -AssemblyName System.Speech 
$speak = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer

while($true) {
    if (Test-Connection 8.8.8.8 -Count 1 -quiet) {$speak.Speak("Host is up!")}
    else {$speak.Speak("host is down!")}
            }