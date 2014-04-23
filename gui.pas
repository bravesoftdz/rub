program gui;

uses app, unix;

type
        TMyApp = object(TApplication)

        end;

var MyApp : TMyApp;

begin
        MyApp.Init;
        shell('aplay explode.wav 2> /dev/null &');
        MyApp.Run;
        MyApp.Done;
end.
