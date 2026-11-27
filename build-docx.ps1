$ErrorActionPreference = 'Stop'
$OutputPath = Join-Path (Get-Location) 'Лабораторна_робота_7_SmartFlea.docx'
$SourcePath = Join-Path (Get-Location) 'Документація_тестування_SmartFlea.md'
$TempRoot = Join-Path $env:TEMP ('smartflea_docx_' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $TempRoot
$null = New-Item -ItemType Directory -Path (Join-Path $TempRoot 'word')
$null = New-Item -ItemType Directory -Path (Join-Path $TempRoot '_rels')

function Escape-Xml([string]$Text) { return [System.Security.SecurityElement]::Escape($Text) }
function Add-Paragraph([string]$Text, [string]$Style = 'Normal') {
  $safe = Escape-Xml $Text
  return "<w:p><w:pPr><w:pStyle w:val=`"$Style`"/></w:pPr><w:r><w:t xml:space=`"preserve`">$safe</w:t></w:r></w:p>"
}
function Add-Cell([string]$Text, [bool]$Header) {
  $safe = Escape-Xml $Text
  $shade = if ($Header) { '<w:shd w:fill="183B56"/><w:color w:val="FFFFFF"/><w:b/>' } else { '' }
  return "<w:tc><w:tcPr><w:tcW w:w=`"0`" w:type=`"auto`"/><w:tcMar><w:top w:w=`"90`" w:type=`"dxa`"/><w:start w:w=`"90`" w:type=`"dxa`"/><w:bottom w:w=`"90`" w:type=`"dxa`"/><w:end w:w=`"90`" w:type=`"dxa`"/></w:tcMar></w:tcPr><w:p><w:pPr><w:spacing w:after=`"0`"/></w:pPr><w:r><w:rPr>$shade</w:rPr><w:t xml:space=`"preserve`">$safe</w:t></w:r></w:p></w:tc>"
}
function Add-Table($Rows) {
  if ($Rows.Count -eq 0) { return '' }
  $colCount = $Rows[0].Count
  $grid = '<w:tblGrid>' + ('<w:gridCol w:w="1800"/>' * $colCount) + '</w:tblGrid>'
  $props = '<w:tblPr><w:tblW w:w="0" w:type="auto"/><w:tblBorders><w:top w:val="single" w:sz="5" w:color="B6C6D2"/><w:left w:val="single" w:sz="5" w:color="B6C6D2"/><w:bottom w:val="single" w:sz="5" w:color="B6C6D2"/><w:right w:val="single" w:sz="5" w:color="B6C6D2"/><w:insideH w:val="single" w:sz="4" w:color="CFD9E0"/><w:insideV w:val="single" w:sz="4" w:color="CFD9E0"/></w:tblBorders></w:tblPr>'
  $body = ''
  for ($ri=0; $ri -lt $Rows.Count; $ri++) {
    $cells = ''
    for ($ci=0; $ci -lt $colCount; $ci++) { $cells += Add-Cell ([string]$Rows[$ri][$ci]) ($ri -eq 0) }
    $body += "<w:tr>$cells</w:tr>"
  }
  return "<w:tbl>$props$grid$body</w:tbl>"
}

$lines = [System.IO.File]::ReadAllLines($SourcePath, [System.Text.Encoding]::UTF8)
$blocks = [System.Collections.Generic.List[string]]::new()
$tableRows = [System.Collections.Generic.List[object]]::new()
$inTable = $false
$firstTitle = $true
$blocks.Add((Add-Paragraph 'ЛАБОРАТОРНА РОБОТА №7' 'Title'))
$blocks.Add((Add-Paragraph 'Розроблення тестової документації' 'Subtitle'))
$blocks.Add((Add-Paragraph 'Checklist, Test Case та Test Suite' 'Subtitle'))
$blocks.Add((Add-Paragraph 'Вебсайт SmartFlea' 'Subtitle'))
$blocks.Add('<w:p><w:pPr><w:spacing w:before="500"/></w:pPr></w:p>')
$blocks.Add((Add-Paragraph 'Виконав(ла): ______________________________' 'CoverInfo'))
$blocks.Add((Add-Paragraph 'Група: ____________________' 'CoverInfo'))
$blocks.Add((Add-Paragraph 'Перевірив(ла): ___________________________' 'CoverInfo'))
$blocks.Add('<w:p><w:pPr><w:spacing w:before="900"/></w:pPr></w:p>')
$blocks.Add((Add-Paragraph '2026' 'CoverInfo'))
$blocks.Add('<w:p><w:pPr><w:pageBreakBefore/></w:pPr></w:p>')

foreach ($line in $lines) {
  if ($line -match '^\|') {
    $cells = @(($line.Trim([char]'|').Split([char]'|')) | ForEach-Object { $_.Trim() })
    if (($cells -join '') -match '^[-:]+$') { continue }
    $inTable = $true
    $tableRows.Add($cells)
    continue
  }
  if ($inTable) { $blocks.Add((Add-Table $tableRows.ToArray())); $tableRows.Clear(); $inTable = $false }
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  if ($line -match '^# (.+)$') {
    if ($firstTitle) { $firstTitle = $false; continue }
    $blocks.Add((Add-Paragraph $Matches[1] 'Heading1')); continue
  }
  if ($line -match '^## (.+)$') { $blocks.Add((Add-Paragraph $Matches[1] 'Heading1')); continue }
  if ($line -match '^### (.+)$') { $blocks.Add((Add-Paragraph $Matches[1] 'Heading2')); continue }
  if ($line -match '^- (.+)$') { $blocks.Add((Add-Paragraph ('• ' + $Matches[1]))); continue }
  $blocks.Add((Add-Paragraph $line))
}
if ($inTable) { $blocks.Add((Add-Table $tableRows.ToArray())) }

$body = $blocks -join "`n"
$sect = '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1134" w:right="1020" w:bottom="1134" w:left="1020" w:header="500" w:footer="500"/><w:cols w:space="708"/></w:sectPr>'
$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>$body$sect</w:body></w:document>
"@
$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos" w:eastAsia="Aptos"/><w:sz w:val="20"/><w:color w:val="243746"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="276" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos"/><w:sz w:val="20"/><w:color w:val="243746"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:pPr><w:jc w:val="center"/><w:spacing w:before="2800" w:after="260"/></w:pPr><w:rPr><w:rFonts w:ascii="Aptos Display" w:hAnsi="Aptos Display"/><w:b/><w:sz w:val="38"/><w:color w:val="183B56"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:pPr><w:jc w:val="center"/><w:spacing w:after="140"/></w:pPr><w:rPr><w:sz w:val="25"/><w:color w:val="426B83"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="CoverInfo"><w:name w:val="Cover Info"/><w:pPr><w:jc w:val="center"/><w:spacing w:after="170"/></w:pPr><w:rPr><w:sz w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="300" w:after="140"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:rFonts w:ascii="Aptos Display" w:hAnsi="Aptos Display"/><w:b/><w:sz w:val="30"/><w:color w:val="183B56"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="100"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:sz w:val="24"/><w:color w:val="287271"/></w:rPr></w:style>
</w:styles>
'@
$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>
'@
$rels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
'@
$docRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>
'@
[System.IO.File]::WriteAllText((Join-Path $TempRoot 'word\document.xml'), $documentXml, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $TempRoot 'word\styles.xml'), $stylesXml, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $TempRoot 'word\_rels\document.xml.rels'), $docRels, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $TempRoot '[Content_Types].xml'), $contentTypes, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $TempRoot '_rels\.rels'), $rels, [System.Text.UTF8Encoding]::new($false))
if (Test-Path $OutputPath) { Remove-Item -LiteralPath $OutputPath -Force }
Compress-Archive -Path (Join-Path $TempRoot '*') -DestinationPath $OutputPath -Force
$zip = [System.IO.Compression.ZipFile]::Open($OutputPath, [System.IO.Compression.ZipArchiveMode]::Update)
$contentEntry = $zip.GetEntry('[Content_Types].xml')
if (-not $contentEntry) {
  $contentEntry = $zip.CreateEntry('[Content_Types].xml')
  $writer = [System.IO.StreamWriter]::new($contentEntry.Open(), [System.Text.UTF8Encoding]::new($false))
  $writer.Write($contentTypes); $writer.Dispose()
}
$zip.Dispose()
Remove-Item -LiteralPath $TempRoot -Recurse -Force
Write-Output $OutputPath
