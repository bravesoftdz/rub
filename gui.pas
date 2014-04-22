uses App;

type
        TMyApp = object(TApplication)

        end;

        var MyApp : TMyApp;

begin
        MyApp.Init;
        MyApp.Run;
        MyApp.Done;
end.