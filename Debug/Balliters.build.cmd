set PATH=c:\jpro\dmd2\windows\bin;C:\Program Files\Microsoft SDKs\Windows\v7.0A\\bin;%PATH%

echo base.d >Debug\Balliters.build.rsp
echo board.d >>Debug\Balliters.build.rsp
echo display.d >>Debug\Balliters.build.rsp
echo fps.d >>Debug\Balliters.build.rsp
echo game.d >>Debug\Balliters.build.rsp
echo gameover.d >>Debug\Balliters.build.rsp
echo main.d >>Debug\Balliters.build.rsp
echo menu.d >>Debug\Balliters.build.rsp
echo piece.d >>Debug\Balliters.build.rsp
echo pointer.d >>Debug\Balliters.build.rsp
echo popup.d >>Debug\Balliters.build.rsp
echo setup.d >>Debug\Balliters.build.rsp
echo shield.d >>Debug\Balliters.build.rsp
echo tkey.d >>Debug\Balliters.build.rsp
echo larverbombblow.d >>Debug\Balliters.build.rsp
echo lazer.d >>Debug\Balliters.build.rsp
echo lazerbeam.d >>Debug\Balliters.build.rsp
echo mine.d >>Debug\Balliters.build.rsp
echo ship.d >>Debug\Balliters.build.rsp
echo unit.d >>Debug\Balliters.build.rsp
echo unitlist.d >>Debug\Balliters.build.rsp
echo weakbrickblow.d >>Debug\Balliters.build.rsp

dmd -g -debug -X -Xf"Debug\Balliters.json" -deps="Debug\Balliters.dep" -of"Debug\Balliters.exe_cv" -map "Debug\Balliters.map" -L/NOMAP @Debug\Balliters.build.rsp
if errorlevel 1 goto reportError
if not exist "Debug\Balliters.exe_cv" (echo "Debug\Balliters.exe_cv" not created! && goto reportError)
echo Converting debug information...
"C:\Program Files\VisualD\cv2pdb\cv2pdb.exe" -D2 "Debug\Balliters.exe_cv" "Debug\Balliters.exe"
if errorlevel 1 goto reportError
if not exist "Debug\Balliters.exe" (echo "Debug\Balliters.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\Balliters.exe failed!

:noError
