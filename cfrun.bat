@if "%0" == "cfrun.bat" echo Compile file and run it
@rem rdmd -ofcfball main %1 %2 %3 %4 %5 %6 %7 %8 %9
xfbuild +oxfball main.d
xfball.exe %1 %2 %3 %4 %5 %6 %7 %8 %9