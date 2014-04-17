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

(* added delta coder and ZRLE coder *)

interface
        uses sorter;     (* to sort one lquad = array [0 .. qupper] of integer *)

        type
                cquad = array [0 .. qupper] of ansichar;

        function bwts(inval: cquad): cquad;
        function ibwts(inval: cquad): cquad;

        (* effectively makes runs of any into runs of zeros *)
        function delta(inval: cquad): cquad;
        function sigma(inval: cquad): cquad;

        (* effectively compresses runs of zeros *)
        function zrle(inval: cquad; b: boolean): ansistring;
        function izrle(inval: ansistring; b: boolean): cquad;
        (* on b is true do compress, else just convert cquad to ansistring *)

        function more(): ansistring;
        (* if not empty then izrle did not use all inval.
           if empty then only a partial decode happened. *)
        function less(): integer;
        (* if equals qupper, a full cquad was decoded by izrle.
           if less than qupper, this is the buffer end point.
           note: try a larger input string and get a complete block
           if more text is available to make a longer string *)

        function reverse(a: ansistring; b: boolean): ansistring;

implementation
        var
                bufs, buff2, output: cquad;
                xx, idx: lquad;
                T, count: lquad;
                l: integer;
                cc: ansistring;

        function reverse(a: ansistring; b: boolean): ansistring;
        var
                i: integer;
        begin
                if b then
                begin
                        reverse := '';
                        if length(a) = 0 then exit;
                        for i := length(a) - 1 downto 0 do
                                reverse := reverse + pchar(a)[i];
                end
                else
                        reverse := a;
        end;

        function zrle(inval: cquad; b: boolean): ansistring;
        var
                i, c: integer;
        begin
                zrle := '';
                c := 0;
                for i := 0 to qupper do
                begin
                        if (integer(inval[i]) <> 0) or not b then
                        begin
                                if c <> 0 then
                                begin
                                        zrle := zrle + ansichar(0);
                                        zrle := zrle + ansichar(c);
                                        c := 0;
                                end;
                                zrle := zrle + inval[i];
                        end
                        else
                        begin
                                c := c + 1;
                                if c = 256 then (* continue *)
                                begin
                                        zrle := zrle + ansichar(0);
                                        zrle := zrle + ansichar(255);
                                        c := 1;
                                end;
                        end;
                end;
                if c <> 0 then (* final run *)
                begin
                        zrle := zrle + ansichar(0);
                        zrle := zrle + ansichar(c);
                end;
                (* terminator *)
                if b then
                begin
                        zrle := zrle + ansichar(0);
                        zrle := zrle + ansichar(0);
                end;
        end;

        function izrle(inval: ansistring; b: boolean): cquad;
        var
                i, c: integer;
                ch: ansichar;
        begin
                c := 0;
                for i := 0 to qupper do
                begin
                        if c = 0  then
                        begin
                                if length(inval) = 0 then
                                        break;
                                ch := pchar(copy(inval, 0, 1))[0];
                                inval := copy(inval, 1, length(inval));
                                if (integer(ch) <> 0) or not b then
                                begin
                                        izrle[i] := ch;
                                end
                                else
                                begin
                                        if length(inval) = 0 then
                                                break;
                                        c := integer(pchar(copy(inval, 0, 1))[0]);
                                        inval := copy(inval, 1, length(inval));
                                        if c = 0 then (* terminal *)
                                                break;
                                end;
                        end
                        else (* c > 0 *)
                        begin
                                izrle[i] := char(0); (* zero char *)
                                c := c - 1;
                        end;
                end;
                l := i; (* pointer stall *)
                cc := inval;
        end;

        function more(): ansistring;
        begin
                more := cc;
        end;

        function less(): integer;
        begin
                less := l;
        end;

        function delta(inval: cquad): cquad;
        var
                i, j: integer;
        begin
                j := integer(inval[0]);
                delta[0] := char(j);
                for i := 1 to qupper do
                begin
                        delta[i] := ansichar((integer(inval[i]) - j) and 255);
                        j := integer(inval[i - 1]);
                end;
        end;

        function sigma(inval: cquad): cquad;
        var
                i, j: integer;
        begin
                j := integer(inval[0]);
                sigma[0] := char(j);
                for i := 1 to qupper do
                begin
                        sigma[i] := ansichar((integer(inval[i]) + j) and 255);
                        j := integer(sigma[i - 1]);
                end;

        end;

        procedure modBufs(ass, aE: integer; m: boolean);
        var
                ch: ansichar;
                p1, i: integer;
        begin
                ch := buff2[aE];
                p1 := aE;
                i := aE + 1;
                while i > ass do
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
                xx[aE] := ass;
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
                        idx[i] := i;
                for i := 0 to qupper - 1 do
                        bufs[i + 1] := buff2[i];
                bufs[0] := buff2[qupper];
                part_cycle(0, qupper);
                sort(idx, @lessThanB);
                for i := 0 to qupper do
                        buff2[i] := bufs[idx[i]];
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
                        if (j = qupper + 1) or (bufs[j] <> '0') then (* lazy or no buffer overflow *)
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
                                output[k] := buff2[j];
                                k := k + 1;
                                j := T[j];
                        end;
                        output[k] := buff2[i];
                        k := k + 1;
               end;
               for i := 0 to qupper do
                        buff2[i] := output[i];
               ibwts := buff2;
        end;
end.
