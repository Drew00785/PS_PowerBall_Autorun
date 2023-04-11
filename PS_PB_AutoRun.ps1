﻿Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$winnings = 0
$script:count = 20

Function Main {
    Show-MainForm
}

Function AddCounter {
$script:count +=20
}

function Format-MatchingNumbers {
    param (
        [array]$winningNumbers,
        [array]$drawNumbers
    )

    $formattedNumbers = @()
    $regularWinningNumbers = $winningNumbers[0..4]
    $powerBallWinningNumber = $winningNumbers[5]

    for ($i = 0; $i -lt 5; $i++) {
        $drawNumber = $drawNumbers[$i]
        if ($regularWinningNumbers -contains $drawNumber) {
            $RTB.SelectionColor = 'Green'
            $RTB.AppendText($drawNumber + ' ')
            $RTB.SelectionColor = 'Black'
        } else {
            $RTB.AppendText($drawNumber + ' ')
        }
    }

    $drawPowerBallNumber = $drawNumbers[5]
    if ($drawPowerBallNumber -eq $powerBallWinningNumber) {
        $RTB.SelectionColor = 'Green'
        $RTB.AppendText($drawPowerBallNumber)
        $RTB.SelectionColor = 'Black'
    } else {
        $RTB.AppendText($drawPowerBallNumber)
    }
}

function Generate-PowerBallNumbers {
    @(Get-Random -Count 5 -InputObject(1..69) | ForEach-Object { $_.ToString("00") } | Sort-Object) + (Get-Random -Minimum 1 -Maximum 26 | ForEach-Object { $_.ToString("00") })
}

$numberOfDraws = 10
$drawsArray = @()

for ($i = 0; $i -lt $numberOfDraws; $i++) {
    $drawsArray += ,@(Generate-PowerBallNumbers)
}

$Draw1_Array = $drawsArray[0]
$Draw2_Array = $drawsArray[1]
$Draw3_Array = $drawsArray[2]
$Draw4_Array = $drawsArray[3]
$Draw5_Array = $drawsArray[4]
$Draw6_Array = $drawsArray[5]
$Draw7_Array = $drawsArray[6]
$Draw8_Array = $drawsArray[7]
$Draw9_Array = $drawsArray[8]
$Draw10_Array = $drawsArray[9]

function Get-WinningAmount {
    param (
        [int]$whiteBallMatches,
        [bool]$powerBallMatch
    )

    switch ($whiteBallMatches) {
        0 {
            if ($powerBallMatch) {
                return "`$4 WINNER - Powerball Matched"
            } else {
                return "LOSER - 0 White Balls Matched"
            }
        }
        1 {
            if ($powerBallMatch) {
                return "`$4 WINNER - 1 White Ball + PB"
            } else {
                return "LOSER - 1 White Ball Matched"
            }
        }
        2 {
            if ($powerBallMatch) {
                return "`$7 WINNER - 2 White Balls + PB"
            } else {
                return "LOSER - 2 White Balls"
            }
        }
        3 {
            if ($powerBallMatch) {
                return "`$100 WINNER - 3 White Balls + PB"
            } else {
                return "`$7 WINNER - 3 White Balls"
            }
        }
        4 {
            if ($powerBallMatch) {
                return "`$50,000 WINNER - 4 White Balls + PB"
            } else {
                return "`$100 WINNER - 4 White Balls"
            }
        }
        5 {
            if ($powerBallMatch) {
                return "JACKPOT WINNER"
            } else {
                return "`$1,000,000 WINNER - 5 White Balls"
            }
        }
    }
}

