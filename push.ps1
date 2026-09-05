# 랜딩 페이지 배포 스크립트
# index.html 을 수정한 뒤 이 스크립트를 실행하면 GitHub Pages 에 반영됩니다.
$ErrorActionPreference = "Stop"
$gh = "$env:ProgramFiles\GitHub CLI\gh.exe"
Set-Location $PSScriptRoot

$changed = git status --porcelain
if (-not $changed) {
    Write-Host "변경된 내용이 없습니다." -ForegroundColor Yellow
    exit 0
}

Write-Host "변경된 파일:" -ForegroundColor Cyan
git status --short

$msg = Read-Host "커밋 메시지 (그냥 Enter 치면 '랜딩 페이지 수정')"
if (-not $msg) { $msg = "랜딩 페이지 수정" }

git add -A
git commit -m $msg
git push

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " 업로드 완료. 1~2분 뒤 사이트에 반영됩니다." -ForegroundColor Green
Write-Host " https://sankang-gif.github.io/ilhaneun-landing/" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
