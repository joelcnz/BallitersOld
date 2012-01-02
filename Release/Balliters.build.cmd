set PATH=c:\jpro\dmd2\windows\bin;C:\Program Files\Microsoft SDKs\Windows\v6.0A\\bin;%PATH%

echo base.d >Release\Balliters.build.rsp
echo board.d >>Release\Balliters.build.rsp
echo display.d >>Release\Balliters.build.rsp
echo fps.d >>Release\Balliters.build.rsp
echo game.d >>Release\Balliters.build.rsp
echo gameover.d >>Release\Balliters.build.rsp
echo main.d >>Release\Balliters.build.rsp
echo menu.d >>Release\Balliters.build.rsp
echo piece.d >>Release\Balliters.build.rsp
echo pointer.d >>Release\Balliters.build.rsp
echo popup.d >>Release\Balliters.build.rsp
echo setup.d >>Release\Balliters.build.rsp
echo shield.d >>Release\Balliters.build.rsp
echo tkey.d >>Release\Balliters.build.rsp
echo larverbombblow.d >>Release\Balliters.build.rsp
echo lazer.d >>Release\Balliters.build.rsp
echo mine.d >>Release\Balliters.build.rsp
echo ship.d >>Release\Balliters.build.rsp
echo unit.d >>Release\Balliters.build.rsp
echo unitlist.d >>Release\Balliters.build.rsp
echo weakbrickblow.d >>Release\Balliters.build.rsp

dmd -release -X -Xf"Release\Balliters.json" -deps="Release\Balliters.dep" -of"Release\Balliters.exe" -map "Release\Balliters.map" -L/NOMAP @Release\Balliters.build.rsp
if errorlevel 1 goto reportError
if not exist "Release\Balliters.exe" (echo "Release\Balliters.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Release\Balliters.exe failed!

:noError
