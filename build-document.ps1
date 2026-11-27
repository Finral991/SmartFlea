$ErrorActionPreference = 'Stop'
$src = Join-Path (Get-Location) 'Документація_тестування_SmartFlea.md'
$out = Join-Path (Get-Location) 'Лабораторна_робота_7_SmartFlea.html'
$lines = [System.IO.File]::ReadAllLines($src, [System.Text.Encoding]::UTF8)
$builder = [System.Text.StringBuilder]::new()
$null = $builder.AppendLine('<!doctype html><html lang="uk"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Лабораторна робота №7 — SmartFlea</title><style>')
$null = $builder.AppendLine('@page{size:A4;margin:18mm 16mm}body{font:11pt/1.5 Arial,sans-serif;color:#243746;max-width:980px;margin:0 auto;padding:26px}h1,h2,h3{color:#183b56;page-break-after:avoid}h1{font-size:20pt;margin:28px 0 12px;border-bottom:2px solid #287271;padding-bottom:6px}h2{font-size:15pt;margin:24px 0 9px}h3{font-size:12pt;margin:17px 0 7px;color:#287271}p{margin:7px 0}table{width:100%;border-collapse:collapse;margin:10px 0 18px;font-size:9.5pt}tr{page-break-inside:avoid}th{background:#183b56;color:white;text-align:left}th,td{border:1px solid #b6c6d2;padding:6px 8px;vertical-align:top}.cover{height:255mm;display:flex;flex-direction:column;align-items:center;text-align:center;padding-top:56mm;page-break-after:always}.cover h1{font-size:26pt;border:0}.cover h2{font-weight:400;font-size:16pt;margin:0 0 8px}.cover .details{margin-top:52mm;line-height:2}.cover .year{margin-top:auto;padding-bottom:15mm}@media print{body{padding:0}}')
$null = $builder.AppendLine('</style></head><body>')
$null = $builder.AppendLine('<section class="cover"><h1>ЛАБОРАТОРНА РОБОТА №7</h1><h2>Розроблення тестової документації</h2><h2>Checklist, Test Case та Test Suite</h2><p><b>Вебсайт SmartFlea</b></p><div class="details">Виконав(ла): ______________________________<br>Група: ____________________<br>Перевірив(ла): ___________________________</div><p class="year">2026</p></section>')
$null = $builder.AppendLine('@page{size:A4;margin:18mm 16mm}*{box-sizing:border-box}body{font:11pt/1.5 "Aptos","Arial",sans-serif;color:#243746;max-width:980px;margin:0 auto;padding:26px}h1,h2,h3{color:#183b56;page-break-after:avoid}h1{font-size:20pt;margin:28px 0 12px;border-bottom:2px solid #287271;padding-bottom:6px}h2{font-size:15pt;margin:24px 0 9px}h3{font-size:12pt;margin:17px 0 7px;color:#287271}p{margin:7px 0}table{width:100%;border-collapse:collapse;margin:10px 0 18px;font-size:9.5pt;page-break-inside:auto}tr{page-break-inside:avoid;page-break-after:auto}th{background:#183b56;color:white;text-align:left}th,td{border:1px solid #b6c6d2;padding:6px 8px;vertical-align:top}tr:nth-child(even) td{background:#f4f7f9}.cover{height:255mm;display:flex;flex-direction:column;align-items:center;text-align:center;justify-content:flex-start;padding-top:56mm;page-break-after:always}.cover h1{font-size:26pt;border:0;margin:0 0 18px}.cover h2{font-weight:400;font-size:16pt;margin:0 0 8px}.cover .project{font-size:17pt;color:#287271;margin:10px 0 0}.cover .details{margin-top:52mm;line-height:2}.cover .year{margin-top:auto;padding-bottom:15mm}.check{color:#287271}ul{padding-left:24px}strong{color:#183b56}@media print{body{padding:0}a{color:inherit;text-decoration:none}}')
$null = $builder.AppendLine('</style></head><body>')
$null = $builder.AppendLine('<section class="cover"><h1>ЛАБОРАТОРНА РОБОТА №7</h1><h2>Розроблення тестової документації</h2><h2>Checklist, Test Case та Test Suite</h2><p class="project">Вебсайт SmartFlea</p><div class="details">Виконав(ла): ______________________________<br>Група: ____________________<br>Перевірив(ла): ___________________________</div><p class="year">2026</p></section>')
$inTable = $false
$firstTitle = $true
$paragraph = [System.Collections.Generic.List[string]]::new()
foreach($line in $lines){
  if($line -match '^\|'){
    if(-not $inTable){
      if($paragraph.Count){ $null=$builder.AppendLine('<p>' 
 (($paragraph -join ' ') -replace '\*\*(.*?)\*\*','<strong>$1</strong>') 
 '</p>'); $paragraph.Clear() }
      $null=$builder.AppendLine('<table>'); $inTable=$true; $rowIndex=0
    }
    $cells=@($line.Trim([char]'|').Split([char]'|') | ForEach-Object { $_.Trim() })
    if(($cells -join '') -match '^[-:]
$'){continue}
    $tag=if($rowIndex -eq 0){'th'}else{'td'}
    $null=$builder.Append('<tr>')
    foreach($cell in $cells){$null=$builder.Append('<' 
 $tag 
 '>' 
 [System.Net.WebUtility]::HtmlEncode($cell) 
 '</' 
 $tag 
 '>')}
    $null=$builder.AppendLine('</tr>');$rowIndex

;continue
  }
  if($inTable){$null=$builder.AppendLine('</table>');$inTable=$false}
  if([string]::IsNullOrWhiteSpace($line)){if($paragraph.Count){$null=$builder.AppendLine('<p>' 
 (($paragraph -join ' ') -replace '\*\*(.*?)\*\*','<strong>$1</strong>') 
 '</p>');$paragraph.Clear()};continue}
  if($line -match '^# (.
)$'){if($firstTitle){$firstTitle=$false;continue};$null=$builder.AppendLine('<h1>'
$Matches[1]
'</h1>');continue}
  if($line -match '^## (.
)$'){$null=$builder.AppendLine('<h2>'
$Matches[1]
'</h2>');continue}
  if($line -match '^### (.
)$'){$null=$builder.AppendLine('<h3>'
$Matches[1]
'</h3>');continue}
  if($line -match '^- (.
)$'){$null=$builder.AppendLine('<p>• '
$Matches[1]
'</p>');continue}
  $paragraph.Add($line)
}
if($inTable){$null=$builder.AppendLine('</table>')}
if($paragraph.Count){$null=$builder.AppendLine('<p>' 
 (($paragraph -join ' ') -replace '\*\*(.*?)\*\*','<strong>$1</strong>') 
 '</p>')}
$null=$builder.AppendLine('</body></html>')
[System.IO.File]::WriteAllText($out,$builder.ToString(),[System.Text.UTF8Encoding]::new($false))
Write-Output $out