Function Show-MainForm {

    $Form = New-Object System.Windows.Forms.Form
    $Form.Size = New-Object System.Drawing.Size(1900,1300)
    $Form.text = "Lottery Simulator"

    $RTB = New-Object System.Windows.Forms.RichTextBox
    $RTB.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",40,[System.Drawing.FontStyle]::Bold)
    $RTB.Location = New-Object System.Drawing.Size(10,100)
    $RTB.Size = New-Object System.Drawing.Size(1800,900)
    $RTB.MultiLine = $True
    $RTB.ScrollBars = "Vertical"    

    $PlayButton = New-Object System.Windows.Forms.Button
    $PlayButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15,[System.Drawing.FontStyle]::Bold)
    $PlayButton.Location = New-Object System.Drawing.Size(50,1050)
    $PlayButton.Size = New-Object System.Drawing.Size(150,80)
    $PlayButton.Text = "Play"

    $PlayUntilJackpotButton = New-Object System.Windows.Forms.Button
    $PlayUntilJackpotButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15,[System.Drawing.FontStyle]::Bold)
    $PlayUntilJackpotButton.Location = New-Object System.Drawing.Size(450,1050)
    $PlayUntilJackpotButton.Size = New-Object System.Drawing.Size(350,80)
    $PlayUntilJackpotButton.Text = "Play Until Jackpot or Million"

    $ElapsedTimeLabel = New-Object System.Windows.Forms.Label
    $ElapsedTimeLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15,[System.Drawing.FontStyle]::Bold)
    $ElapsedTimeLabel.Location = New-Object System.Drawing.Size(850,1050)
    $ElapsedTimeLabel.Size = New-Object System.Drawing.Size(350,80)
    $ElapsedTimeLabel.Text = "Elapsed Time: 00:00:00"

    $simulationTimer = New-Object System.Windows.Forms.Timer
    # 1 Second Interval
    #$simulationTimer.Interval = 1000
    # Half Second Interval
    #$simulationTimer.Interval = 500
    # Quarter Second Interval
    $simulationTimer.Interval = 250

    $stopWatch = New-Object System.Diagnostics.Stopwatch

    function PlayUntilJackpotOrMillion {
        $stopWatch.Start()
        $simulationTimer.Start()
    }

    $simulationTimer.Add_Tick({
        Update-WinningNumbers
        AddCounter
        $ElapsedTimeLabel.Text = "Elapsed Time: " + $stopWatch.Elapsed.ToString("hh\:mm\:ss")

        if ($result -eq "JACKPOT WINNER" -or $result -eq "`$1,000,000 WINNER - 5 White Balls") {
            $simulationTimer.Stop()
            $stopWatch.Stop()
        }
    })

    $PlayUntilJackpotButton.Add_Click({ PlayUntilJackpotOrMillion })

    $CloseButton = New-Object System.Windows.Forms.Button
    $CloseButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15,[System.Drawing.FontStyle]::Bold)
    $CloseButton.Location = New-Object System.Drawing.Size(250,1050)
    $CloseButton.Size = New-Object System.Drawing.Size(150,80)
    $CloseButton.Text = "Close"
    $CloseButton.Add_Click({ $Form.Close() })

function Update-WinningNumbers {
    $Win_Array = Generate-PowerBallNumbers
    $RTB.Clear()
    $RTB.SelectionFont = New-Object System.Drawing.Font("Microsoft Sans Serif", 20, [System.Drawing.FontStyle]::Bold)
    $RTB.AppendText("Winning Numbers: " + ($Win_Array -join ' '))
    $RTB.AppendText("`r`n")
    $RTB.AppendText("`r`n")

    for ($i = 0; $i -lt $numberOfDraws; $i++) {
        $drawsArray[$i] = Generate-PowerBallNumbers
        $whiteBallMatches = @(Compare-Object $Win_Array[0..4] $drawsArray[$i][0..4] -IncludeEqual -ExcludeDifferent).Count
        $powerBallMatch = $Win_Array[5] -eq $drawsArray[$i][5]
        $RTB.SelectionColor = "Black"
        $RTB.AppendText("Draw " + ($i + 1) + ": ")
        Format-MatchingNumbers -winningNumbers $Win_Array -drawNumbers $drawsArray[$i]
        $result = Get-WinningAmount -whiteBallMatches $whiteBallMatches -powerBallMatch $powerBallMatch

        $RTB.AppendText(" - " + $result)
        if ($result -ne "LOSER - 0 White Balls Matched" -and $result -ne "LOSER - 1 White Ball Matched" -and $result -ne "LOSER - 2 White Balls") {
    switch ($result) {
        "`$4 WINNER - Powerball Matched" { $script:winnings += 4 }
        "`$4 WINNER - 1 White Ball + PB" { $script:winnings += 4 }
        "`$7 WINNER - 2 White Balls + PB" { $script:winnings += 7 }
        "`$7 WINNER - 3 White Balls" { $script:winnings += 7 }
        "`$100 WINNER - 3 White Balls + PB" { $script:winnings += 100 }
        "`$100 WINNER - 4 White Balls" { $script:winnings += 100 }
        "`$50,000 WINNER - 4 White Balls + PB" { $script:winnings += 50000 }
        "`$1,000,000 WINNER - 5 White Balls" { $script:winnings += 1000000 }
        "JACKPOT WINNER" { $script:winnings += 5000000 }
        }
    }
        $RTB.AppendText("`r`n")
    }
    $RTB.AppendText("Spent = $" + $count + "      Won = $" + $winnings)
}

    $PlayButton.Add_Click({ Update-WinningNumbers  ; AddCounter })
    $Form.Controls.AddRange(@($RTB, $Label, $PlayButton, $CloseButton, $PlayUntilJackpotButton, $ElapsedTimeLabel))
    Update-WinningNumbers
    AddCounter
    $Form.ShowDialog()
}

Show-MainForm