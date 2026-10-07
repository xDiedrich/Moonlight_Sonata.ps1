# Moonlight_Sonata.ps1
A PowerShell script that uses lesser used PowerShell features to play moonlight sonatas first movement (shortened of course)

The script functions by storing the musical score as a list of notes that are notated by their Hz number then takes that Hz and converts it into a
sine wave by putting it through this equation Sin(2π × frequency ÷ 16000 × i) which is written as $w = 2 * [Math]::PI * $n[0] / $rate then that number
is multiplied through loudness variable (honestly if you were dedicated enough you could also get the actual velocity of the notes though other functions 
but it would be very tedious) Then the script will wrap it into WAV header that is then put in a MemoryStream then finally it gets put into the lesser 
used PowerShell function of SoundPlayer to play you the song :) 



