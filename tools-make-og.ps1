# 카카오톡 / SNS 공유용 OG 이미지 생성 (1200x630)
param(
  [string]$Src = "$PSScriptRoot\img\hero.jpg",
  [string]$Out = "$PSScriptRoot\img\og.jpg",
  [int]$SrcCropY = 170
)
Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$img = [System.Drawing.Image]::FromFile($Src)
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.SmoothingMode     = 'AntiAlias'
$g.TextRenderingHint = 'ClearTypeGridFit'

# 1) 원본을 1200x630 비율(1.905:1)로 크롭해 채우기
$cropH = [int]($img.Width / ($W / $H))
if ($SrcCropY + $cropH -gt $img.Height) { $SrcCropY = [math]::Max(0, $img.Height - $cropH) }
$srcRect  = New-Object System.Drawing.Rectangle(0, $SrcCropY, $img.Width, $cropH)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$img.Dispose()

# 2) 좌측이 진한 오버레이 (텍스트 가독성)
$p1 = New-Object System.Drawing.Point(0,0)
$p2 = New-Object System.Drawing.Point($W,0)
$c1 = [System.Drawing.Color]::FromArgb(240, 11, 15, 18)
$c2 = [System.Drawing.Color]::FromArgb(105, 11, 15, 18)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($p1, $p2, $c1, $c2)
$g.FillRectangle($grad, 0, 0, $W, $H)
# 하단 살짝 더 어둡게
$p3 = New-Object System.Drawing.Point(0,[int]($H*0.55))
$p4 = New-Object System.Drawing.Point(0,$H)
$grad2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush($p3, $p4,
          [System.Drawing.Color]::FromArgb(0,11,15,18), [System.Drawing.Color]::FromArgb(120,11,15,18))
$g.FillRectangle($grad2, 0, [int]($H*0.55), $W, [int]($H*0.45))

$L = 74   # 좌측 여백

# 3) 상단 브랜드 라인 — 하늘색 사각 마크 + 기관명
$markSize = 42
$brandBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 21, 149, 204))
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = 11; $mx = $L; $my = 66
$path.AddArc($mx, $my, $r*2, $r*2, 180, 90)
$path.AddArc($mx+$markSize-$r*2, $my, $r*2, $r*2, 270, 90)
$path.AddArc($mx+$markSize-$r*2, $my+$markSize-$r*2, $r*2, $r*2, 0, 90)
$path.AddArc($mx, $my+$markSize-$r*2, $r*2, $r*2, 90, 90)
$path.CloseFigure()
$g.FillPath($brandBrush, $path)

$fMark  = New-Object System.Drawing.Font('Malgun Gothic', 15, [System.Drawing.FontStyle]::Bold)
$white  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
$markRect = New-Object System.Drawing.RectangleF($mx, $my, $markSize, $markSize)
$g.DrawString('일', $fMark, $white, $markRect, $sf)

$fBrand = New-Object System.Drawing.Font('Malgun Gothic', 16, [System.Drawing.FontStyle]::Bold)
$g.DrawString('사회적협동조합 일하는학교', $fBrand, $white, ($mx + $markSize + 14), ($my + 9))

# 4) 헤드라인
$fH1 = New-Object System.Drawing.Font('Malgun Gothic', 43, [System.Drawing.FontStyle]::Bold)
$g.DrawString('혼자 힘으로 자립해야 하는', $fH1, $white, ($L - 6), 206)
$g.DrawString('청년에게,', $fH1, $white, ($L - 6), 274)

# '기댈 언덕' 하늘색 밑줄 강조
# MeasureString 기본값은 좌우 여백을 붙여 반환하므로 GenericTypographic 으로 정확히 잰다
$tf = [System.Drawing.StringFormat]::GenericTypographic.Clone()
$tf.FormatFlags = $tf.FormatFlags -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces
$hl = '기댈 언덕'; $rest = '이 되어주세요'
$x3 = $L - 6; $y3 = 342
$hlW = $g.MeasureString($hl, $fH1, $([System.Drawing.PointF]::new(0,0)), $tf).Width
$underline = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 104, 201, 243))
$g.FillRectangle($underline, $x3, 394, $hlW, 20)
$g.DrawString($hl,   $fH1, $white, $([System.Drawing.PointF]::new($x3, $y3)), $tf)
$g.DrawString($rest, $fH1, $white, $([System.Drawing.PointF]::new(($x3 + $hlW), $y3)), $tf)

# 5) 하단 서브카피
$fSub = New-Object System.Drawing.Font('Malgun Gothic', 17)
$subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 214, 228, 238))
$g.DrawString('13년간 512명의 위기·고립 청년과 동행했습니다', $fSub, $subBrush, ($L - 4), 448)
$g.DrawString('첫 취업 후 3개월 이상 지속 64.9%', $fSub, $subBrush, ($L - 4), 480)

# 6) 후원 배지
$donate = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 206, 69, 32))
$bp = New-Object System.Drawing.Drawing2D.GraphicsPath
$bx = $L - 2; $by = 528; $bw = 168; $bh = 50; $br = 25
$bp.AddArc($bx, $by, $br*2, $br*2, 90, 180)
$bp.AddArc($bx+$bw-$br*2, $by, $br*2, $br*2, 270, 180)
$bp.CloseFigure()
$g.FillPath($donate, $bp)
$fBtn = New-Object System.Drawing.Font('Malgun Gothic', 15, [System.Drawing.FontStyle]::Bold)
$btnRect = New-Object System.Drawing.RectangleF($bx, $by, $bw, $bh)
$g.DrawString('후원하기', $fBtn, $white, $btnRect, $sf)

$g.Dispose()

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int]86)
$bmp.Save($Out, $codec, $ep)
$bmp.Dispose()
Write-Output ("{0}  {1}x{2}  {3} KB" -f (Split-Path $Out -Leaf), $W, $H, [int]((Get-Item $Out).Length/1KB))
