# Beethoven - Moonlight Sonata 1st Movement Performed by Powershell

$volume = 0.15   # KEEP THIS LOW IT GETS REALLY LOUD
$t      = 200    
 
#Note Variables
$Fs3=185; $Gs3=208; $A3=220; $Bs3=262; $Cs4=277; $D4=294; $Ds4=311
$E4=330; $Fs4=370; $Gs4=415; $A4=440; $Cs3=139
 
function Triplet($a, $b, $c, $times) {
    $out = @()
    for ($i = 0; $i -lt $times; $i++) { $out += ,@($a,$t); $out += ,@($b,$t); $out += ,@($c,$t) }
    return $out
}
 
# Intro 
$notes  = Triplet $Gs3 $Cs4 $E4 4
$notes += Triplet $Gs3 $Cs4 $E4 2
$notes += Triplet $A3  $Cs4 $E4 2
$notes += Triplet $A3  $D4  $Fs4 2
$notes += Triplet $Gs3 $Bs3 $Fs4 1
$notes += Triplet $Gs3 $Cs4 $E4 1
$notes += Triplet $Gs3 $Bs3 $Fs4 1
$notes += Triplet $Gs3 $Cs4 $E4 1
$notes += Triplet $Gs3 $Bs3 $Ds4 2
 
# The Expo 
$notes += @(
    @($Gs4,300), @($Gs4,100), @($Gs4,1200),
    @($Gs4,300), @($Gs4,100), @($Gs4,800),
    @($A4,800),  @($Gs4,800),
    @($Fs4,800), @($Fs4,400), @($E4,1600),
    @(0,300)
)
 
# Trips ending on C#
$notes += Triplet $Gs3 $Cs4 $E4 4
$notes += Triplet $Gs3 $Bs3 $Ds4 2
$notes += Triplet $Gs3 $Cs4 $E4 2
$notes += ,@($Cs4,800)
$notes += ,@($Cs3,1600)
 

$rate = 16000
$total = 0
foreach ($n in $notes) { $total += [int]($rate * $n[1] / 1000) }
$samples = New-Object 'int16[]' $total
$amp  = 32767 * $volume
$fade = [int]($rate * 0.008)   # 8 ms fade in/out to avoid clicks
$pos  = 0
 
foreach ($n in $notes) {
    $len = [int]($rate * $n[1] / 1000)
    if ($n[0] -gt 0) {
        $w = 2 * [Math]::PI * $n[0] / $rate
        for ($i = 0; $i -lt $len; $i++) {
            $env = 1.0
            if ($i -lt $fade) { $env = $i / $fade }
            elseif ($i -gt $len - $fade) { $env = ($len - $i) / $fade }
            $samples[$pos + $i] = [int16]($amp * $env * [Math]::Sin($w * $i))
        }
    }
    $pos += $len
}
 

$dataBytes = $total * 2
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms
$bw.Write([Text.Encoding]::ASCII.GetBytes("RIFF")); $bw.Write([int](36 + $dataBytes))
$bw.Write([Text.Encoding]::ASCII.GetBytes("WAVEfmt ")); $bw.Write([int]16)
$bw.Write([int16]1); $bw.Write([int16]1); $bw.Write([int]$rate)
$bw.Write([int]($rate * 2)); $bw.Write([int16]2); $bw.Write([int16]16)
$bw.Write([Text.Encoding]::ASCII.GetBytes("data")); $bw.Write([int]$dataBytes)
$bytes = New-Object 'byte[]' $dataBytes
[Buffer]::BlockCopy($samples, 0, $bytes, 0, $dataBytes)
$bw.Write($bytes); $bw.Flush()
$ms.Position = 0

try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
Clear-Host
Write-Host "  Beethoven - Moonlight Sonata, 1st Movement" -ForegroundColor Cyan
Write-Host ""
 
$V  = [char]0x2551  # double vertical line
$L  = [char]0x2591  # light shade (white key)
$B  = [char]0x2588  # full block (black key)
$C1 = [char]0x255A  # bottom-left corner
$H  = [char]0x2550  # double horizontal line
$T  = [char]0x2569  # bottom T-junction
$C2 = [char]0x255D  # bottom-right corner
 
$keys = "$V$L$B$L$B$L$V$L$B$L$B$L$B$L$V$L$B$L$B$L$V"
Write-Host "  $keys -Script by Diedrich Ellmann"
Write-Host "  $keys Played by PowerShell"
Write-Host ("  " + $V + ("$L$V" * 10))
Write-Host ("  " + $C1 + $H + ("$T$H" * 9) + $C2)
Write-Host ""
 
$player = New-Object System.Media.SoundPlayer $ms
$player.PlaySync()


