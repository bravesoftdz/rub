unit bwts;

(* A bijective BWT (S) adapted from source
 * Mark Nelson
 * March 8, 1996
 * http://web2.airmail.net/markn
 * modifed by David A. Scott Dec of 2007
 * to make a fully bijective BWT
 * modifed by David A. Scott in August of 2000
 * to sort faster and drop EOF
 * modified by Simon P. Jackson, BEng. in June of 2010
 * to become a Java class to BWTS char[] type
 * modified april 2014 into pascal too
 *)

interface
        uses sorter;     (* to sort one lquad = array [0 .. qupper] of integer *)

        type
                cquad = array [0 .. qupper] of ansichar;

        function bwts(inval: cquad): cquad;
        function ibwts(inval: cquad): cquad;
implementation
        var
                bufs, buff2, out: cquad;
                xx, index: lquad;
                T, count: lquad;

        procedure modBufs(aS, aE: integer; m: boolean);
        var
                ch: ansichar;
                p1, i: integer;
        begin
                ch := buff2[aE];
                p1 := aE;
                i := aE + 1;
                while i > aS do
                begin
                        i := i - 1;
                        if buff2[i] <> ch then
                        begin
                                ch := buff2[i];
                                p1 := i + 1;
                        end;
                        if m and (xx[i] = p1) then
                                break;
                        xx[i] := p1;
                end;
                xx[aE] := aS;
        end;

        function lessThanC(i, j: integer; s: boolean): boolean;
        var
                iold, jold, ic, jc: integer;
        begin
                iold := i;
                jold := j;
                ic := 3;
                jc := 3;
                if buff2[i] <> buff2[j] then
                begin
                        lessThanC := buff2[i] < buff2[j];
                        exit;
                end;
                while true do
                begin
                        if i < xx[i] then
                        begin
                                if j < xx[j] then
                                begin
                                        if (xx[i] - i) < (xx[j] - j) then
                                        begin
                                                j := j + xx[i] - i;
                                                i := xx[i];
                                        end
                                        else if (xx[i] - i) > (xx[j] - j) then
                                        begin
                                                i := i + xx[j] - j;
                                                j := xx[j];
                                        end
                                        else
                                        begin
                                                i := xx[i];
                                                j := xx[j];
                                        end
                                end
                                else
                                begin
                                        if jc <> 0 then
                                                jc := jc - 1;
                                        if s then
                                                j := jold
                                        else
                                                j := xx[j];
                                        i := i + 1;
                                end
                        end
                        else
                        begin
                                if j < xx[j] then
                                        j := j + 1
                                else
                                begin
                                        if jc <> 0 then
                                                jc := jc - 1;
                                        if s then
                                                j := jold
                                        else
                                                j := xx[j];
                                end;
                                if s then
                                        i := iold
                                else
                                        i := xx[i];
                                if ic <> 0 then
                                        ic := ic - 1;
                        end;
                        if buff2[i] <> buff2[j] then
                                break;
                        if (ic + jc) = 0 then
                                break;
                end;
                if buff2[i] <> buff2[j] then
                        lessThanC := buff2[i] < buff2[j];
                lessThanC := i < j;
        end;

        function lessThanB(i, j: integer): boolean;
        begin
                lessThanB := lessThanC(i, j, false);//sorter thing!!
        end;

        procedure part_cycle(startS, endS: integer);
        var
                Ns, Ts, i: integer;
        begin
                Ns := endS;
                modBufs(startS, endS, false);
                while true do
                begin
                        if Ns = startS then
                        begin
                                bufs[Ns] := buff2[Ns];
                                xx[Ns] := Ns;
                                exit;
                        end;
                        modBufs(startS, Ns, true);
                        Ts := Ns;			// first guess
                         i := startS;
                        while i < Ns do
                        begin
                                i := xx[i];
                                if lessThanC(Ts, i, true) <> true then
                                        Ts := i;
                        end;
                        modBufs(Ts, Ns, true);
                        bufs[Ts] := buff2[Ns];
                        if Ts = startS then
                                exit;
                        Ns := Ts - 1;
                        bufs[startS] := buff2[Ns];
                end;
        end;

        function bwts(inval: cquad): cquad;
        var
                i: integer;
        begin
                buff2 := inval;
                for i := 0 to qupper do
                        index[i] := i;
                for i := 0 to qupper - 1 do
                        bufs[i + 1] := buff2[i];
                bufs[0] := buff2[qupper];
                part_cycle(0, qupper);
                sort(index, @lessThanB);
                for i := 0 to qupper do
                        buff2[i] := bufs[index[i]];
                bwts := buff2;
        end;

        function ibwts(inval: cquad): cquad;
        var
                i, j, k, sum: integer;
        begin
                buff2 := inval;
                for i := 0 to qupper do
                        count[i] := 0;
                for i := 0 to qupper do
                begin
                        bufs[i] := '0';
                        count[word(buff2[i])] := count[word(buff2[i])] + 1;
                end;
                sum := 0;
                for i := 0 to qupper do
                begin
                        xx[i] := sum;
                        sum := sum + count[i];
                        count[i] := 0;
                end;
                for i := 0 to qupper do
                begin
                        j := integer(buff2[i]);
                        T[count[j] + xx[j]] := i;
                        count[j] := count[j] + 1;
                end;
                i := 0;
                while true do
                begin
                        bufs[i] := '2';	(* 2 top of a cycle *)
                        for j := 0 to qupper do
                        begin
                                i := T[i];
                                if bufs[i] = '2' then
                                        break;
                                bufs[i] := '3';
                        end;
                        for j := i to qupper do
                                if bufs[j] = '0' then
                                        break;
                        if (bufs[j] <> '0') or (j = qupper) then
                                break;
                        i := j;
                end;
                k := 0;
                for i := qupper downto 0 do
                begin
                        if bufs[i] <> '2' then
                                continue;
                        j := T[i];
                        while true do
                        begin
                                if i = j then
                                        break;
                                out[k] := buff2[j];
                                k := k + 1;
                                j := T[j];
                        end;
                        out[k] := buff2[i];
                        k := k + 1;
               end;
               for i := 0 to qupper do
                        buff2[i] := out[i];
               ibwts := buff2;
        end;
end.